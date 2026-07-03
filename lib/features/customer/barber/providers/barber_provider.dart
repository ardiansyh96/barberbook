import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/barber_service.dart';
import '../models/barber_model.dart';

/// Provider for barber service singleton
final barberServiceProvider = Provider<BarberService>((ref) => BarberService());

/// Provider that streams active barbers for customer view
final activeBarbersProvider = StreamProvider<List<BarberModel>>((ref) {
  final service = ref.watch(barberServiceProvider);
  return service.getActiveBarbers();
});

/// Provider that streams all barbers for admin view
final allBarbersProvider = StreamProvider<List<BarberModel>>((ref) {
  final service = ref.watch(barberServiceProvider);
  return service.getAllBarbers();
});

/// Provider to fetch a single barber by ID
final barberByIdProvider = FutureProvider.family<BarberModel?, String>((ref, id) {
  final service = ref.watch(barberServiceProvider);
  return service.getBarberById(id);
});

/// Provider for barber search with query
final barberSearchProvider = StreamProvider.family<List<BarberModel>, String>((ref, query) {
  final service = ref.watch(barberServiceProvider);
  return service.searchBarbers(query);
});
