// lib/models/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;  // 👈 أضف هذا (nullable)

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,  // 👈 أضف هذا
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'patient',
      phone: json['phone']?.toString() ?? '',  // 👈 أضف هذا
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,  // 👈 أضف هذا
    };
  }
}