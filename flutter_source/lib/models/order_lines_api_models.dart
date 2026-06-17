class WaitingPurchaseOrderLineDetailsResponse {
  final bool approval;
  final String? message;
  final List<WaitingPurchaseOrderLineItem> lines;

  const WaitingPurchaseOrderLineDetailsResponse({
    required this.approval,
    required this.message,
    required this.lines,
  });

  factory WaitingPurchaseOrderLineDetailsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final raw = json['FR_55_WorkWithPo'];
    final list = raw is List
        ? raw
            .whereType<Map<String, dynamic>>()
            .map(WaitingPurchaseOrderLineItem.fromJson)
            .toList()
        : <WaitingPurchaseOrderLineItem>[];

    return WaitingPurchaseOrderLineDetailsResponse(
      approval: json['Approval'] == true,
      message: json['message']?.toString(),
      lines: list,
    );
  }
}

class WaitingPurchaseOrderLineItem {
  final int orderNumber;
  final String orderCo;
  final String orderType;
  final String originator;
  final String supplierName;
  final double orderAmount;
  final String baseCurr;
  final String requestDate;
  final String responsible;

  const WaitingPurchaseOrderLineItem({
    required this.orderNumber,
    required this.orderCo,
    required this.orderType,
    required this.originator,
    required this.supplierName,
    required this.orderAmount,
    required this.baseCurr,
    required this.requestDate,
    required this.responsible,
  });

  factory WaitingPurchaseOrderLineItem.fromJson(Map<String, dynamic> json) {
    final amountRaw = json['OrderAmount'];
    return WaitingPurchaseOrderLineItem(
      orderNumber: int.tryParse((json['OrderNumber'] ?? '0').toString()) ?? 0,
      orderCo: (json['OrderCo'] ?? '').toString(),
      orderType: (json['OrTy'] ?? '').toString(),
      originator: (json['Originator'] ?? '').toString(),
      supplierName: (json['SupplierName'] ?? '').toString(),
      orderAmount: amountRaw is num
          ? amountRaw.toDouble()
          : double.tryParse(amountRaw.toString()) ?? 0,
      baseCurr: (json['BaseCurr'] ?? '').toString(),
      requestDate: (json['RequestDate'] ?? '').toString(),
      responsible: (json['Responsible'] ?? '').toString(),
    );
  }
}
