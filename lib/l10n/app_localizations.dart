// lib/l10n/app_localizations.dart
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  // ========== النصوص حسب اللغة ==========
  bool get isArabic => locale.languageCode == 'ar';

  String get appTitle => isArabic ? 'مركز عيادات الأسنان' : 'Dental Clinic Center';

  String get login => isArabic ? 'تسجيل الدخول' : 'Login';
  String get register => isArabic ? 'تسجيل حساب جديد' : 'Register';
  String get logout => isArabic ? 'تسجيل الخروج' : 'Logout';
  String get email => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get name => isArabic ? 'الاسم الكامل' : 'Full Name';
  String get phone => isArabic ? 'رقم الهاتف' : 'Phone Number';

  String get patient => isArabic ? 'مريض' : 'Patient';
  String get doctor => isArabic ? 'طبيب' : 'Doctor';
  String get reception => isArabic ? 'ريسبشن' : 'Reception';
  String get storeKeeper => isArabic ? 'أمين مستودع' : 'Store Keeper';
  String get admin => isArabic ? 'أدمن' : 'Admin';

  String get myAppointments => isArabic ? 'مواعيدي' : 'My Appointments';
  String get doctors => isArabic ? 'الأطباء' : 'Doctors';
  String get pending => isArabic ? 'قيد الانتظار' : 'Pending';
  String get confirmed => isArabic ? 'مؤكد' : 'Confirmed';
  String get completed => isArabic ? 'مكتمل' : 'Completed';
  String get cancelled => isArabic ? 'ملغي' : 'Cancelled';

  String get inventory => isArabic ? 'المخزون' : 'Inventory';
  String get lowStock => isArabic ? 'منخفض المخزون' : 'Low Stock';
  String get totalItems => isArabic ? 'إجمالي الأصناف' : 'Total Items';

  String get bookAppointment => isArabic ? 'حجز موعد' : 'Book Appointment';
  String get selectDoctor => isArabic ? 'اختر الدكتور' : 'Select Doctor';
  String get selectDate => isArabic ? 'اختر التاريخ' : 'Select Date';
  String get selectTime => isArabic ? 'اختر الوقت' : 'Select Time';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get save => isArabic ? 'حفظ' : 'Save';

  String get welcome => isArabic ? 'مرحباً بك' : 'Welcome';
  String get noAppointments => isArabic ? 'لا يوجد مواعيد' : 'No appointments';
  String get noDoctors => isArabic ? 'لا يوجد أطباء' : 'No doctors';
  String get noItems => isArabic ? 'لا توجد أصناف' : 'No items';

  String get error => isArabic ? 'حدث خطأ' : 'An error occurred';
  String get connectionError => isArabic ? 'خطأ في الاتصال' : 'Connection error';

  String get selectLanguage => isArabic ? 'اختر اللغة' : 'Select Language';
  String get arabic => isArabic ? 'العربية' : 'Arabic';
  String get english => isArabic ? 'الإنجليزية' : 'English';

  // أخطاء
  String get emailRequired => isArabic ? 'الرجاء إدخال البريد الإلكتروني' : 'Email is required';
  String get passwordRequired => isArabic ? 'الرجاء إدخال كلمة المرور' : 'Password is required';
  String get nameRequired => isArabic ? 'الرجاء إدخال الاسم' : 'Name is required';
  String get passwordMinLength => isArabic ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل' : 'Password must be at least 6 characters';
  String get invalidEmail => isArabic ? 'البريد الإلكتروني غير صحيح' : 'Invalid email address';

  // شاشات
  String get patientHome => isArabic ? 'الصفحة الرئيسية - مريض' : 'Patient Home';
  String get doctorHome => isArabic ? 'الصفحة الرئيسية - طبيب' : 'Doctor Home';
  String get receptionHome => isArabic ? 'لوحة التحكم - استقبال' : 'Reception Dashboard';
  String get storeKeeperHome => isArabic ? 'لوحة التحكم - أمين مستودع' : 'Store Keeper Dashboard';
  String get adminHome => isArabic ? 'لوحة تحكم الأدمن' : 'Admin Dashboard';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}