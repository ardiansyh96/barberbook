import 'package:cloud_firestore/cloud_firestore.dart';

class BarberModel {
  final String id;
  final String nama;
  final String spesialis;
  final int pengalaman;
  final String? foto;
  final double rating;
  final bool statusAktif;
  final String jamMasuk;
  final String jamPulang;
  final int totalReviews;
  final DateTime createdAt;

  const BarberModel({
    required this.id,
    required this.nama,
    required this.spesialis,
    required this.pengalaman,
    this.foto,
    this.rating = 0.0,
    this.statusAktif = true,
    required this.jamMasuk,
    required this.jamPulang,
    this.totalReviews = 0,
    required this.createdAt,
  });

  factory BarberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BarberModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      spesialis: data['spesialis'] ?? '',
      pengalaman: (data['pengalaman'] ?? 0) as int,
      foto: data['foto'],

      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,

      // Support field lama maupun baru
      statusAktif: data['statusAktif'] ??
          data['aktif'] ??
          true,

      // Support field lama maupun baru
      jamMasuk: data['jamMasuk'] ??
          data['jamMulai'] ??
          '09:00',

      jamPulang: data['jamPulang'] ??
          data['jamSelesai'] ??
          '21:00',

      totalReviews: data['totalReviews'] ??
          data['jumlahReview'] ??
          0,

      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'spesialis': spesialis,
      'pengalaman': pengalaman,
      'foto': foto,
      'rating': rating,

      // Simpan dua-duanya supaya kompatibel
      'statusAktif': statusAktif,
      'aktif': statusAktif,

      'jamMasuk': jamMasuk,
      'jamMulai': jamMasuk,

      'jamPulang': jamPulang,
      'jamSelesai': jamPulang,

      'totalReviews': totalReviews,
      'jumlahReview': totalReviews,

      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}