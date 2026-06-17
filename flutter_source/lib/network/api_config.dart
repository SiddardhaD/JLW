class ApiConfig {
  static const String baseUrl = 'http://140.245.21.194/jderest';

  // Keep login URL maintained in one place.
  static const String loginUrl = '$baseUrl/v2/tokenrequest';
  static const String logoutUrl = '$baseUrl/tokenrequest/logout';
  static const String ordersUrl =
      '$baseUrl/v3/orchestrator/ORCH_55_GetPurchaseOrderStatusInquiry';

  static const String waitingPurchaseOrderLineDetailsUrl =
      '$baseUrl/v3/orchestrator/ORCH_55_GetWaitingPurchaseOrderLineDetails';
}
