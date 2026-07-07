class OrdersResponse {
  final bool approval;
  final String? message;
  final List<OrderListItemResponse> orders;

  const OrdersResponse({
    required this.approval,
    required this.message,
    required this.orders,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    final rawOrders = json['FR_55_WorkWithPo'] ?? json['FR_55_WorkWithOrdersPo'];
    final list = rawOrders is List
        ? rawOrders
            .whereType<Map<String, dynamic>>()
            .map(OrderListItemResponse.fromJson)
            .toList()
        : <OrderListItemResponse>[];

    return OrdersResponse(
      approval: json['Approval'] == true,
      message: json['message']?.toString(),
      orders: list,
    );
  }
}

class OrderListItemResponse {
  final int orderNumber;
  final String orderCo;
  final String orderType;
  final String originator;
  final String responsible;
  final String supplierName;
  final double orderAmount;
  final String baseCurr;
  final String currencyCode;
  final String requestDate;

  const OrderListItemResponse({
    required this.orderNumber,
    required this.orderCo,
    required this.orderType,
    required this.originator,
    required this.responsible,
    required this.supplierName,
    required this.orderAmount,
    required this.baseCurr,
    required this.currencyCode,
    required this.requestDate,
  });

  factory OrderListItemResponse.fromJson(Map<String, dynamic> json) {
    final amountRaw = json['OrderAmount'];
    return OrderListItemResponse(
      orderNumber: int.tryParse((json['OrderNumber'] ?? '0').toString()) ?? 0,
      orderCo: (json['OrderCo'] ?? '').toString(),
      orderType: (json['OrTy'] ?? '').toString(),
      originator: (json['Originator'] ?? '').toString(),
      responsible: (json['Responsible'] ?? '').toString(),
      supplierName: (json['SupplierName'] ?? '').toString(),
      orderAmount: amountRaw is num
          ? amountRaw.toDouble()
          : double.tryParse(amountRaw.toString()) ?? 0,
      baseCurr: (json['BaseCurr'] ?? '').toString(),
      currencyCode: (json['CurrencyCode'] ?? '').toString(),
      requestDate: (json['RequestDate'] ?? '').toString(),
    );
  }
}
