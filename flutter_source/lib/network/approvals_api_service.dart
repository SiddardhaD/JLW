import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/approval_flow.dart';
import '../models/auth_models.dart';
import '../models/order_action_models.dart';
import '../models/order_lines_api_models.dart';
import '../models/orders_api_models.dart';
import '../models/responsible_person_models.dart';
import '../services/device_info_service.dart';
import 'api_config.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class SessionExpiredException extends ApiException {
  const SessionExpiredException()
      : super('Session expired. Please login again.');
}

class ApprovalsApiService {
  final http.Client _client;

  ApprovalsApiService({http.Client? client})
      : _client = client ?? http.Client();

  Future<LoginSuccessResponse> login(LoginRequest request) async {
    final response = await _client.post(
      Uri.parse(ApiConfig.loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    final payload = _safeDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return LoginSuccessResponse.fromJson(payload);
    }

    final failure = LoginFailureResponse.fromJson(payload);
    throw ApiException(failure.message);
  }

  Future<OrdersResponse> fetchOrders({String? token, String? flag}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final deviceId = await DeviceInfoService.getDeviceId();

    final response = await _client.post(
      Uri.parse(ApiConfig.ordersUrl),
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        'token': token,
        'deviceName': deviceId,
      }),
    );

    final payload = _safeDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return OrdersResponse.fromJson(payload);
    }
    if (response.statusCode == 401) throw const SessionExpiredException();
    throw ApiException(
      payload['message']?.toString() ?? 'Failed to fetch orders.',
    );
  }

  Future<WaitingPurchaseOrderLineDetailsResponse>
      fetchWaitingPurchaseOrderLineDetails({
    required String token,
    required int orderNumber,
    required String orderCo,
    required String orderType,
  }) async {
    final deviceId = await DeviceInfoService.getDeviceId();
    final response = await _client.post(
      Uri.parse(ApiConfig.waitingPurchaseOrderLineDetailsUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'token': token,
        'deviceName': deviceId,
        'OrderNumber': orderNumber,
        'OrderCo': orderCo,
        'OrTy': orderType,
      }),
    );

    final payload = _safeDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return WaitingPurchaseOrderLineDetailsResponse.fromJson(payload);
    }
    if (response.statusCode == 401) throw const SessionExpiredException();
    throw ApiException(
      payload['message']?.toString() ??
          'Failed to fetch waiting purchase order line details.',
    );
  }

  Future<PurchaseOrderApproveResponse> approveOrder({
    required String token,
    required int orderNumber,
    required String orderCo,
    required String orderType,
    ApprovalFlow flow = ApprovalFlow.purchaseOrder,
  }) async {
    final deviceId = await DeviceInfoService.getDeviceId();
    final url = flow == ApprovalFlow.purchaseRequisition
        ? ApiConfig.purchaseOrderRequisitionApproveUrl
        : ApiConfig.purchaseOrderApproveUrl;
    final response = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'token': token,
        'deviceName': deviceId,
        'OrderNumber': orderNumber,
        'OrderCo': orderCo,
        'OrTy': orderType,
      }),
    );

    final payload = _safeDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return PurchaseOrderApproveResponse.fromJson(payload);
    }
    if (response.statusCode == 401) throw const SessionExpiredException();
    throw ApiException(
      payload['message']?.toString() ?? 'Failed to approve order.',
    );
  }

  Future<PurchaseOrderRejectResponse> rejectOrder({
    required String token,
    required int orderNumber,
    required String orderCo,
    required String orderType,
    ApprovalFlow flow = ApprovalFlow.purchaseOrder,
    String? note,
  }) async {
    final deviceId = await DeviceInfoService.getDeviceId();
    final url = flow == ApprovalFlow.purchaseRequisition
        ? ApiConfig.purchaseOrderRequisitionRejectUrl
        : ApiConfig.purchaseOrderRejectUrl;
    final response = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'token': token,
        'deviceName': deviceId,
        'OrderNumber': orderNumber,
        'OrderCo': orderCo,
        'OrTy': orderType,
        'Note': note ?? '',
      }),
    );

    final payload = _safeDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return PurchaseOrderRejectResponse.fromJson(payload);
    }
    if (response.statusCode == 401) throw const SessionExpiredException();
    throw ApiException(
      payload['message']?.toString() ?? 'Failed to reject order.',
    );
  }

  Future<void> logoutUser({required String token}) async {
    try {
      final deviceId = await DeviceInfoService.getDeviceId();
      await _client.post(
        Uri.parse(ApiConfig.logoutUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'deviceName': deviceId,
          'token': token,
        }),
      );
    } catch (_) {
      // API failure must not block local logout.
    }
  }

  /// Returns the sequence number of every media object attached to the order.
  /// The API reports how many media items exist; each one must be downloaded
  /// individually via [downloadMediaObject].
  Future<List<int>> fetchMediaObjectSequences({
    required String token,
    required String orderNumber,
    required String orderCo,
    required String orderType,
  }) async {
    final deviceId = await DeviceInfoService.getDeviceId();
    final response = await _client.post(
      Uri.parse(ApiConfig.mediaObjectRetrievalUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        "token": token,
        "deviceName": deviceId,
        "OrderNumber": orderNumber,
        "OrderCompany": orderCo,
        "OrderType ": orderType,
        "OrderSuffix ": "000"
      }),
    );

    final payload = _safeDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final objects = payload['mediaObjects'] as List?;
      if (objects != null) {
        return objects
            .whereType<Map<String, dynamic>>()
            .map((o) => o['sequence'] as int?)
            .whereType<int>()
            .toList();
      }
    }
    return const [];
  }

  Future<Uint8List?> downloadMediaObject({
    required String token,
    required String orderNumber,
    required String orderCo,
    required String orderType,
    required String sequence,
  }) async {
    final deviceId = await DeviceInfoService.getDeviceId();
    final response = await _client.post(
      Uri.parse(ApiConfig.mediaObjectDownloadUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/octet-stream',
      },
      body: jsonEncode(<String, dynamic>{
        'token': token,
        "deviceName": deviceId,
        "Company": orderCo,
        "OrderType": orderType,
        "OrderSuffix": "000",
        "OrderNo": orderNumber,
        "Sequence": sequence,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final bytes = response.bodyBytes;
      final body = response.body.trim();

      // Case 1: raw binary PDF (%PDF- magic bytes)
      if (bytes.length > 4 &&
          bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46) {
        return bytes;
      }

      // Case 2: plain base64 PDF as response body (what JDE actually returns).
      // "JVBERi0x" is the base64 encoding of "%PDF-1".
      if (body.startsWith('JVBERi0x')) {
        return base64Decode(body.replaceAll(RegExp(r'\s'), ''));
      }

      // Case 3: base64 PDF embedded inside a JSON field.
      try {
        final payload = _safeDecode(body);
        final base64Str = _findBase64Pdf(payload);
        if (base64Str != null) {
          return base64Decode(base64Str.replaceAll(RegExp(r'\s'), ''));
        }
      } catch (_) {
        debugPrint('Failed to decode PDF from response body: ${_.toString()}');
      }
    }
    return null;
  }

  Future<ResponsiblePersonsResponse> fetchResponsiblePersons({
    required String token,
    required int orderNumber,
    required String orderCo,
    required String orderType,
  }) async {
    final deviceId = await DeviceInfoService.getDeviceId();
    final response = await _client.post(
      Uri.parse(ApiConfig.responsiblePersonUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'token': token,
        'deviceName': deviceId,
        'OrderNumber': orderNumber,
        'OrderCo': orderCo,
        'OrTy': orderType,
      }),
    );

    final payload = _safeDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ResponsiblePersonsResponse.fromJson(payload);
    }
    if (response.statusCode == 401) throw const SessionExpiredException();
    throw ApiException(
      payload['message']?.toString() ?? 'Failed to fetch responsible persons.',
    );
  }

  String? _findBase64Pdf(Map<String, dynamic> json) {
    for (final value in json.values) {
      if (value is String && value.startsWith('JVBERi0x')) {
        return value;
      }
      if (value is Map<String, dynamic>) {
        final found = _findBase64Pdf(value);
        if (found != null) return found;
      }
    }
    return null;
  }

  Map<String, dynamic> _safeDecode(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{};
  }
}
