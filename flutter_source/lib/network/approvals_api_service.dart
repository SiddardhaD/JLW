import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_models.dart';
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

  Future<OrdersResponse> fetchOrders({String? token}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await _client.post(
      Uri.parse(ApiConfig.ordersUrl),
      headers: headers,
      body: jsonEncode(<String, dynamic>{}),
    );

    final payload = _safeDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return OrdersResponse.fromJson(payload);
    }

    throw ApiException(
      payload['message']?.toString() ?? 'Failed to fetch orders.',
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
