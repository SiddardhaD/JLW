import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../models/order_action_models.dart';
import '../models/order_lines_api_models.dart';
import '../models/order.dart';
import '../network/approvals_api_service.dart';

/// State Manager for JLW Approvals.
/// Replicates the ApprovalsViewModel used in the Jetpack Compose package.
class ApprovalsProvider extends ChangeNotifier {
  final ApprovalsApiService _apiService = ApprovalsApiService();

  // Authentication States
  String _username = '';
  String _password = '';
  bool _isAuthenticated = false;
  bool _isLoginLoading = false;
  String? _loginError;
  LoginSuccessResponse? _loginSuccessResponse;
  String? _token;

  String get username => _username;
  String get password => _password;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoginLoading => _isLoginLoading;
  String? get loginError => _loginError;
  LoginSuccessResponse? get loginSuccessResponse => _loginSuccessResponse;

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

  bool _isWaitingLinesLoading = false;
  String? _waitingLinesError;
  bool _isOrderActionLoading = false;
  String? _orderActionError;

  List<GetWaitingPurchaseOrderLineDetails> get waitingLines => _waitingLines;
  bool get isWaitingLinesLoading => _isWaitingLinesLoading;
  String? get waitingLinesError => _waitingLinesError;
  bool get isOrderActionLoading => _isOrderActionLoading;
  String? get orderActionError => _orderActionError;

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

      // final matchesFilter = _selectedFilter == 'All' ||
      //     (_selectedFilter == 'High Value' &&
      //         (order.priority == 'HIGH VALUE' ||
      //             order.orderAmount >= 50000000.0)) ||
      //     (_selectedFilter == 'Today' && order.orderDate == '15-05-2024') ||
      //     (_selectedFilter == 'Pending' && order.status == 'Awaiting Approval');

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

    _isLoginLoading = true;
    _loginError = null;
    notifyListeners();

    try {
      final response = await _apiService.login(
        LoginRequest(
          deviceName: 'Android',
          username: _username.trim(),
          password: _password.trim(),
        ),
      );

      _isAuthenticated = true;
      _loginSuccessResponse = response;
      _token = response.token;
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
    _waitingLines.clear();
    _isOrderActionLoading = false;
    _orderActionError = null;
    _searchQuery = '';
    _selectedFilter = 'Queued';
    notifyListeners();
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
    } on ApiException catch (e) {
      _orders..clear();
      _ordersError = e.message;
    } catch (_) {
      _orders..clear();
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
    } on ApiException catch (e) {
      _orders..clear();
      _ordersError = e.message;
    } catch (_) {
      _orders..clear();
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

      _waitingLines
        ..clear()
        ..addAll(response.lines);
    } on ApiException catch (e) {
      _waitingLinesError = e.message;
    } catch (_) {
      _waitingLinesError = 'Unable to load lines.';
    } finally {
      _isWaitingLinesLoading = false;
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
      );

      await fetchOrders();
      return response.successMessage;
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
      );

      await fetchOrders();
      if (response.rejected.isNotEmpty) {
        return 'Order is rejected successfully.';
      }
      return 'Order rejected.';
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
