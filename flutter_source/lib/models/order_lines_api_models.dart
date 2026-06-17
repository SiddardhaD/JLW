class WaitingPurchaseOrderLineDetailsResponse {
  final bool approval;
  final String? message;
  final List<GetWaitingPurchaseOrderLineDetails> lines;

  const WaitingPurchaseOrderLineDetailsResponse({
    required this.approval,
    required this.message,
    required this.lines,
  });

  factory WaitingPurchaseOrderLineDetailsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final raw = json['GetWaitingPurchaseOrderLineDetails'];
    final list = raw is List
        ? raw
            .whereType<Map<String, dynamic>>()
            .map(GetWaitingPurchaseOrderLineDetails.fromJson)
            .toList()
        : <GetWaitingPurchaseOrderLineDetails>[];

    return WaitingPurchaseOrderLineDetailsResponse(
      approval: json['Approval'] == true,
      message: json['message']?.toString(),
      lines: list,
    );
  }
}

class GetWaitingPurchaseOrderLineDetails {
  final int line;
  final String itemNumber;
  final int quantity;
  final double unitCost;
  final double extendedCost;
  final String um;
  final String description;

  const GetWaitingPurchaseOrderLineDetails({
    required this.line,
    required this.itemNumber,
    required this.quantity,
    required this.unitCost,
    required this.extendedCost,
    required this.um,
    required this.description,
  });

  factory GetWaitingPurchaseOrderLineDetails.fromJson(
      Map<String, dynamic> json) {
    return GetWaitingPurchaseOrderLineDetails(
      line: json['Line'] ?? 0,
      itemNumber: json['ItemNumber'] ?? '',
      quantity: json['QuantityOrdered'] ?? 0,
      unitCost: json['UnitCost'].toDouble() ?? 0,
      extendedCost: json['ExtendedCost'].toDouble() ?? 0.0,
      um: json['UM'] ?? '',
      description: json['Description'] ?? '',
    );
  }
}
