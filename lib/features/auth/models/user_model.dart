import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing both Customer and Admin roles.
///
/// Maps to the `users` collection in Firestore.
/// The [role] field determines which features and screens the user can access.
class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String? nomorHP;
  final String? photo;
  final String role; // 'customer' or 'admin'
  final String? fcmToken;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    this.nomorHP,
    this.photo,
    required this.role,
    this.fcmToken,
    required this.createdAt,
  });

  /// Check if this user has admin privileges
  bool get isAdmin => role == 'admin';

  /// Check if this user is a customer
  bool get isCustomer => role == 'customer';

  /// Create a UserModel from a Firestore document snapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      nomorHP: data['nomorHP'],
      photo: data['photo'],
      role: data['role'] ?? 'customer',
      fcmToken: data['fcmToken'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      nomorHP: json['nomorHP'],
      photo: json['photo'],
      role: json['role'] ?? 'customer',
      fcmToken: json['fcmToken'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Convert to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'email': email,
      'nomorHP': nomorHP,
      'photo': photo,
      'role': role,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with modified fields
  UserModel copyWith({
    String? uid,
    String? nama,
    String? email,
    String? nomorHP,
    String? photo,
    String? role,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      nomorHP: nomorHP ?? this.nomorHP,
      photo: photo ?? this.photo,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
