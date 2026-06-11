import 'package:flutter/material.dart';
import '../models/order.dart';

/// State Manager for JLW Approvals.
/// Replicates the ApprovalsViewModel used in the Jetpack Compose package.
class ApprovalsProvider extends ChangeNotifier {
  // Authentication States
  String _username = '';
  String _password = '';
  bool _isAuthenticated = false;
  String? _loginError;

  String get username => _username;
  String get password => _password;
  bool get isAuthenticated => _isAuthenticated;
  String? get loginError => _loginError;

  // Search & Filtering States
  String _searchQuery = '';
  String _selectedFilter = 'All'; // "All", "High Value", "Today", "Pending"

  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;

  // Seed Data List corresponding to mockup and native database specifications
  final List<OrderModel> _orders = [
    OrderModel(
      id: "2323135",
      originator: "Anubhav",
      responsible: "Nitya",
      project: "M30",
      orderType: "OP",
      orderDate: "12-05-2024",
      supplierName: "James O'Malley Enterprise",
      orderAmount: 20002202.0,
      currency: "AED",
      priority: "URGENT",
      status: "Awaiting Approval",
      coNumber: "00200",
      projectIdFull: "M30-INFRA-2024",
    ),
    OrderModel(
      id: "2323136",
      originator: "Hiten",
      responsible: "Nitya",
      project: "M30",
      orderType: "OP",
      orderDate: "14-05-2024",
      supplierName: "Global Logistics Ltd.",
      orderAmount: 20105400.0,
      currency: "AED",
      priority: "ROUTINE",
      status: "Awaiting Approval",
      coNumber: "00325",
      projectIdFull: "M30-LOGISTICS-2024",
    ),
    OrderModel(
      id: "2323137",
      originator: "Shiddartl",
      responsible: "Nitya",
      project: "M30",
      orderType: "OP",
      orderDate: "15-05-2024",
      supplierName: "James O'Malley Enterprise",
      orderAmount: 284000000.0,
      currency: "AED",
      priority: "HIGH VALUE",
      status: "Awaiting Approval",
      coNumber: "00401",
      projectIdFull: "M30-MEGA-INFRA",
    ),
  ];

  // Seed Line Items matching mockup table cells exactly
  final List<LineItemModel> _lineItems = [
    LineItemModel(
      orderId: "2323135",
      lineNumber: 1,
      itemCode: "210-998-A",
      requestedDate: "10-06-2026",
      description: "Precision Grade Structural Steel - Grade 50 / Type 2 Reinforcement Rods",
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
      description: "Heavy Infrastructure Mechanical Excavation Core Assemblies - Base Contractor Installment",
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
      description: "International Air Freight Cargo Shippings (High Priority Transport)",
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
      description: "Heavy Duty Foundation Concrete Pouring & Sub-Level Tunnel Reinforcements",
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
          order.supplierName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.originator.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'High Value' && (order.priority == 'HIGH VALUE' || order.orderAmount >= 50000000.0)) ||
          (_selectedFilter == 'Today' && order.orderDate == '15-05-2024') ||
          (_selectedFilter == 'Pending' && order.status == 'Awaiting Approval');

      return matchesQuery && matchesFilter;
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

  void login() {
    if (_username.trim().isEmpty) {
      _loginError = "Username cannot be empty";
      notifyListeners();
      return;
    }
    if (_password.isEmpty) {
      _loginError = "Password cannot be empty";
      notifyListeners();
      return;
    }
    _isAuthenticated = true;
    _loginError = null;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _username = '';
    _password = '';
    _searchQuery = '';
    _selectedFilter = 'All';
    notifyListeners();
  }

  // Dashboard Operations
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // Core Decisions
  void approveOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(status: "Approved");
      notifyListeners();
    }
  }

  void rejectOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(status: "Rejected");
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
