// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // ==================== اختر الرابط المناسب ====================

  // ✅ للأندرويد إيموليتر (Android Studio)
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  // ✅ للـ iOS إيموليتر (ماك)
  // static const String _baseUrl = 'http://127.0.0.1:8000/api';

  // ✅ لجهاز حقيقي (على نفس الشبكة)
  // static const String _baseUrl = 'http://192.168.1.100:8000/api';
  // ============================================================

  // دالة مساعدة للحصول على الـ headers مع التوكن
  static Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== دوال المصادقة (Auth) ====================

  // دالة تسجيل الدخول
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      debugPrint('📤 إرسال طلب تسجيل دخول إلى: $_baseUrl/login');

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 رمز الحالة: ${response.statusCode}');
      debugPrint('📥 الرد: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'خطأ في الاتصال: ${response.statusCode}',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الدخول: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم: $e'
      };
    }
  }

  // دالة تسجيل حساب جديد
  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      debugPrint('📤 إرسال طلب تسجيل جديد إلى: $_baseUrl/register');
      debugPrint('📤 البيانات: $userData');

      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 رمز الحالة: ${response.statusCode}');
      debugPrint('📥 الرد: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'خطأ في الاتصال: ${response.statusCode}',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      debugPrint('❌ خطأ في التسجيل: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم: $e'
      };
    }
  }

  // دالة جلب بيانات المستخدم الحالي
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final headers = await _getHeaders();

      debugPrint('📤 جلب بيانات المستخدم من: $_baseUrl/user');

      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 رمز الحالة: ${response.statusCode}');
      debugPrint('📥 الرد: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'فشل في جلب البيانات: ${response.statusCode}'
        };
      }
    } catch (e) {
      debugPrint('❌ خطأ في جلب البيانات: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال: $e'
      };
    }
  }

  // دالة تسجيل الخروج
  static Future<void> logout() async {
    try {
      final headers = await _getHeaders();

      debugPrint('📤 تسجيل خروج من: $_baseUrl/logout');

      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('✅ تم تسجيل الخروج بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الخروج: $e');
    } finally {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      debugPrint('🗑️ تم حذف البيانات المحلية');
    }
  }

  // دالة حفظ التوكن
  static Future<void> saveToken(String token, Map<String, dynamic> userData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('user', json.encode(userData));
      debugPrint('💾 تم حفظ التوكن والبيانات محلياً');
    } catch (e) {
      debugPrint('❌ خطأ في حفظ البيانات: $e');
    }
  }

  // دالة التحقق من وجود توكن
  static Future<bool> hasToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  // دالة جلب التوكن
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ==================== دوال المريض (Patient) ====================

  // جلب مواعيد المريض
  static Future<Map<String, dynamic>> getMyAppointments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/patient/appointments'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 جلب مواعيد المريض: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في جلب المواعيد: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // جلب قائمة الأطباء
  static Future<Map<String, dynamic>> getDoctors() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/patient/doctors'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 جلب الأطباء: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في جلب الأطباء: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // حجز موعد جديد
  static Future<Map<String, dynamic>> bookAppointment(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/patient/appointment/book'),
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 حجز موعد: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في حجز الموعد: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // ==================== دوال الدكتور (Doctor) ====================

  // جلب مواعيد الدكتور
  static Future<Map<String, dynamic>> getDoctorAppointments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/doctor/appointments'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 جلب مواعيد الدكتور: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في جلب مواعيد الدكتور: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // تحديث حالة الموعد
  static Future<Map<String, dynamic>> updateAppointmentStatus(int id, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/doctor/appointment/update/$id'),
        headers: headers,
        body: json.encode({'status': status}),
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 تحديث حالة الموعد: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في تحديث الموعد: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // ==================== دوال الاستقبال (Reception) ====================

  // جلب المواعيد المنتظرة
  static Future<Map<String, dynamic>> getPendingAppointments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/reception/pending'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 جلب المواعيد المنتظرة: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في جلب المواعيد المنتظرة: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // تأكيد موعد
  static Future<Map<String, dynamic>> confirmAppointment(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/reception/confirm/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 تأكيد الموعد: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في تأكيد الموعد: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // جلب مواعيد اليوم
  static Future<Map<String, dynamic>> getTodayAppointments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/reception/today'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 جلب مواعيد اليوم: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في جلب مواعيد اليوم: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // ==================== دوال أمين المستودع (Store Keeper) ====================

  // جلب المخزون
  static Future<Map<String, dynamic>> getInventory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/store/inventory'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 جلب المخزون: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في جلب المخزون: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // تحديث كمية صنف
  static Future<Map<String, dynamic>> updateStock(int id, int quantity) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/store/update/$id'),
        headers: headers,
        body: json.encode({'quantity': quantity}),
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 تحديث المخزون: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في تحديث المخزون: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // جلب المواد منخفضة المخزون
  static Future<Map<String, dynamic>> getLowStock() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/store/low-stock'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 جلب المواد منخفضة المخزون: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في جلب المواد منخفضة المخزون: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // ==================== دوال الأدمن (Admin) ====================

  // جلب إحصائيات الأدمن
  static Future<Map<String, dynamic>> getAdminStatistics() async {
    try {
      final headers = await _getHeaders();
      debugPrint('📤 جلب إحصائيات الأدمن من: $_baseUrl/admin/statistics');

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/statistics'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 رد الإحصائيات: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'فشل جلب الإحصائيات: ${response.statusCode}'
        };
      }
    } catch (e) {
      debugPrint('❌ خطأ في جلب الإحصائيات: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // جلب جميع المستخدمين
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/users'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 جلب جميع المستخدمين: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في جلب المستخدمين: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // جلب الأطباء للأدمن
  static Future<Map<String, dynamic>> getDoctorsForAdmin() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/doctors'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 جلب الأطباء للأدمن: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في جلب الأطباء: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // جلب المواعيد للأدمن
  static Future<Map<String, dynamic>> getAppointmentsForAdmin() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/appointments'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 جلب المواعيد للأدمن: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في جلب المواعيد: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // جلب المخزون للأدمن
  static Future<Map<String, dynamic>> getInventoryForAdmin() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/inventory'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 جلب المخزون للأدمن: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في جلب المخزون: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // إنشاء مستخدم جديد (للأدمن)
  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/user/create'),
        headers: headers,
        body: json.encode(userData),
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 إنشاء مستخدم: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء المستخدم: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // تحديث مستخدم
  static Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/user/update/$id'),
        headers: headers,
        body: json.encode(userData),
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 تحديث مستخدم: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في تحديث المستخدم: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // حذف مستخدم
  static Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/admin/user/delete/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 حذف مستخدم: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في حذف المستخدم: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // ==================== دوال الممرض (Nurse) ====================

  // جلب مهام التمريض
  static Future<Map<String, dynamic>> getNurseTasks() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/nurse/tasks'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 جلب مهام التمريض: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في جلب مهام التمريض: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  // تحديث حالة مهمة تمريضية
  static Future<Map<String, dynamic>> updateNurseTaskStatus(int id, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/nurse/update/$id'),
        headers: headers,
        body: json.encode({'status': status}),
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 تحديث حالة المهمة: ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ خطأ في تحديث حالة المهمة: $e');
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }
}