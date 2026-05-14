// lib/models/user_model.dart

class UserModel {
  final int id;
  final String googleId;
  final String name;
  final String email;
  final String? avatar;
  final String role; // 'customer' or 'admin'

  UserModel({
    required this.id,
    required this.googleId,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      googleId: json['google_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      role: json['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'google_id': googleId,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role,
    };
  }

  bool get isAdmin => role == 'admin';
}
