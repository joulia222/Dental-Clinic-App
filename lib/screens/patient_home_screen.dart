import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  List<dynamic> _appointments = [];
  List<dynamic> _doctors = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return; // تأكد أن الشاشة موجودة قبل البدء

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appointmentsResult = await ApiService.getMyAppointments();
      final doctorsResult = await ApiService.getDoctors();

      // التحقق من mounted بعد كل await (Async Gap)
      if (!mounted) return;

      if (appointmentsResult['success'] == true) {
        setState(() {
          _appointments = appointmentsResult['data'] ?? [];
        });
      }

      if (doctorsResult['success'] == true) {
        setState(() {
          _doctors = doctorsResult['data'] ?? [];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openBookingScreen() async {
    if (!mounted) return;

    if (_doctors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد أطباء متاحين حالياً')),
      );
      return;
    }

    // عرض الـ Dialog هو عملية async
    final selectedDoctor = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر الدكتور'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _doctors.length,
            itemBuilder: (context, index) {
              final doctor = _doctors[index];
              return ListTile(
                leading: const Icon(Icons.medical_services),
                title: Text(doctor['name'] ?? ''),
                subtitle: Text(doctor['specialization']?['name'] ?? ''),
                onTap: () => Navigator.pop(context, doctor),
              );
            },
          ),
        ),
      ),
    );

    if (selectedDoctor == null || !mounted) return;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (selectedDate == null || !mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (selectedTime == null || !mounted) return;

    final appointmentDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحجز'),
        content: Text(
          'هل أنت متأكد من حجز موعد مع د. ${selectedDoctor['name']} في:\n'
              '${appointmentDateTime.toString()}؟', // يفضل استخدام toString بسيط أو Intl
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await ApiService.bookAppointment({
        'doctor_id': selectedDoctor['id'],
        'patient_id': authProvider.currentUser?.id,
        'date': appointmentDateTime.toIso8601String(),
      });

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حجز الموعد بنجاح')),
        );
        _loadData(); // إعادة تحميل البيانات
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'فشل الحجز')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // استخدمنا consumer أو provider.of بذكاء هنا
    final authProvider = Provider.of<AuthProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: const AppDrawer(currentRole: 'patient'), // أضفت const هنا
        appBar: AppBar(
          title: const Text('الصفحة الرئيسية - مريض'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authProvider.logout();
                // بعد الـ logout يفضل التوجيه لصفحة اللوجن إذا لم يكن البروفايدر يفعل ذلك تلقائياً
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            authProvider.currentUser?.name.isNotEmpty == true
                                ? authProvider.currentUser!.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          authProvider.currentUser?.name ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          authProvider.currentUser?.email ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'الأطباء',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_errorMessage != null)
                  Center(child: Text(_errorMessage!))
                else if (_doctors.isEmpty)
                    const Center(child: Text('لا يوجد أطباء'))
                  else
                    SizedBox(
                      height: 140, // زدت الارتفاع قليلاً لتجنب الـ Overflow
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _doctors[index];
                          return Card(
                            margin: const EdgeInsets.only(left: 10), // تعديل الهامش لليمين
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  const Icon(Icons.medical_services, size: 40, color: Colors.blue),
                                  const SizedBox(height: 5),
                                  Text(doctor['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    doctor['specialization']?['name'] ?? '',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                const SizedBox(height: 20),
                const Text(
                  'مواعيدي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (_appointments.isEmpty && !_isLoading)
                  const Center(child: Text('لا يوجد مواعيد حالية'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _appointments[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today, color: Colors.blue),
                          title: Text('د. ${appointment['doctor']?['name'] ?? 'غير معروف'}'),
                          subtitle: Text(appointment['date'] ?? ''),
                          trailing: _buildStatusBadge(appointment['status'] ?? 'pending'),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openBookingScreen,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // دالة مساعدة لتنظيف كود الـ UI
  Widget _buildStatusBadge(String status) {
    bool isConfirmed = status == 'confirmed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isConfirmed ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isConfirmed ? 'مؤكد' : 'قيد الانتظار',
        style: TextStyle(color: isConfirmed ? Colors.green : Colors.orange),
      ),
    );
  }
}