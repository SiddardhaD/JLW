class PurchaseOrderApproveHierarchicalResponse {
  final String? message;
  final ServiceRequestLayer? serviceRequest1;

  const PurchaseOrderApproveHierarchicalResponse({
    required this.message,
    required this.serviceRequest1,
  });

  factory PurchaseOrderApproveHierarchicalResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final serviceRequestRaw = json['ServiceRequest1'];
    return PurchaseOrderApproveHierarchicalResponse(
      message: json['Message']?.toString(),
      serviceRequest1: serviceRequestRaw is Map<String, dynamic>
          ? ServiceRequestLayer.fromJson(serviceRequestRaw)
          : null,
    );
  }
}

class ServiceRequestLayer {
  final List<ServiceRequestFormLayer> forms;

  const ServiceRequestLayer({required this.forms});

  factory ServiceRequestLayer.fromJson(Map<String, dynamic> json) {
    final rawForms = json['forms'];
    final forms = rawForms is List
        ? rawForms
            .whereType<Map<String, dynamic>>()
            .map(ServiceRequestFormLayer.fromJson)
            .toList()
        : <ServiceRequestFormLayer>[];

    return ServiceRequestLayer(forms: forms);
  }
}

class ServiceRequestFormLayer {
  final int? stackId;
  final int? stateId;
  final String? currentApp;

  const ServiceRequestFormLayer({
    required this.stackId,
    required this.stateId,
    required this.currentApp,
  });

  factory ServiceRequestFormLayer.fromJson(Map<String, dynamic> json) {
    return ServiceRequestFormLayer(
      stackId: json['stackId'] as int?,
      stateId: json['stateId'] as int?,
      currentApp: json['currentApp']?.toString(),
    );
  }
}

class PurchaseOrderApproveFinalResponse {
  final int orderNumber;
  final String responsible;
  final String? message;

  const PurchaseOrderApproveFinalResponse({
    required this.orderNumber,
    required this.responsible,
    required this.message,
  });

  factory PurchaseOrderApproveFinalResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return PurchaseOrderApproveFinalResponse(
      orderNumber: int.tryParse((json['OrderNumber'] ?? '0').toString()) ?? 0,
      responsible: (json['Responsible'] ?? '').toString(),
      message: json['Message']?.toString(),
    );
  }
}

class PurchaseOrderApproveResponse {
  final PurchaseOrderApproveHierarchicalResponse? hierarchical;
  final PurchaseOrderApproveFinalResponse? finalApproval;

  const PurchaseOrderApproveResponse({
    required this.hierarchical,
    required this.finalApproval,
  });

  String get successMessage =>
      finalApproval?.message ??
      hierarchical?.message ??
      'Order is approved successfully.';

  factory PurchaseOrderApproveResponse.fromJson(Map<String, dynamic> json) {
    final hasServiceRequest = json.containsKey('ServiceRequest1');
    final hasFinalShape = json.containsKey('OrderNumber') &&
        json.containsKey('Responsible') &&
        json.containsKey('Message');

    return PurchaseOrderApproveResponse(
      hierarchical: hasServiceRequest
          ? PurchaseOrderApproveHierarchicalResponse.fromJson(json)
          : null,
      finalApproval: hasFinalShape
          ? PurchaseOrderApproveFinalResponse.fromJson(json)
          : null,
    );
  }
}

class PurchaseOrderRejectItem {
  final String responsible;
  final int orderNumber;
  final String orderType;
  final String orderCo;
  final String note;

  const PurchaseOrderRejectItem({
    required this.responsible,
    required this.orderNumber,
    required this.orderType,
    required this.orderCo,
    required this.note,
  });

  factory PurchaseOrderRejectItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderRejectItem(
      responsible: (json['Responsible'] ?? '').toString(),
      orderNumber: int.tryParse((json['OrderNumber'] ?? '0').toString()) ?? 0,
      orderType: (json['OrTy'] ?? '').toString(),
      orderCo: (json['OrderCo'] ?? '').toString(),
      note: (json['Note'] ?? '').toString(),
    );
  }
}

class PurchaseOrderRejectResponse {
  final List<PurchaseOrderRejectItem> rejected;

  const PurchaseOrderRejectResponse({required this.rejected});

  factory PurchaseOrderRejectResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['PurchaseOrderReject'];
    final list = raw is List
        ? raw
            .whereType<Map<String, dynamic>>()
            .map(PurchaseOrderRejectItem.fromJson)
            .toList()
        : <PurchaseOrderRejectItem>[];

    return PurchaseOrderRejectResponse(rejected: list);
  }
}
