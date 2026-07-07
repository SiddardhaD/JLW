import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  static const AndroidId _androidId = AndroidId();
  static final DeviceInfoPlugin _devicePlugin = DeviceInfoPlugin();
  static String? _cachedDeviceId;

  static Future<String> getDeviceId() async {
    final cached = _cachedDeviceId;
    if (cached != null) return cached;

    String deviceId = 'unknown';
    try {
      if (Platform.isAndroid) {
        deviceId = await _androidId.getId() ?? 'unknown';
      } else if (Platform.isIOS) {
        final info = await _devicePlugin.iosInfo;
        deviceId = info.identifierForVendor ?? 'unknown';
      }
    } catch (_) {
      deviceId = 'unknown';
    }

    _cachedDeviceId = deviceId;
    return deviceId;
  }
}
