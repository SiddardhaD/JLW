import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_models.dart';
import '../models/order_action_models.dart';
import '../models/order_lines_api_models.dart';
import '../models/orders_api_models.dart';
import 'api_config.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
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

    final response = await _client.post(
      Uri.parse(ApiConfig.ordersUrl),
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        'token': token,
        'deviceName': 'Android',
        'Flag': flag
      }),
    );

    final payload = _safeDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return OrdersResponse.fromJson(payload);
    }

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
    final response = await _client.post(
      Uri.parse(ApiConfig.waitingPurchaseOrderLineDetailsUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'token': token,
        'deviceName': 'Android',
        'OrderNumber': orderNumber,
        'OrderCo': orderCo,
        'OrTy': orderType,
      }),
    );

    final payload = _safeDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return WaitingPurchaseOrderLineDetailsResponse.fromJson(payload);
    }

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
  }) async {
    final response = await _client.post(
      Uri.parse(ApiConfig.purchaseOrderApproveUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'token': token,
        'deviceName': 'Android',
        'OrderNumber': orderNumber,
        'OrderCo': orderCo,
        'OrTy': orderType,
      }),
    );

    final payload = _safeDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return PurchaseOrderApproveResponse.fromJson(payload);
    }

    throw ApiException(
      payload['message']?.toString() ?? 'Failed to approve order.',
    );
  }

  Future<PurchaseOrderRejectResponse> rejectOrder({
    required String token,
    required int orderNumber,
    required String orderCo,
    required String orderType,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiConfig.purchaseOrderRejectUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'token': token,
        'deviceName': 'Android',
        'OrderNumber': orderNumber,
        'OrderCo': orderCo,
        'OrTy': orderType,
      }),
    );

    final payload = _safeDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return PurchaseOrderRejectResponse.fromJson(payload);
    }

    throw ApiException(
      payload['message']?.toString() ?? 'Failed to reject order.',
    );
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
