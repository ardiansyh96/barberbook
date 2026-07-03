import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_collections.dart';

class AdminStats {
  final int totalCustomers;
  final int totalAdmins;
  final int totalBarbers;
  final int totalServices;
  final int totalBookings;

  final int todayBookings;
  final int pendingBookings;
  final int confirmedBookings;
  final int processingBookings;
  final int completedBookings;
  final int cancelledBookings;
  final int rejectedBookings;

  final int activeBarbers;
  final int totalRevenue;

  final List<QueryDocumentSnapshot> recentBookings;

  const AdminStats({
    required this.totalCustomers,
    required this.totalAdmins,
    required this.totalBarbers,
    required this.totalServices,
    required this.totalBookings,
    required this.todayBookings,
    required this.pendingBookings,
    required this.confirmedBookings,
    required this.processingBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.rejectedBookings,
    required this.activeBarbers,
    required this.totalRevenue,
    required this.recentBookings,
  });
}

class AdminDashboardService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference get bookings =>
      _firestore.collection(FirebaseCollections.bookings);

  CollectionReference get users =>
      _firestore.collection(FirebaseCollections.users);

  CollectionReference get barbers =>
      _firestore.collection(FirebaseCollections.barbers);

  CollectionReference get services =>
      _firestore.collection(FirebaseCollections.services);

  Future<int> totalBooking() async {
    final data = await bookings.count().get();
    return data.count ?? 0;
  }

  Future<int> totalCustomer() async {
    final data = await users
        .where("role", isEqualTo: "customer")
        .count()
        .get();

    return data.count ?? 0;
  }

  Future<int> totalAdmin() async {
    final data = await users
        .where("role", isEqualTo: "admin")
        .count()
        .get();

    return data.count ?? 0;
  }

  Future<int> totalBarber() async {
    final data = await barbers.count().get();
    return data.count ?? 0;
  }

  Future<int> totalService() async {
    final data = await services.count().get();
    return data.count ?? 0;
  }

  Future<int> totalPending() async {
    final data = await bookings
        .where("status", isEqualTo: "pending")
        .count()
        .get();

    return data.count ?? 0;
  }

  Future<int> totalConfirmed() async {
    final data = await bookings
        .where("status", isEqualTo: "confirmed")
        .count()
        .get();

    return data.count ?? 0;
  }

  Future<int> totalProcessing() async {
    final data = await bookings
        .where("status", isEqualTo: "processing")
        .count()
        .get();

    return data.count ?? 0;
  }

  Future<int> totalCompleted() async {
    final data = await bookings
        .where("status", isEqualTo: "completed")
        .count()
        .get();

    return data.count ?? 0;
  }

  Future<int> totalCancelled() async {
    final data = await bookings
        .where("status", isEqualTo: "cancelled")
        .count()
        .get();

    return data.count ?? 0;
  }

  Future<int> totalRejected() async {
    final data = await bookings
        .where("status", isEqualTo: "rejected")
        .count()
        .get();

    return data.count ?? 0;
  }

  Future<int> todayBookings() async {
  final now = DateTime.now();

  final start = DateTime(
    now.year,
    now.month,
    now.day,
  );

  final end = start.add(const Duration(days: 1));

  final data = await bookings
      .where(
        "createdAt",
        isGreaterThanOrEqualTo: Timestamp.fromDate(start),
      )
      .where(
        "createdAt",
        isLessThan: Timestamp.fromDate(end),
      )
      .count()
      .get();

  return data.count ?? 0;
}

Future<int> activeBarbers() async {
  final data = await barbers
      .where(
        "statusAktif",
        isEqualTo: true,
      )
      .count()
      .get();

  return data.count ?? 0;
}

Future<int> totalRevenue() async {
  final snapshot = await bookings
      .where(
        "status",
        whereIn: [
          "completed",
          "confirmed",
          "processing",
        ],
      )
      .get();

  int total = 0;

  for (final doc in snapshot.docs) {
    total += (doc["totalHarga"] ?? 0) as int;
  }

  return total;
}

  Future<List<QueryDocumentSnapshot>> recentBookings() async {
    final snapshot = await bookings
        .orderBy(
          "createdAt",
          descending: true,
        )
        .limit(5)
        .get();

    return snapshot.docs;
  }

  Future<AdminStats> fetchStats() async {

    final result = await Future.wait([

      totalCustomer(),
      totalAdmin(),
      totalBarber(),
      totalService(),
      totalBooking(),

      todayBookings(),

      totalPending(),
      totalConfirmed(),
      totalProcessing(),
      totalCompleted(),
      totalCancelled(),
      totalRejected(),

      activeBarbers(),
      totalRevenue(),

      recentBookings(),

    ]);

    return AdminStats(

      totalCustomers: result[0] as int,
      totalAdmins: result[1] as int,
      totalBarbers: result[2] as int,
      totalServices: result[3] as int,
      totalBookings: result[4] as int,

      todayBookings: result[5] as int,

      pendingBookings: result[6] as int,
      confirmedBookings: result[7] as int,
      processingBookings: result[8] as int,
      completedBookings: result[9] as int,
      cancelledBookings: result[10] as int,
      rejectedBookings: result[11] as int,

      activeBarbers: result[12] as int,
      totalRevenue: result[13] as int,

      recentBookings:
          result[14] as List<QueryDocumentSnapshot>,

    );

  }
  }