import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/banner_model.dart';
import '../services/banner_service.dart';

/// Singleton Banner Service
final bannerServiceProvider = Provider<BannerService>((ref) {
  return BannerService();
});

/// Customer -> hanya banner aktif
final activeBannersProvider =
    StreamProvider<List<BannerModel>>((ref) {
  final service = ref.watch(bannerServiceProvider);
  return service.getActiveBanners();
});

/// Admin -> semua banner
final allBannersProvider =
    StreamProvider<List<BannerModel>>((ref) {
  final service = ref.watch(bannerServiceProvider);
  return service.getAllBanners();
});

/// Detail banner berdasarkan ID
final bannerByIdProvider =
    FutureProvider.family<BannerModel?, String>((ref, bannerId) {
  final service = ref.watch(bannerServiceProvider);
  return service.getBannerById(bannerId);
});