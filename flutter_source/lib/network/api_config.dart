class ApiConfig {
  static const String baseUrl = 'http://140.245.21.194/jderest';
  // static const String baseUrl = 'https://npaislb.jlwme.com/jderest';

  // Keep login URL maintained in one place.
  static const String loginUrl = '$baseUrl/v2/tokenrequest';
  static const String logoutUrl = '$baseUrl/tokenrequest/logout';
  static const String ordersUrl =
      '$baseUrl/v3/orchestrator/ORCH_55_GetPurchaseOrderStatusInquiry';

  static const String waitingPurchaseOrderLineDetailsUrl =
      '$baseUrl/v3/orchestrator/ORCH_55_GetWaitingPurchaseOrderLineDetails';

  static const String purchaseOrderApproveUrl =
      '$baseUrl/v3/orchestrator/ORCH_55_PurchaseOrderApprove';
  static const String purchaseOrderRejectUrl =
      '$baseUrl/v3/orchestrator/ORCH_55_PurchaseOrderReject';

  static const String purchaseOrderRequisitionApproveUrl =
      '$baseUrl/v3/orchestrator/ORCH_55_PurchaseOrderRequisitionApproval';
  static const String purchaseOrderRequisitionRejectUrl =
      '$baseUrl/v3/orchestrator/ORCH_55_PurchaseOrderRequisitionReject';

  static const String mediaObjectRetrievalUrl =
      '$baseUrl/v3/orchestrator/ORCH_55_MediaObjectRetrieval';
  static const String mediaObjectDownloadUrl =
      '$baseUrl/v3/orchestrator/ORCH_55_MediaObjectDownload';

  static const String responsiblePersonUrl =
      '$baseUrl/v3/orchestrator/ORCH_55_GetPurchaseOrderResponsiblePerson';
}
