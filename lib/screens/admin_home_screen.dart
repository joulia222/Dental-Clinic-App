import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _users = [];
  Map<String, dynamic> _stats = {
    'total_appointments': 0,
    'total_doctors': 0,
    'total_inventory': 0,
    'total_users': 0,
    'pending_appointments': 0,
    'confirmed_appointments': 0,
    'completed_appointments': 0,
    'low_stock_items': 0,
  };
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // دالة موحدة لجلب المستخدمين والإحصائيات
  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // جلب البيانات بالتوازي لتحسين السرعة
      final results = await Future.wait([
        ApiService.getAllUsers(),
        ApiService.getAdminStatistics(),
      ]);

      if (!mounted) return;

      setState(() {
        if (results[0]['success'] == true) {
          _users = results[0]['data'] ?? [];
        }
        if (results[1]['success'] == true) {
          _stats = results[1]['data'] ?? _stats;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ أثناء جلب البيانات: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteUser(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المستخدم "$name"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final result = await ApiService.deleteUser(id);
        if (!mounted) return;
        if (result['success'] == true) {
          await _loadAllData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حذف المستخدم')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: const AppDrawer(currentRole: 'admin'),
        appBar: AppBar(
          title: const Text('لوحة تحكم النظام'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.dashboard), text: 'الإحصائيات'),
              Tab(icon: Icon(Icons.people), text: 'إدارة المستخدمين'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authProvider.logout(),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDashboard(authProvider),
            _buildUsersList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  Widget _buildDashboard(AuthProvider authProvider) {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAdminProfileCard(authProvider),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'إحصائيات عامة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  'إجمالي المستخدمين',
                  (_stats['total_users'] ?? _users.length).toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatCard(
                  'المواعيد المحجوزة',
                  _stats['total_appointments'].toString(),
                  Icons.event_available,
                  Colors.green,
                ),
                _buildStatCard(
                  'الأطباء النشطين',
                  _stats['total_doctors'].toString(),
                  Icons.local_hospital,
                  Colors.orange,
                ),
                _buildStatCard(
                  'أصناف المخزون',
                  _stats['total_inventory'].toString(),
                  Icons.inventory_2,
                  Colors.purple,
                ),
                _buildStatCard(
                  'مواعيد قيد الانتظار',
                  _stats['pending_appointments'].toString(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
                _buildStatCard(
                  'أصناف منخفضة المخزون',
                  _stats['low_stock_items'].toString(),
                  Icons.warning,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminProfileCard(AuthProvider authProvider) {
    final user = authProvider.currentUser;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.red.shade100,
              child: Text(
                user?.name[0].toUpperCase() ?? 'A',
                style: const TextStyle(fontSize: 28, color: Colors.red),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'مدير النظام',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Text(
                    'صلاحية: مدير كامل',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      color: color.withValues(alpha: 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final role = user['type'] ?? user['role'] ?? 'patient';
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(role),
              child: Text(
                user['name'][0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(user['name'] ?? ''),
            subtitle: Text(_getRoleLabel(role)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: () => _deleteUser(user['id'], user['name']),
            ),
          ),
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'doctor':
        return Colors.blue;
      case 'reception':
        return Colors.green;
      case 'store_keeper':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'مدير النظام';
      case 'doctor':
        return 'طبيب';
      case 'reception':
        return 'موظف استقبال';
      case 'store_keeper':
        return 'أمين مستودع';
      default:
        return 'مريض';
    }
  }
}