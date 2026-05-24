import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('عن التطبيق'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services,
                  size: 50,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'مركز عيادات الأسنان',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'الإصدار 1.0.0',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'عن التطبيق',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'تطبيق متكامل لإدارة عيادات الأسنان، يهدف إلى تسهيل عملية حجز المواعيد ومتابعة المرضى وإدارة المخزون.',
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المميزات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('✓ حجز المواعيد بسهولة'),
                      Text('✓ متابعة المواعيد'),
                      Text('✓ إدارة المخزون'),
                      Text('✓ إدارة المرضى والأطباء'),
                      Text('✓ تقارير مفصلة'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات الاتصال',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('📞 0123456789'),
                      Text('✉️ info@dentalclinic.com'),
                      Text('🌐 www.dentalclinic.com'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                '© 2024 مركز عيادات الأسنان',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}