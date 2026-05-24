import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';

class ReceptionHomeScreen extends StatefulWidget {
  const ReceptionHomeScreen({super.key});

  @override
  State<ReceptionHomeScreen> createState() => _ReceptionHomeScreenState();
}

class _ReceptionHomeScreenState extends State<ReceptionHomeScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _pendingAppointments = [];
  List<dynamic> _todayAppointments = [];
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose(); // 👈 تنظيف الـ Controller ضروري للأداء
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pendingResult = await ApiService.getPendingAppointments();
      final todayResult = await ApiService.getTodayAppointments();

      if (!mounted) return; // 👈 فحص الأمان بعد الـ await

      setState(() {
        if (pendingResult['success'] == true) {
          _pendingAppointments = pendingResult['data'] ?? [];
        }
        if (todayResult['success'] == true) {
          _todayAppointments = todayResult['data'] ?? [];
        }
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ في جلب البيانات: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmAppointment(int id) async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.confirmAppointment(id);

      if (!mounted) return;

      if (result['success'] == true) {
        await _loadData(); // إعادة تحميل البيانات بعد التأكيد
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تأكيد الموعد وإرسال إشعار للمريض')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التأكيد: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // 👈 إضافة const هنا حسّنت أداء التصيير
        drawer: const AppDrawer(currentRole: 'reception'),
        appBar: AppBar(
          title: const Text('قسم الاستقبال والمواعيد'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(icon: Icon(Icons.pending_actions), text: 'بانتظار التأكيد'),
              Tab(icon: Icon(Icons.today), text: 'مواعيد اليوم'),
            ],
          ),
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
          onRefresh: _loadData,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAppointmentsList(
                _pendingAppointments,
                showConfirmButton: true,
                onConfirm: _confirmAppointment,
              ),
              _buildAppointmentsList(_todayAppointments),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // هنا ممكن تفتح صفحة إضافة مريض جديد
          },
          label: const Text('حجز جديد'),
          icon: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(
      List<dynamic> appointments, {
        bool showConfirmButton = false,
        Function(int)? onConfirm,
      }) {
    if (_isLoading && appointments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && appointments.isEmpty) {
      return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }

    if (appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد مواعيد في هذه القائمة', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final patientName = appointment['patient']?['name'] ?? 'مريض مجهول';
        final doctorName = appointment['doctor']?['name'] ?? 'طبيب غير محدد';
        final status = appointment['status'] ?? 'pending';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(patientName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.medical_services_outlined, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text('د. $doctorName'),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(appointment['date'] ?? '', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            trailing: showConfirmButton && status == 'pending'
                ? ElevatedButton(
              onPressed: () => onConfirm?.call(appointment['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('تأكيد'),
            )
                : _buildStatusChip(status),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    bool isConfirmed = status == 'confirmed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isConfirmed ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isConfirmed ? Colors.green.shade200 : Colors.orange.shade200),
      ),
      child: Text(
        isConfirmed ? 'مؤكد' : 'بانتظار التأكيد',
        style: TextStyle(
          color: isConfirmed ? Colors.green.shade700 : Colors.orange.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}