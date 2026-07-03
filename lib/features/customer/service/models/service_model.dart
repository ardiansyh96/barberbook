import 'package:cloud_firestore/cloud_firestore.dart';

/// Service model representing a barbershop service (haircut, facial, etc.).
///
/// Maps to the `services` collection in Firestore.
class ServiceModel {
  final String id;
  final String nama;
  final int harga; // price in Rupiah
  final int durasi; // duration in minutes
  final String? gambar;
  final String deskripsi;
  final bool aktif;
  final String kategori; // category for filtering (e.g., "Haircuts", "Facial")
  final DateTime? updatedAt;
  final DateTime createdAt;

  const ServiceModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.durasi,
    this.gambar,
    this.deskripsi = '',
    this.aktif = true,
    this.kategori = '',
    required this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      harga: data['harga'] ?? 0,
      durasi: data['durasi'] ?? 30,
      gambar: data['gambar'],
      deskripsi: data['deskripsi'] ?? '',
      aktif: data['aktif'] ?? true,
      kategori: data['kategori'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
      (data["updatedAt"] as Timestamp?)
          ?.toDate(),
    );
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      harga: json['harga'] ?? 0,
      durasi: json['durasi'] ?? 30,
      gambar: json['gambar'],
      deskripsi: json['deskripsi'] ?? '',
      aktif: json['aktif'] ?? true,
      kategori: json['kategori'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'harga': harga,
      'durasi': durasi,
      'gambar': gambar,
      'deskripsi': deskripsi,
      'aktif': aktif,
      'kategori': kategori,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ServiceModel copyWith({
    String? id,
    String? nama,
    int? harga,
    int? durasi,
    String? gambar,
    String? deskripsi,
    bool? aktif,
    String? kategori,
    DateTime? createdAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      durasi: durasi ?? this.durasi,
      gambar: gambar ?? this.gambar,
      deskripsi: deskripsi ?? this.deskripsi,
      aktif: aktif ?? this.aktif,
      kategori: kategori ?? this.kategori,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
