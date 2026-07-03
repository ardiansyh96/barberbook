import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/models/user_model.dart';
import '../services/customer_service.dart';

/// Singleton Customer Service
final customerServiceProvider =
    Provider<CustomerService>((ref) => CustomerService());

/// Semua customer
final allCustomersProvider =
    StreamProvider<List<UserModel>>((ref) {
  final service = ref.watch(customerServiceProvider);
  return service.getAllCustomers();
});

/// Detail customer
final customerByIdProvider =
    FutureProvider.family<UserModel?, String>((ref, uid) {
  final service = ref.watch(customerServiceProvider);
  return service.getCustomerById(uid);
});

/// Total booking customer
final customerBookingProvider =
    FutureProvider.family<int, String>((ref, uid) {
  final service = ref.watch(customerServiceProvider);
  return service.totalBooking(uid);
});

/// Total booking selesai
final customerFinishedBookingProvider =
    FutureProvider.family<int, String>((ref, uid) {
  final service = ref.watch(customerServiceProvider);
  return service.totalFinishedBooking(uid);
});

/// Total pengeluaran customer
final customerSpentProvider =
    FutureProvider.family<double, String>((ref, uid) {
  final service = ref.watch(customerServiceProvider);
  return service.totalSpent(uid);
});