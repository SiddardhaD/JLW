import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../models/approval_flow.dart';
import '../models/auth_models.dart';
import '../models/order_action_models.dart';
import '../models/order_lines_api_models.dart';
import '../models/order.dart';
import '../models/responsible_person_models.dart';
import '../network/approvals_api_service.dart';
import '../services/device_info_service.dart';
import '../services/secure_storage_service.dart';

/// State Manager for JLW Approvals.
/// Replicates the ApprovalsViewModel used in the Jetpack Compose package.
class ApprovalsProvider extends ChangeNotifier {
  final ApprovalsApiService _apiService = ApprovalsApiService();
  final SecureStorageService _storage = SecureStorageService();

  // Authentication States
  String _username = '';
  String _password = '';
  bool _isAuthenticated = false;
  bool _isLoginLoading = false;
  String? _loginError;
  LoginSuccessResponse? _loginSuccessResponse;
  String? _token;
  bool _sessionExpired = false;
  bool _biometricEnabled = false;
  ApprovalFlow _flow = ApprovalFlow.purchaseOrder;

  String get username => _username;
  String get password => _password;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoginLoading => _isLoginLoading;
  String? get loginError => _loginError;
  LoginSuccessResponse? get loginSuccessResponse => _loginSuccessResponse;
  bool get isSessionExpired => _sessionExpired;
  bool get isBiometricEnabled => _biometricEnabled;
  ApprovalFlow get flow => _flow;

  void setFlow(ApprovalFlow flow) {
    _flow = flow;
    notifyListeners();
  }

  // Search & Filtering States
  String _searchQuery = '';
  String _selectedFilter = 'Queued';
  bool _isOrdersLoading = false;
  String? _ordersError;

  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  bool get isOrdersLoading => _isOrdersLoading;
  String? get ordersError => _ordersError;
  List<OrderModel>? get orders => _orders;

  final List<OrderModel> _orders = [];
  final List<GetWaitingPurchaseOrderLineDetails> _waitingLines = [];
  String _waitingLinesCurrency = '';

  bool _isWaitingLinesLoading = false;
  String? _waitingLinesError;
  bool _isOrderActionLoading = false;
  String? _orderActionError;

  List<GetWaitingPurchaseOrderLineDetails> get waitingLines => _waitingLines;
  String get waitingLinesCurrency => _waitingLinesCurrency;
  bool get isWaitingLinesLoading => _isWaitingLinesLoading;
  String? get waitingLinesError => _waitingLinesError;
  bool get isOrderActionLoading => _isOrderActionLoading;
  String? get orderActionError => _orderActionError;

  // PDF States
  bool _isPdfLoading = false;
  String? _pdfError;
  List<Uint8List> _pdfDocuments = [];

  bool get isPdfLoading => _isPdfLoading;
  String? get pdfError => _pdfError;
  List<Uint8List> get pdfDocuments => _pdfDocuments;

  // Responsible Persons States
  List<ResponsiblePerson> _responsiblePersons = [];
  bool _isResponsiblePersonsLoading = false;
  String? _responsiblePersonsError;

  List<ResponsiblePerson> get responsiblePersons => _responsiblePersons;
  bool get isResponsiblePersonsLoading => _isResponsiblePersonsLoading;
  String? get responsiblePersonsError => _responsiblePersonsError;

  // Seed Line Items matching mockup table cells exactly
  final List<LineItemModel> _lineItems = [
    LineItemModel(
      orderId: "2323135",
      lineNumber: 1,
      itemCode: "210-998-A",
      requestedDate: "10-06-2026",
      description:
          "Precision Grade Structural Steel - Grade 50 / Type 2 Reinforcement Rods",
      quantity: 31.0,
      unit: "KG",
      unitCost: 10.0,
      extendedCost: 310.0,
    ),
    LineItemModel(
      orderId: "2323135",
      lineNumber: 2,
      itemCode: "440-X12",
      requestedDate: "10-06-2026",
      description: "Standard Steel Connectors & Anchor Bolts (Zinc Coated)",
      quantity: 15.0,
      unit: "UNIT",
      unitCost: 8.0,
      extendedCost: 120.0,
    ),
    LineItemModel(
      orderId: "2323135",
      lineNumber: 3,
      itemCode: "EXC-H77",
      requestedDate: "10-06-2026",
      description:
          "Heavy Infrastructure Mechanical Excavation Core Assemblies - Base Contractor Installment",
      quantity: 1.0,
      unit: "LOT",
      unitCost: 20001772.0,
      extendedCost: 20001772.0,
    ),
    LineItemModel(
      orderId: "2323136",
      lineNumber: 1,
      itemCode: "610-LOG-B",
      requestedDate: "10-06-2026",
      description:
          "International Air Freight Cargo Shippings (High Priority Transport)",
      quantity: 2.0,
      unit: "SHIPMENT",
      unitCost: 10052700.0,
      extendedCost: 20105400.0,
    ),
    LineItemModel(
      orderId: "2323137",
      lineNumber: 1,
      itemCode: "999-STRUCT-M",
      requestedDate: "10-06-2026",
      description:
          "Heavy Duty Foundation Concrete Pouring & Sub-Level Tunnel Reinforcements",
      quantity: 1.0,
      unit: "LOT",
      unitCost: 284000000.0,
      extendedCost: 284000000.0,
    ),
  ];

