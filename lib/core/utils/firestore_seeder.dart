import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../features/customer/barber/models/barber_model.dart';
import '../../features/customer/service/models/service_model.dart';
import '../../features/admin/banner_mgmt/models/banner_model.dart';
import '../../features/customer/rating/models/review_model.dart';
import '../../core/constants/firebase_collections.dart';


class FirestoreSeeder {
  static final FirebaseFirestore _firestore = 
    FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
    FirebaseAuth.instance;

  /// Main seeding function
  static Future<SeedResult> seed() async {
    try {
      debugPrint('[Seeder] 🌱 Starting Firestore seeder...');

      final result = SeedResult();

      await _seedAdmin();

      // Seed Barbers
      debugPrint('[Seeder] 👥 Seeding barbers...');
      result.barberCount = await _seedBarbers();

      // Seed Services
      debugPrint('[Seeder] ✂️ Seeding services...');
      result.serviceCount = await _seedServices();

      // Seed Banners
      debugPrint('[Seeder] 🖼️ Seeding banners...');
      result.bannerCount = await _seedBanners();

      // Seed Reviews
      debugPrint('[Seeder] ⭐ Seeding reviews...');
      result.reviewCount = await _seedReviews();

      debugPrint('[Seeder] ✅ Seeding completed successfully!');
      debugPrint('[Seeder]   - Barbers: ${result.barberCount}');
      debugPrint('[Seeder]   - Services: ${result.serviceCount}');
      debugPrint('[Seeder]   - Banners: ${result.bannerCount}');
      debugPrint('[Seeder]   - Reviews: ${result.reviewCount}');

      result.success = true;
      result.message = 'Seeder completed successfully!';
      return result;
    } catch (e) {
      debugPrint('[Seeder] ❌ Seeder failed: $e');
      return SeedResult(
        success: false,
        message: 'Seeder failed: $e',
      );
    }
  }


