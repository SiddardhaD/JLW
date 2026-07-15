import '../config/flavor_config.dart';

class ApiConfig {
  static String get baseUrl => FlavorConfig.instance.baseUrl;

  // Keep login URL maintained in one place.
  static String get loginUrl => '$baseUrl/v2/tokenrequest';
  static String get logoutUrl => '$baseUrl/tokenrequest/logout';
  static String get ordersUrl =>
      '$baseUrl/v3/orchestrator/ORCH_55_GetPurchaseOrderStatusInquiry';

  static String get waitingPurchaseOrderLineDetailsUrl =>
      '$baseUrl/v3/orchestrator/ORCH_55_GetWaitingPurchaseOrderLineDetails';

  static String get purchaseOrderApproveUrl =>
      '$baseUrl/v3/orchestrator/ORCH_55_PurchaseOrderApprove';
  static String get purchaseOrderRejectUrl =>
      '$baseUrl/v3/orchestrator/ORCH_55_PurchaseOrderReject';

  static String get purchaseOrderRequisitionApproveUrl =>
      '$baseUrl/v3/orchestrator/ORCH_55_PurchaseOrderRequisitionApproval';
  static String get purchaseOrderRequisitionRejectUrl =>
      '$baseUrl/v3/orchestrator/ORCH_55_PurchaseOrderRequisitionReject';

  static String get mediaObjectRetrievalUrl =>
      '$baseUrl/v3/orchestrator/ORCH_55_MediaObjectRetrieval';
  static String get mediaObjectDownloadUrl =>
      '$baseUrl/v3/orchestrator/ORCH_55_MediaObjectDownload';

  static String get responsiblePersonUrl =>
      '$baseUrl/v3/orchestrator/ORCH_55_GetPurchaseOrderResponsiblePerson';
}
