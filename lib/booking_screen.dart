import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // متغيرات لحفظ البيانات
  List doctors = []; // قائمة الدكاترة اللي رح نجيبهم من السيرفر
  String? selectedDoctorId; // رقم الدكتور اللي اختاره المريض
  DateTime selectedDate = DateTime.now(); // التاريخ المختار

  @override
  void initState() {
    super.initState();
    getDoctorsFromServer(); // أول ما تفتح الصفحة، جيب الدكاترة فوراً
  }

  // دالة تجيب الدكاترة من اللارافيل
  Future getDoctorsFromServer() async {
    // ملاحظة: غير الـ IP لعنوان جهازك أو استخدم 10.0.2.2 للأندرويد
    var url = Uri.parse('http://10.0.2.2:8000/api/doctors');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      setState(() {
        doctors = jsonData['data']; // حطينا الدكاترة بالليستة
      });
    }
  }

  // دالة إرسال الحجز للسيرفر
  Future sendBooking() async {
    var url = Uri.parse('http://10.0.2.2:8000/api/appointment/book');
    var response = await http.post(url, body: {
      'doctor_id': selectedDoctorId,
      'patient_id': '1', // مؤقتاً حط رقم 1 لحد ما نتعلم تسجيل الدخول
      'date': selectedDate.toString(), // التاريخ والوقت
    });

    if (response.statusCode == 201) {
      print("تم الحجز بنجاح!");
      // هون بنقدر نظهر رسالة نجاح للمريض
    } else {
      print("فشل الحجز: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("حجز موعد جديد")),
      body: doctors.isEmpty
          ? Center(child: CircularProgressIndicator()) // لو لسه عم يحمل أظهر دائرة تحميل
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("اختر الطبيب المناسب:"),
            // قائمة منسدلة لاختيار الدكتور
            DropdownButton(
              value: selectedDoctorId,
              hint: Text("اضغط للاختيار"),
              items: doctors.map((doc) {
                return DropdownMenuItem(
                  value: doc['id'].toString(),
                  child: Text(doc['name']),
                );
              }).toList(),
              onChanged: (val) {
                setState(() { selectedDoctorId = val as String?; });
              },
            ),

            SizedBox(height: 30),

            Text("اختر التاريخ والوقت:"),
            // زر يفتح التقويم
            ElevatedButton(
              onPressed: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2027),
                );
                if (date != null) setState(() { selectedDate = date; });
              },
              child: Text("افتح التقويم"),
            ),

            Spacer(),

            // زر الحجز النهائي
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 50)),
              onPressed: sendBooking,
              child: Text("تأكيد الحجز", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}