  List<OrderModel> get filteredOrders {
    return _orders.where((order) {
      final matchesQuery = _searchQuery.isEmpty ||
          order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.supplierName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          order.originator.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesQuery;
    }).toList();
  }

  // Auth Methods
  void setUsername(String value) {
    _username = value;
    _loginError = null;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _loginError = null;
    notifyListeners();
  }

  Future<bool> login() async {
    if (_username.trim().isEmpty || _password.trim().isEmpty) {
      _loginError = "Fields can't be empty";
      notifyListeners();
      return false;
    }

    return _authenticateAndLogin(_username.trim(), _password.trim());
  }

  /// Loads the encrypted credentials saved for biometric sign-in and calls the
  /// token request API with them, so the user never re-enters username/password.
  Future<bool> loginWithStoredCredentials() async {
    final credentials = await _storage.loadCredentials();
    if (credentials == null) {
      _loginError = 'No saved credentials found. Please sign in with your password.';
      notifyListeners();
      return false;
    }

    _username = credentials.username;
    _password = credentials.password;
    return _authenticateAndLogin(credentials.username, credentials.password);
  }

  Future<bool> _authenticateAndLogin(String username, String password) async {
    _isLoginLoading = true;
    _loginError = null;
    notifyListeners();

    try {
      final deviceId = await DeviceInfoService.getDeviceId();
      final response = await _apiService.login(
        LoginRequest(
          deviceName: deviceId,
          username: username,
          password: password,
        ),
      );

      _isAuthenticated = true;
      _loginSuccessResponse = response;
      _token = response.token;
      _sessionExpired = false;

      await _storage.saveSession(
        token: response.token ?? '',
        username: response.username,
        environment: response.environment,
        role: response.role,
      );

      return true;
    } on ApiException catch (e) {
      _isAuthenticated = false;
      _loginError = e.message;
      return false;
    } catch (_) {
      _isAuthenticated = false;
      _loginError = 'Unable to login. Please try again.';
      return false;
    } finally {
      _isLoginLoading = false;
      notifyListeners();
    }
  }

  /// Loads whether the user has previously opted into biometric sign-in.
  Future<void> loadBiometricPreference() async {
    _biometricEnabled = await _storage.isBiometricEnabled();
    notifyListeners();
  }

  /// Called after a successful password login when the user opts in to
  /// biometric sign-in. Encrypts and stores the credentials just used so
  /// they can be replayed against the login API on future app opens.
  Future<void> enableBiometricLogin({
    required String username,
    required String password,
  }) async {
    await _storage.saveCredentials(username: username, password: password);
    await _storage.setBiometricEnabled(true);
    _biometricEnabled = true;
    notifyListeners();
  }

  Future<void> disableBiometricLogin() async {
    await _storage.clearCredentials();
    _biometricEnabled = false;
    notifyListeners();
  }

