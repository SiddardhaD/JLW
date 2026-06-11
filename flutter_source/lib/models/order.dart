/// Model representing a Purchase Order in the JLW system.
class OrderModel {
  final String id;
  final String originator;
  final String responsible;
  final String project;
  final String orderType;
  final String orderDate;
  final String supplierName;
  final double orderAmount;
  final String currency;
  final String priority; // "URGENT", "ROUTINE", "HIGH VALUE"
  String status;         // "Awaiting Approval", "Approved", "Rejected"
  final String coNumber;
  final String projectIdFull;

  OrderModel({
    required this.id,
    required this.originator,
    required this.responsible,
    required this.project,
    required this.orderType,
    required this.orderDate,
    required this.supplierName,
    required this.orderAmount,
    required this.currency,
    required this.priority,
    required this.status,
    required this.coNumber,
    required this.projectIdFull,
  });

  OrderModel copyWith({String? status}) {
    return OrderModel(
      id: id,
      originator: originator,
      responsible: responsible,
      project: project,
      orderType: orderType,
      orderDate: orderDate,
      supplierName: supplierName,
      orderAmount: orderAmount,
      currency: currency,
      priority: priority,
      status: status ?? this.status,
      coNumber: coNumber,
      projectIdFull: projectIdFull,
    );
  }
}

/// Model representing an individual Line Item in a Purchase Order.
class LineItemModel {
  final String orderId;
  final int lineNumber;
  final String itemCode;
  final String requestedDate;
  final String description;
  final double quantity;
  final String unit;
  final double unitCost;
  final double extendedCost;

  LineItemModel({
    required this.orderId,
    required this.lineNumber,
    required this.itemCode,
    required this.requestedDate,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.extendedCost,
  });
}
