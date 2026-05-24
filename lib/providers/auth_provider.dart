// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;  // 👈 أضف هذا

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;  // 👈 أضف هذا (getter)

  AuthProvider() {
    _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString('user');
      String? savedToken = prefs.getString('token');

      if (userJson != null && savedToken != null) {
        _token = savedToken;
        _currentUser = User.fromJson(json.decode(userJson));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('خطأ في تحميل المستخدم المحفوظ: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;  // 👈 أضف هذا
    notifyListeners();

    try {
      var result = await ApiService.login(email, password);

      debugPrint('📥 نتيجة تسجيل الدخول: $result');

      if (result['success'] == true) {
        debugPrint('✅ تسجيل دخول ناجح');

        _token = result['token'];
        _currentUser = User.fromJson(result['user']);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', json.encode(result['user']));

        debugPrint('✅ تم حفظ بيانات المستخدم');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'فشل تسجيل الدخول';  // 👈 أضف هذا
        debugPrint('❌ فشل تسجيل الدخول: ${result['message']}');
      }
    } catch (e) {
      _errorMessage = 'خطأ في الاتصال: $e';  // 👈 أضف هذا
      debugPrint('❌ خطأ في تسجيل الدخول: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;  // 👈 أضف هذا
    notifyListeners();

    try {
      var result = await ApiService.register(userData);

      debugPrint('📥 نتيجة التسجيل: $result');

      if (result['success'] == true) {
        debugPrint('✅ تسجيل ناجح');

        _token = result['token'];
        _currentUser = User.fromJson(result['user']);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', json.encode(result['user']));

        debugPrint('✅ تم حفظ البيانات');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'فشل التسجيل';  // 👈 أضف هذا
        debugPrint('❌ فشل التسجيل: ${result['message']}');
      }
    } catch (e) {
      _errorMessage = 'خطأ في الاتصال: $e';  // 👈 أضف هذا
      debugPrint('❌ خطأ في التسجيل: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      debugPrint('✅ تم تسجيل الخروج');
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الخروج: $e');
    }

    _currentUser = null;
    _token = null;
    _errorMessage = null;  // 👈 أضف هذا
    notifyListeners();
  }
}