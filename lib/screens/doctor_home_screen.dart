import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getDoctorAppointments();

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _appointments = result['data'] ?? [];
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ في تحميل المواعيد: $e';
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

  Future<void> _updateStatus(int id, String status) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.updateAppointmentStatus(id, status);

      if (!mounted) return;

      if (result['success'] == true) {
        await _loadAppointments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث حالة الموعد بنجاح')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التحديث: $e')),
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: const AppDrawer(currentRole: 'doctor'), // أضفت const هنا
        appBar: AppBar(
          title: const Text('لوحة تحكم الطبيب'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authProvider.logout();
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadAppointments,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // كرت معلومات الطبيب
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? '',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                user?.email ?? '',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'جدول المواعيد اليومية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 10),

                if (_isLoading && _appointments.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ))
                else if (_errorMessage != null)
                  Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                else if (_appointments.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('لا توجد مواعيد مسجلة حالياً'),
                    ))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _appointments[index];
                        final status = appointment['status'] ?? 'pending';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              child: Text(
                                appointment['patient']?['name']?.isNotEmpty == true
                                    ? appointment['patient']['name'][0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                            title: Text(
                              appointment['patient']?['name'] ?? 'مريض غير معروف',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(appointment['date'] ?? 'بدون تاريخ'),
                            trailing: _buildStatusBadge(status),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    if (status == 'pending')
                                      _buildActionButton(
                                          'تأكيد',
                                          Colors.green,
                                              () => _updateStatus(appointment['id'], 'confirmed')
                                      ),
                                    if (status == 'confirmed')
                                      _buildActionButton(
                                          'إتمام',
                                          Colors.blue,
                                              () => _updateStatus(appointment['id'], 'completed')
                                      ),
                                    _buildActionButton(
                                        'إلغاء',
                                        Colors.red,
                                            () => _updateStatus(appointment['id'], 'cancelled'),
                                        isOutlined: true
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة لبناء شارة الحالة (Badge)
  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'confirmed':
        color = Colors.green; text = 'مؤكد'; break;
      case 'completed':
        color = Colors.blue; text = 'مكتمل'; break;
      case 'cancelled':
        color = Colors.red; text = 'ملغي'; break;
      default:
        color = Colors.orange; text = 'انتظار';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  // دالة لبناء أزرار العمليات
  Widget _buildActionButton(String label, Color color, VoidCallback onPressed, {bool isOutlined = false}) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(foregroundColor: color, side: BorderSide(color: color)),
        child: Text(label),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
      child: Text(label),
    );
  }
}