  /// Marks the session as expired, clears the active session, and notifies listeners
  /// so the UI can show the session-expired dialog and redirect to login.
  /// Saved biometric credentials are left untouched.
  Future<void> handleSessionExpired() async {
    await _storage.clearSession();
    _sessionExpired = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _isLoginLoading = false;
    _isOrdersLoading = false;
    _username = '';
    _password = '';
    _token = null;
    _loginSuccessResponse = null;
    _loginError = null;
    _ordersError = null;
    _orders.clear();
    _waitingLinesError = null;
    _waitingLinesCurrency = '';
    _waitingLines.clear();
    _isOrderActionLoading = false;
    _orderActionError = null;
    _searchQuery = '';
    _selectedFilter = 'Queued';
    _isPdfLoading = false;
    _pdfError = null;
    _pdfDocuments = [];
    _responsiblePersons = [];
    _isResponsiblePersonsLoading = false;
    _responsiblePersonsError = null;
    _sessionExpired = false;
    _flow = ApprovalFlow.purchaseOrder;
    notifyListeners();
  }

  /// Full explicit logout: clears the active session as well as the saved
  /// username/password and biometric flag, so the next app open shows the
  /// password login form instead of prompting for biometrics.
  Future<void> logoutWithApi() async {
    if (_token != null) {
      await _apiService.logoutUser(token: _token!);
    }
    await _storage.clearSession();
    await _storage.clearCredentials();
    _biometricEnabled = false;
    logout();
  }

  void clearPdfState() {
    _isPdfLoading = false;
    _pdfError = null;
    _pdfDocuments = [];
    notifyListeners();
  }

