import 'package:cloud_firestore/cloud_firestore.dart';

/// Review model for customer ratings after completed bookings.
///
/// Maps to the `reviews` collection in Firestore.
/// Each review is linked to a booking, customer, and barber.
class ReviewModel {
  final String id;
  final String bookingId;
  final String customerId;
  final String barberId;
  final int rating; // 1-5 stars
  final String komentar;
  final String? customerNama;
  final String? customerPhoto;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.barberId,
    required this.rating,
    this.komentar = '',
    this.customerNama,
    this.customerPhoto,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      customerId: data['customerId'] ?? '',
      barberId: data['barberId'] ?? '',
      rating: data['rating'] ?? 0,
      komentar: data['komentar'] ?? '',
      customerNama: data['customerNama'],
      customerPhoto: data['customerPhoto'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      customerId: json['customerId'] ?? '',
      barberId: json['barberId'] ?? '',
      rating: json['rating'] ?? 0,
      komentar: json['komentar'] ?? '',
      customerNama: json['customerNama'],
      customerPhoto: json['customerPhoto'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'customerId': customerId,
      'barberId': barberId,
      'rating': rating,
      'komentar': komentar,
      'customerNama': customerNama,
      'customerPhoto': customerPhoto,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? bookingId,
    String? customerId,
    String? barberId,
    int? rating,
    String? komentar,
    String? customerNama,
    String? customerPhoto,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      barberId: barberId ?? this.barberId,
      rating: rating ?? this.rating,
      komentar: komentar ?? this.komentar,
      customerNama: customerNama ?? this.customerNama,
      customerPhoto: customerPhoto ?? this.customerPhoto,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