  /// Seed 5 barbers with realistic data
  static Future<int> _seedBarbers() async {
    final collection = _firestore.collection(FirebaseCollections.barbers);
    final snapshot = await collection.limit(1).get();

    // Skip if data already exists
    if (snapshot.docs.isNotEmpty) {
      debugPrint('[Seeder] ⏭️ Barbers already exist, skipping...');
      return snapshot.docs.length;
    }

    final barbers = [
      BarberModel(
        id: '',
        nama: 'Andi Pratama',
        spesialis: 'Classic Cuts & Fades',
        pengalaman: 8,
        foto: null,
        rating: 4.8,
        statusAktif: true,
        jamMasuk: '09:00',
        jamPulang: '21:00',
        totalReviews: 124,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      BarberModel(
        id: '',
        nama: 'Budi Santoso',
        spesialis: 'Modern Styles & Beard Design',
        pengalaman: 6,
        foto: null,
        rating: 4.9,
        statusAktif: true,
        jamMasuk: '10:00',
        jamPulang: '20:00',
        totalReviews: 98,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
      ),
      BarberModel(
        id: '',
        nama: 'Cahya Wijaya',
        spesialis: 'Hair Coloring & Treatment',
        pengalaman: 10,
        foto: null,
        rating: 4.7,
        statusAktif: true,
        jamMasuk: '09:00',
        jamPulang: '19:00',
        totalReviews: 156,
        createdAt: DateTime.now().subtract(const Duration(days: 400)),
      ),
      BarberModel(
        id: '',
        nama: 'Dimas Kurniawan',
        spesialis: 'Premium Grooming & Spa',
        pengalaman: 5,
        foto: null,
        rating: 4.6,
        statusAktif: true,
        jamMasuk: '11:00',
        jamPulang: '21:00',
        totalReviews: 67,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      BarberModel(
        id: '',
        nama: 'Eko Prasetyo',
        spesialis: 'Kids & Family Cuts',
        pengalaman: 7,
        foto: null,
        rating: 4.8,
        statusAktif: true,
        jamMasuk: '09:00',
        jamPulang: '18:00',
        totalReviews: 89,
        createdAt: DateTime.now().subtract(const Duration(days: 250)),
      ),
    ];

    int count = 0;
    for (final barber in barbers) {
      await collection.add(barber.toJson());
      count++;
    }

    debugPrint('[Seeder] ✅ Created $count barbers');
    return count;
  }

  /// Seed 10 services with realistic data
  static Future<int> _seedServices() async {
    final collection = _firestore.collection(FirebaseCollections.services);
    final snapshot = await collection.limit(1).get();

    // Skip if data already exists
    if (snapshot.docs.isNotEmpty) {
      debugPrint('[Seeder] ⏭️ Services already exist, skipping...');
      return snapshot.docs.length;
    }

    final services = [
      ServiceModel(
        id: '',
        nama: 'Classic Haircut',
        harga: 50000,
        durasi: 30,
        gambar: null,
        deskripsi: 'Traditional haircut with precision cutting technique',
        aktif: true,
        kategori: 'Haircuts',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      ServiceModel(
        id: '',
        nama: 'Fade & Taper',
        harga: 65000,
        durasi: 45,
        gambar: null,
        deskripsi: 'Modern fade haircut with smooth gradient blending',
        aktif: true,
        kategori: 'Haircuts',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      ServiceModel(
        id: '',
        nama: 'Beard Trim & Shape',
        harga: 35000,
        durasi: 20,
        gambar: null,
        deskripsi: 'Professional beard grooming and styling',
        aktif: true,
        kategori: 'Beard',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      ServiceModel(
        id: '',
        nama: 'Hair Coloring',
        harga: 150000,
        durasi: 90,
        gambar: null,
        deskripsi: 'Premium hair coloring with quality products',
        aktif: true,
        kategori: 'Coloring',
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
      ),
      ServiceModel(
        id: '',
        nama: 'Hair Highlighting',
        harga: 180000,
        durasi: 120,
        gambar: null,
        deskripsi: 'Professional highlighting for modern look',
        aktif: true,
        kategori: 'Coloring',
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
      ),
      ServiceModel(
        id: '',
        nama: 'Facial Treatment',
        harga: 85000,
        durasi: 45,
        gambar: null,
        deskripsi: 'Deep cleansing facial with moisturizing treatment',
        aktif: true,
        kategori: 'Facial',
        createdAt: DateTime.now().subtract(const Duration(days: 250)),
      ),
      ServiceModel(
        id: '',
        nama: 'Hair Spa & Massage',
        harga: 120000,
        durasi: 60,
        gambar: null,
        deskripsi: 'Relaxing hair spa with scalp massage therapy',
        aktif: true,
        kategori: 'Spa',
        createdAt: DateTime.now().subtract(const Duration(days: 250)),
      ),
      ServiceModel(
        id: '',
        nama: 'Kids Haircut',
        harga: 40000,
        durasi: 25,
        gambar: null,
        deskripsi: 'Gentle haircut service for children under 12',
        aktif: true,
        kategori: 'Haircuts',
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      ServiceModel(
        id: '',
        nama: 'Premium Shave',
        harga: 55000,
        durasi: 30,
        gambar: null,
        deskripsi: 'Traditional hot towel shave with premium products',
        aktif: true,
        kategori: 'Beard',
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      ServiceModel(
        id: '',
        nama: 'Complete Grooming Package',
        harga: 200000,
        durasi: 120,
        gambar: null,
        deskripsi: 'Full service: haircut, beard trim, facial, and spa',
        aktif: true,
        kategori: 'Package',
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
      ),
    ];

    int count = 0;
    for (final service in services) {
      await collection.add(service.toJson());
      count++;
    }

    debugPrint('[Seeder] ✅ Created $count services');
    return count;
  }

  /// Seed 3 promotional banners
  static Future<int> _seedBanners() async {
    final collection = _firestore.collection(FirebaseCollections.banners);
    final snapshot = await collection.limit(1).get();

    // Skip if data already exists
    if (snapshot.docs.isNotEmpty) {
      debugPrint('[Seeder] ⏭️ Banners already exist, skipping...');
      return snapshot.docs.length;
    }

    final banners = [
      BannerModel(
        id: '',
        gambar: 'https://images.unsplash.com/photo-1585747860019-8e8ef578c8c9?w=800',
        judul: 'Grand Opening Promo - 20% OFF',
        aktif: true,
        deskripsi: 'Get 20% discount on all services this month!',
        linkTarget: '/customer/booking/create',
        urutan: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      BannerModel(
        id: '',
        gambar: 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=800',
        judul: 'New Premium Grooming Package',
        aktif: true,
        deskripsi: 'Try our complete grooming experience',
        linkTarget: '/customer/booking/create',
        urutan: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      BannerModel(
        id: '',
        gambar: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800',
        judul: 'Weekend Special - Free Beard Trim',
        aktif: true,
        deskripsi: 'Free beard trim with every haircut on weekends',
        linkTarget: '/customer/booking/create',
        urutan: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    int count = 0;
    for (final banner in banners) {
      await collection.add(banner.toJson());
      count++;
    }

    debugPrint('[Seeder] ✅ Created $count banners');
    return count;
  }

  /// Seed 5 customer reviews
  static Future<int> _seedReviews() async {
    final collection = _firestore.collection(FirebaseCollections.reviews);
    final snapshot = await collection.limit(1).get();

    // Skip if data already exists
    if (snapshot.docs.isNotEmpty) {
      debugPrint('[Seeder] ⏭️ Reviews already exist, skipping...');
      return snapshot.docs.length;
    }

    // First, get barber IDs
    final barbersSnapshot = await _firestore
        .collection(FirebaseCollections.barbers)
        .limit(5)
        .get();

    if (barbersSnapshot.docs.isEmpty) {
      debugPrint('[Seeder] ⚠️ No barbers found, skipping reviews...');
      return 0;
    }

    final barberIds = barbersSnapshot.docs.map((doc) => doc.id).toList();

    final reviews = [
      ReviewModel(
        id: '',
        bookingId: 'seed_booking_001',
        customerId: 'seed_customer_001',
        barberId: barberIds[0],
        rating: 5,
        komentar: 'Excellent service! Very professional and attention to detail. Highly recommended!',
        customerNama: 'Rizky Ramadhan',
        customerPhoto: null,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ReviewModel(
        id: '',
        bookingId: 'seed_booking_002',
        customerId: 'seed_customer_002',
        barberId: barberIds[1],
        rating: 5,
        komentar: 'Best barber in town! Clean shop and friendly staff. Will definitely come back.',
        customerNama: 'Fajar Hidayat',
        customerPhoto: null,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      ReviewModel(
        id: '',
        bookingId: 'seed_booking_003',
        customerId: 'seed_customer_003',
        barberId: barberIds[2],
        rating: 4,
        komentar: 'Great haircut and coloring service. The result exceeded my expectations!',
        customerNama: 'Sarah Putri',
        customerPhoto: null,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      ReviewModel(
        id: '',
        bookingId: 'seed_booking_004',
        customerId: 'seed_customer_004',
        barberId: barberIds[3],
        rating: 5,
        komentar: 'Amazing facial treatment! Very relaxing and my skin feels so fresh afterward.',
        customerNama: 'Dian Saputra',
        customerPhoto: null,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ReviewModel(
        id: '',
        bookingId: 'seed_booking_005',
        customerId: 'seed_customer_005',
        barberId: barberIds[0],
        rating: 4,
        komentar: 'Good service and reasonable price. The barber was very skilled and friendly.',
        customerNama: 'Hendra Wijaya',
        customerPhoto: null,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];

    int count = 0;
    for (final review in reviews) {
      await collection.add(review.toJson());
      count++;
    }

    debugPrint('[Seeder] ✅ Created $count reviews');
    return count;
  }

  static Future<void> _seedAdmin() async {
    try {
      const email = "admin@barberbook.com";
      const password = "admin123";

      final existing = await _firestore
          .collection(FirebaseCollections.users)
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        debugPrint("[Seeder] Admin already exists");
        return;
      }

      final credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      await _firestore
        .collection(FirebaseCollections.users)
        .doc(uid)
        .set({

      "uid": uid,

      "nama": "Administrator",

      "email": email,

      "nomorHP": "081234567890",

      "photo": null,

      "role": "admin",

      "fcmToken": null,

      "createdAt": Timestamp.now(),

    });

      debugPrint("[Seeder] Admin created");

      await _auth.signOut();
    } catch (e) {
      debugPrint("[Seeder] Admin Error : $e");
    }
  }
}

 class SeedResult{

  bool success;

  String message;

  int barberCount;

  int serviceCount;

  int bannerCount;

  int reviewCount;

  int customerCount;

  int bookingCount;

  int adminCount;

  SeedResult({

    this.success=false,

    this.message="",

    this.barberCount=0,

    this.serviceCount=0,

    this.bannerCount=0,

    this.reviewCount=0,

    this.customerCount=0,

    this.bookingCount=0,

    this.adminCount=0,

  });
 }