  /// Fetches every media object attached to the order and downloads each one
  /// individually, so all associated documents are shown, not just the first.
  Future<void> fetchAndDownloadPdf({
    required String orderNumber,
    required String orderCo,
    required String orderType,
  }) async {
    _isPdfLoading = true;
    _pdfError = null;
    _pdfDocuments = [];
    notifyListeners();

    try {
      final t = _token ?? '';
      if (t.trim().isEmpty) {
        throw const ApiException('Session token missing. Please login again.');
      }

      final sequences = await _apiService.fetchMediaObjectSequences(
        token: t,
        orderNumber: orderNumber,
        orderCo: orderCo,
        orderType: orderType,
      );

      if (sequences.isEmpty) {
        _pdfError = 'No document available for this order.';
        return;
      }

      final documents = <Uint8List>[];
      for (final sequence in sequences) {
        final bytes = await _apiService.downloadMediaObject(
          token: t,
          orderNumber: orderNumber,
          orderCo: orderCo,
          orderType: orderType,
          sequence: sequence.toString(),
        );
        if (bytes != null && bytes.isNotEmpty) {
          documents.add(bytes);
        }
      }

      if (documents.isEmpty) {
        _pdfError = 'Failed to download document.';
        return;
      }

      _pdfDocuments = documents;
    } on SessionExpiredException {
      await handleSessionExpired();
    } on ApiException catch (e) {
      _pdfError = e.message;
    } catch (_) {
      debugPrint('Error fetching/downloading PDF: ${_.toString()}');
      _pdfError = 'Unable to load document.';
    } finally {
      _isPdfLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrders() async {
    _isOrdersLoading = true;
    _ordersError = null;
    notifyListeners();

    try {
      final response = await _apiService.fetchOrders(token: _token, flag: 'Q');
      _orders
        ..clear()
        ..addAll(response.orders.map(OrderModel.fromApi));
    } on SessionExpiredException {
      await handleSessionExpired();
    } on ApiException catch (e) {
      _orders.clear();
      _ordersError = e.message;
    } catch (_) {
      _orders.clear();
      _ordersError = 'Unable to load orders.';
    } finally {
      _isOrdersLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrdersBasedOnFilter(String flag) async {
    _isOrdersLoading = true;
    _ordersError = null;
    notifyListeners();

    try {
      final response = await _apiService.fetchOrders(token: _token, flag: flag);
      _orders
        ..clear()
        ..addAll(response.orders.map(OrderModel.fromApi));
    } on SessionExpiredException {
      await handleSessionExpired();
    } on ApiException catch (e) {
      _orders.clear();
      _ordersError = e.message;
    } catch (_) {
      _orders.clear();
      _ordersError = 'Unable to load orders.';
    } finally {
      _isOrdersLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWaitingLinesForOrder({
    required int orderNumber,
    required String orderCo,
    required String orderType,
  }) async {
    _isWaitingLinesLoading = true;
    _waitingLinesError = null;
    _waitingLines.clear();
    notifyListeners();

    try {
      final t = _token ?? '';
      if (t.trim().isEmpty) {
        throw const ApiException('Session token missing. Please login again.');
      }

      final response = await _apiService.fetchWaitingPurchaseOrderLineDetails(
        token: t,
        orderNumber: orderNumber,
        orderCo: orderCo,
        orderType: orderType,
      );

      _waitingLinesCurrency = response.currencyCode;
      _waitingLines
        ..clear()
        ..addAll(response.lines);
    } on SessionExpiredException {
      await handleSessionExpired();
    } on ApiException catch (e) {
      _waitingLinesError = e.message;
    } catch (_) {
      _waitingLinesError = 'Unable to load lines.';
    } finally {
      _isWaitingLinesLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchResponsiblePersons({
    required int orderNumber,
    required String orderCo,
    required String orderType,
  }) async {
    _isResponsiblePersonsLoading = true;
    _responsiblePersonsError = null;
    _responsiblePersons = [];
    notifyListeners();

    try {
      final t = _token ?? '';
      if (t.trim().isEmpty) {
        throw const ApiException('Session token missing. Please login again.');
      }

      final response = await _apiService.fetchResponsiblePersons(
        token: t,
        orderNumber: orderNumber,
        orderCo: orderCo,
        orderType: orderType,
      );

      _responsiblePersons = response.persons;
    } on SessionExpiredException {
      await handleSessionExpired();
    } on ApiException catch (e) {
      _responsiblePersonsError = e.message;
    } catch (_) {
      _responsiblePersonsError = 'Unable to load responsible persons.';
    } finally {
      _isResponsiblePersonsLoading = false;
      notifyListeners();
    }
  }

  // Dashboard Operations
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectFilter(String filter) {
    _selectedFilter = filter;
    switch (filter) {
      case 'Queued':
        fetchOrdersBasedOnFilter('Q');
        break;
      case 'Waiting Approval':
        fetchOrdersBasedOnFilter('W');
        break;
      case 'Approved':
        fetchOrdersBasedOnFilter('A');
        break;
      case "Rejected":
        fetchOrdersBasedOnFilter('R');
        break;
      case "Failure":
        fetchOrdersBasedOnFilter('SS');
        break;
    }
    notifyListeners();
  }

  // Core Decisions
  Future<String?> approveOrder({
    required int orderNumber,
    required String orderCo,
    required String orderType,
  }) async {
    _isOrderActionLoading = true;
    _orderActionError = null;
    notifyListeners();

    try {
      final t = _token ?? '';
      if (t.trim().isEmpty) {
        throw const ApiException('Session token missing. Please login again.');
      }

      final PurchaseOrderApproveResponse response =
          await _apiService.approveOrder(
        token: t,
        orderNumber: orderNumber,
        orderCo: orderCo,
        orderType: orderType,
        flow: _flow,
      );

      await fetchOrders();
      return response.successMessage(_flow.shortLabel);
    } on SessionExpiredException {
      await handleSessionExpired();
      return null;
    } on ApiException catch (e) {
      _orderActionError = e.message;
      return null;
    } catch (_) {
      _orderActionError = 'Unable to approve order.';
      return null;
    } finally {
      _isOrderActionLoading = false;
      notifyListeners();
    }
  }

  Future<String?> rejectOrder({
    required int orderNumber,
    required String orderCo,
    required String orderType,
    required String note,
  }) async {
    _isOrderActionLoading = true;
    _orderActionError = null;
    notifyListeners();

    try {
      final t = _token ?? '';
      if (t.trim().isEmpty) {
        throw const ApiException('Session token missing. Please login again.');
      }

      final PurchaseOrderRejectResponse response =
          await _apiService.rejectOrder(
        token: t,
        orderNumber: orderNumber,
        orderCo: orderCo,
        orderType: orderType,
        flow: _flow,
        note: note,
      );

      await fetchOrders();
      if (response.rejected.isNotEmpty) {
        return '${_flow.shortLabel} is rejected successfully.';
      }
      return '${_flow.shortLabel} rejected.';
    } on SessionExpiredException {
      await handleSessionExpired();
      return null;
    } on ApiException catch (e) {
      _orderActionError = e.message;
      return null;
    } catch (_) {
      _orderActionError = 'Unable to reject order.';
      return null;
    } finally {
      _isOrderActionLoading = false;
      notifyListeners();
    }
  }

  // View item streams
  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  List<LineItemModel> getLineItemsForOrder(String orderId) {
    return _lineItems.where((item) => item.orderId == orderId).toList();
  }
}
