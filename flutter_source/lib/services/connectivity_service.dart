import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { online, offline }

/// Watches both the device's network adapter state (via [Connectivity]) and
/// actual internet reachability (a DNS lookup), so a phone connected to Wi-Fi
/// with no real internet is still reported as offline.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<NetworkStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _pollTimer;
  NetworkStatus _lastStatus = NetworkStatus.online;

  Stream<NetworkStatus> get onStatusChange => _controller.stream;
  NetworkStatus get currentStatus => _lastStatus;

  void start() {
    _checkAndEmit();
    _subscription =
        _connectivity.onConnectivityChanged.listen((_) => _checkAndEmit());
    _pollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkAndEmit(),
    );
  }

  Future<void> _checkAndEmit() async {
    final online = await _hasActiveInternet();
    final status = online ? NetworkStatus.online : NetworkStatus.offline;
    if (status != _lastStatus) {
      _lastStatus = status;
      _controller.add(status);
    }
  }

  Future<bool> _hasActiveInternet() async {
    final results = await _connectivity.checkConnectivity();
    if (results.every((r) => r == ConnectivityResult.none)) {
      return false;
    }

    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _pollTimer?.cancel();
    _controller.close();
  }
}
