import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';

class StoreKeeperHomeScreen extends StatefulWidget {
  const StoreKeeperHomeScreen({super.key});

  @override
  State<StoreKeeperHomeScreen> createState() => _StoreKeeperHomeScreenState();
}

class _StoreKeeperHomeScreenState extends State<StoreKeeperHomeScreen> {
  List<dynamic> _inventory = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.getInventory();

      if (!mounted) return; // فحص بعد الـ await

      if (result['success'] == true) {
        setState(() {
          _inventory = result['data'] ?? [];
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
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

  Future<void> _updateStock(int id, int newQuantity) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.updateStock(id, newQuantity);

      if (!mounted) return; // فحص أمان (Async Gap)

      if (result['success'] == true) {
        await _loadInventory(); // تحديث القائمة

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث المخزون بنجاح')),
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showUpdateDialog(int id, String name, int currentQuantity) {
    final quantityController = TextEditingController(
      text: currentQuantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تحديث كمية: $name'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'الكمية الجديدة',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final newQuantity = int.tryParse(quantityController.text);
              if (newQuantity != null) {
                _updateStock(id, newQuantity);
              }
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // مراقبة الـ AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // أضفت const هنا لتحسين الأداء
        drawer: const AppDrawer(currentRole: 'store_keeper'),
        appBar: AppBar(
          title: const Text('لوحة التحكم - أمين مستودع'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authProvider.logout();
                // Navigator يفضل أن يكون هنا إذا لم يكن البروفايدر يوجه تلقائياً
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadInventory,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // كرت معلومات المستخدم
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 24),
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
                const SizedBox(height: 20),
                // الإحصائيات السريعة
                Row(
                  children: [
                    _buildStatCard(
                      'إجمالي الأصناف',
                      _inventory.length.toString(),
                      Icons.inventory,
                      Colors.blue,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      'منخفضة المخزون',
                      _inventory.where((item) => (item['quantity'] ?? 0) < 10).length.toString(),
                      Icons.warning,
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'قائمة المخزون',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                // قائمة الأصناف
                if (_isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else if (_errorMessage != null)
                  Expanded(child: Center(child: Text(_errorMessage!)))
                else if (_inventory.isEmpty)
                    const Expanded(child: Center(child: Text('لا توجد أصناف في المخزون')))
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _inventory.length,
                        itemBuilder: (context, index) {
                          final item = _inventory[index];
                          final quantity = item['quantity'] ?? 0;
                          final isLowStock = quantity < 10;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isLowStock ? Colors.orange.shade50 : Colors.green.shade50,
                                child: Icon(
                                  Icons.category,
                                  color: isLowStock ? Colors.orange : Colors.green,
                                ),
                              ),
                              title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(item['type'] ?? 'صنف طبي'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$quantity',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isLowStock ? Colors.red : Colors.green,
                                    ),
                                  ),
                                  const Text('قطعة', style: TextStyle(fontSize: 10)),
                                ],
                              ),
                              onTap: () => _showUpdateDialog(item['id'], item['name'], quantity),
                            ),
                          );
                        },
                      ),
                    ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // إضافة صنف جديد مستقبلاً
          },
          child: const Icon(Icons.add_business),
        ),
      ),
    );
  }

  // دالة مساعدة لبناء كروت الإحصائيات لتقليل تكرار الكود
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1), // استبدال withOpacity بالتحديث الجديد
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}