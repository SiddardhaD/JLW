import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Saves downloaded documents to local device storage - the public Downloads
/// folder on Android, the app's Documents directory on iOS - and shows a
/// "download complete" notification that reopens the file when tapped.
class DownloadService {
  static const MethodChannel _channel =
      MethodChannel('jlw_approvals/downloads');
  static const String _channelId = 'downloads_channel';

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _notifications.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _openSavedFile(payload);
        }
      },
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Saves [bytes] as [fileName] (including extension) and returns a URI/path
  /// that [_openSavedFile] can reopen later.
  static Future<String> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    if (Platform.isAndroid) {
      final saved = await _channel.invokeMethod<String>('saveToDownloads', {
        'fileName': fileName,
        'mimeType': mimeType,
        'bytes': bytes,
      });
      if (saved == null || saved.isEmpty) {
        throw const FormatException('Unable to save file to Downloads.');
      }
      return saved;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Shows a tappable notification confirming [fileName] finished downloading.
  static Future<void> notifyDownloadComplete({
    required String fileName,
    required String savedLocation,
    required String mimeType,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Downloads',
      channelDescription: 'Notifies when a document finishes downloading',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      id: savedLocation.hashCode,
      title: 'Download complete',
      body: '$fileName saved. Tap to open.',
      notificationDetails: details,
      payload: '$mimeType|$savedLocation',
    );
  }

  static Future<void> _openSavedFile(String payload) async {
    final separatorIndex = payload.indexOf('|');
    if (separatorIndex == -1) return;
    final mimeType = payload.substring(0, separatorIndex);
    final location = payload.substring(separatorIndex + 1);

    if (Platform.isAndroid) {
      await _channel.invokeMethod('openFile', {
        'uri': location,
        'mimeType': mimeType,
      });
      return;
    }

    await OpenFilex.open(location);
  }
}
