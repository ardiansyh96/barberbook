import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/service_service.dart';
import '../models/service_model.dart';

/// Provider for service service singleton
final serviceServiceProvider = Provider<ServiceService>((ref) => ServiceService());

/// Provider that streams active services for customer view
final activeServicesProvider = StreamProvider<List<ServiceModel>>((ref) {
  final service = ref.watch(serviceServiceProvider);
  return service.getActiveServices();
});

/// Provider that streams all services for admin view
final allServicesProvider = StreamProvider<List<ServiceModel>>((ref) {
  final service = ref.watch(serviceServiceProvider);
  return service.getAllServices();
});

/// Provider to fetch a single service by ID
final serviceByIdProvider = FutureProvider.family<ServiceModel?, String>((ref, id) {
  final service = ref.watch(serviceServiceProvider);
  return service.getServiceById(id);
});

/// Provider to get services by category
final servicesByCategoryProvider = StreamProvider.family<List<ServiceModel>, String>((ref, category) {
  final service = ref.watch(serviceServiceProvider);
  return service.getServicesByCategory(category);
});

final searchServicesProvider =
    StreamProvider.family<List<ServiceModel>, String>((ref, keyword) {

  final service =
      ref.watch(serviceServiceProvider);

  return service.searchServices(keyword);

});

final servicesFutureProvider =
    FutureProvider<List<ServiceModel>>((ref) {

  return ref
      .watch(serviceServiceProvider)
      .fetchAllServices();

});

final totalServicesProvider =
    FutureProvider<int>((ref) {

  return ref
      .watch(serviceServiceProvider)
      .totalServices();

});

final totalActiveServicesProvider =
    FutureProvider<int>((ref) {

  return ref
      .watch(serviceServiceProvider)
      .totalActiveServices();

});


