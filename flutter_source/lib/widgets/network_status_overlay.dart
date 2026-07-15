import 'dart:async';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/connectivity_service.dart';

/// Wraps the whole app (via `MaterialApp.builder`) with a slim top banner
/// that appears over whatever screen is active — no internet while offline,
/// then a brief "Back Online" flash for a couple of seconds on reconnect.
class NetworkStatusOverlay extends StatefulWidget {
  final Widget child;

  const NetworkStatusOverlay({super.key, required this.child});

  @override
  State<NetworkStatusOverlay> createState() => _NetworkStatusOverlayState();
}

class _NetworkStatusOverlayState extends State<NetworkStatusOverlay> {
  final ConnectivityService _service = ConnectivityService();
  StreamSubscription<NetworkStatus>? _subscription;
  Timer? _hideReconnectedTimer;

  NetworkStatus _status = NetworkStatus.online;
  bool _showReconnectedBanner = false;

  @override
  void initState() {
    super.initState();
    _service.start();
    _subscription = _service.onStatusChange.listen(_handleStatusChange);
  }

  void _handleStatusChange(NetworkStatus status) {
    if (!mounted) return;
    final wasOffline = _status == NetworkStatus.offline;

    setState(() => _status = status);

    if (status == NetworkStatus.online && wasOffline) {
      _hideReconnectedTimer?.cancel();
      setState(() => _showReconnectedBanner = true);
      _hideReconnectedTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showReconnectedBanner = false);
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _hideReconnectedTimer?.cancel();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = _status == NetworkStatus.offline;
    final showBanner = isOffline || _showReconnectedBanner;

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              offset: showBanner ? Offset.zero : const Offset(0, -1.5),
              child: _buildBanner(isOffline),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBanner(bool isOffline) {
    return Container(
      width: double.infinity,
      color: isOffline ? JLWColors.buttonReject : JLWColors.mintAccent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOffline ? Icons.wifi_off : Icons.wifi,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            isOffline ? 'No Internet Connection' : 'Back Online',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
