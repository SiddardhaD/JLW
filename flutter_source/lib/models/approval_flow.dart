/// Distinguishes the two approval dashboards the app supports.
/// Both flows share the same orders/lines/responsible-persons/PDF APIs;
/// only the approve/reject endpoints and on-screen wording differ.
enum ApprovalFlow {
  purchaseOrder,
  purchaseRequisition;

  String get shortLabel =>
      this == ApprovalFlow.purchaseOrder ? 'PO' : 'PR';

  String get displayName => this == ApprovalFlow.purchaseOrder
      ? 'Purchase Order'
      : 'Purchase Requisition';
}
