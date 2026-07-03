import 'package:cloud_firestore/cloud_firestore.dart';

/// Booking model representing a reservation made by a customer.
///
/// Maps to the `bookings` collection in Firestore.
/// Status flow: pending -> confirmed -> processing -> completed
///                              \-> rejected
///                  cancelled (by customer from pending/confirmed)
class BookingModel {
  final String id;
  final String customerId;
  final String barberId;
  final String serviceId;
  final DateTime tanggal;
  final String jam; // time slot "HH:mm"
  final String status; // pending, confirmed, processing, completed, rejected, cancelled
  final String? catatan; // customer notes
  final int totalHarga;
  final DateTime createdAt;

  // Denormalized fields for display (avoid extra reads)
  final String? customerNama;
  final String? barberNama;
  final String? serviceNama;
  final String? barberFoto;
  final bool hasRated;

  final String? rejectReason;
  final DateTime? confirmedAt;
  final DateTime? processingAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  const BookingModel({
    required this.id,
    required this.customerId,
    required this.barberId,
    required this.serviceId,
    required this.tanggal,
    required this.jam,
    required this.status,
    this.catatan,
    required this.totalHarga,
    required this.createdAt,
    this.customerNama,
    this.barberNama,
    this.serviceNama,
    this.barberFoto,
    this.hasRated = false,

    this.rejectReason,

    this.confirmedAt,
    this.processingAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      barberId: data['barberId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      tanggal: (data['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
      jam: data['jam'] ?? '',
      status: data['status'] ?? 'pending',
      catatan: data['catatan'],
      totalHarga: data['totalHarga'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      customerNama: data['customerNama'],
      barberNama: data['barberNama'],
      serviceNama: data['serviceNama'],
      barberFoto: data['barberFoto'],
      hasRated: data['hasRated'] ?? false,

      rejectReason: data['rejectReason'],

      confirmedAt:
          (data['confirmedAt'] as Timestamp?)?.toDate(),

      processingAt:
          (data['processingAt'] as Timestamp?)?.toDate(),

      completedAt:
          (data['completedAt'] as Timestamp?)?.toDate(),

      cancelledAt:
          (data['cancelledAt'] as Timestamp?)?.toDate(),
    );
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      barberId: json['barberId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      tanggal: json['tanggal'] is Timestamp
          ? (json['tanggal'] as Timestamp).toDate()
          : DateTime.now(),
      jam: json['jam'] ?? '',
      status: json['status'] ?? 'pending',
      catatan: json['catatan'],
      totalHarga: json['totalHarga'] ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      customerNama: json['customerNama'],
      barberNama: json['barberNama'],
      serviceNama: json['serviceNama'],
      barberFoto: json['barberFoto'],
      hasRated: json['hasRated'] ?? false,

      rejectReason: json['rejectReason'],

      confirmedAt: json['confirmedAt'] is Timestamp
          ? (json['confirmedAt'] as Timestamp).toDate()
          : null,

      processingAt: json['processingAt'] is Timestamp
          ? (json['processingAt'] as Timestamp).toDate()
          : null,

      completedAt: json['completedAt'] is Timestamp
          ? (json['completedAt'] as Timestamp).toDate()
          : null,

      cancelledAt: json['cancelledAt'] is Timestamp
          ? (json['cancelledAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'barberId': barberId,
      'serviceId': serviceId,
      'tanggal': Timestamp.fromDate(tanggal),
      'jam': jam,
      'status': status,
      'catatan': catatan,
      'totalHarga': totalHarga,
      'createdAt': Timestamp.fromDate(createdAt),
      'customerNama': customerNama,
      'barberNama': barberNama,
      'serviceNama': serviceNama,
      'barberFoto': barberFoto,
      'hasRated': hasRated,

      'rejectReason': rejectReason,

      'confirmedAt': confirmedAt == null
          ? null
          : Timestamp.fromDate(confirmedAt!),

      'processingAt': processingAt == null
          ? null
          : Timestamp.fromDate(processingAt!),

      'completedAt': completedAt == null
          ? null
          : Timestamp.fromDate(completedAt!),

      'cancelledAt': cancelledAt == null
          ? null
          : Timestamp.fromDate(cancelledAt!),
    };
  }

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? barberId,
    String? serviceId,
    DateTime? tanggal,
    String? jam,
    String? status,
    String? catatan,
    int? totalHarga,
    DateTime? createdAt,
    String? customerNama,
    String? barberNama,
    String? serviceNama,
    String? barberFoto,
    bool? hasRated,

    String? rejectReason,

    DateTime? confirmedAt,
    DateTime? processingAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      barberId: barberId ?? this.barberId,
      serviceId: serviceId ?? this.serviceId,
      tanggal: tanggal ?? this.tanggal,
      jam: jam ?? this.jam,
      status: status ?? this.status,
      catatan: catatan ?? this.catatan,
      totalHarga: totalHarga ?? this.totalHarga,
      createdAt: createdAt ?? this.createdAt,
      customerNama: customerNama ?? this.customerNama,
      barberNama: barberNama ?? this.barberNama,
      serviceNama: serviceNama ?? this.serviceNama,
      barberFoto: barberFoto ?? this.barberFoto,
      hasRated: hasRated ?? this.hasRated,

      rejectReason:
          rejectReason ?? this.rejectReason,

      confirmedAt:
          confirmedAt ?? this.confirmedAt,

      processingAt:
          processingAt ?? this.processingAt,

      completedAt:
          completedAt ?? this.completedAt,

      cancelledAt:
          cancelledAt ?? this.cancelledAt,
    );
  }
}
