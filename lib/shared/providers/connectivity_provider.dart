import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Provider that monitors network connectivity status.
///
/// Returns true when the device has an active internet connection,
/// false when offline. Used by screens to show appropriate
/// offline/online states.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => !results.contains(ConnectivityResult.none),
  );
});
