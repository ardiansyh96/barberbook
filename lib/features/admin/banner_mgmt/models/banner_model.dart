import 'package:cloud_firestore/cloud_firestore.dart';

/// Banner model for promotional banners displayed on the customer dashboard.
///
/// Maps to the `banners` collection in Firestore.
/// Admin can create, activate/deactivate, and delete banners.
class BannerModel {
  final String id;
  final String gambar; // image URL
  final String judul; // title
  final bool aktif;
  final String? deskripsi;
  final String? linkTarget; // optional deep link or screen route
  final int urutan; // display order
  final DateTime createdAt;

  const BannerModel({
    required this.id,
    required this.gambar,
    required this.judul,
    this.aktif = true,
    this.deskripsi,
    this.linkTarget,
    this.urutan = 0,
    required this.createdAt,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      gambar: data['gambar'] ?? '',
      judul: data['judul'] ?? '',
      aktif: data['aktif'] ?? true,
      deskripsi: data['deskripsi'],
      linkTarget: data['linkTarget'],
      urutan: data['urutan'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      gambar: json['gambar'] ?? '',
      judul: json['judul'] ?? '',
      aktif: json['aktif'] ?? true,
      deskripsi: json['deskripsi'],
      linkTarget: json['linkTarget'],
      urutan: json['urutan'] ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gambar': gambar,
      'judul': judul,
      'aktif': aktif,
      'deskripsi': deskripsi,
      'linkTarget': linkTarget,
      'urutan': urutan,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  BannerModel copyWith({
    String? id,
    String? gambar,
    String? judul,
    bool? aktif,
    String? deskripsi,
    String? linkTarget,
    int? urutan,
    DateTime? createdAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      gambar: gambar ?? this.gambar,
      judul: judul ?? this.judul,
      aktif: aktif ?? this.aktif,
      deskripsi: deskripsi ?? this.deskripsi,
      linkTarget: linkTarget ?? this.linkTarget,
      urutan: urutan ?? this.urutan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
