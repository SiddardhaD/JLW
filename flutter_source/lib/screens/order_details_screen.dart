import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/order_lines_api_models.dart';
import '../models/order.dart';
import '../providers/approvals_provider.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onBack;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.onBack,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider = context.read<ApprovalsProvider>();
      final orderNumber = int.tryParse(widget.order.id) ?? 0;
      await provider.fetchWaitingLinesForOrder(
        orderNumber: orderNumber,
        orderCo: widget.order.coNumber,
        orderType: widget.order.orderType,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApprovalsProvider>(context);
    final order = widget.order;
    final lines = provider.waitingLines;

    return Scaffold(
      backgroundColor: JLWColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JLWColors.mintAccent),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Order No: ${order.id}',
          style: const TextStyle(
            color: JLWColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: JLWColors.slateText),
            onPressed: widget.onBack,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              children: [
                _buildOrderSummaryCard(order),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lines Waiting for Approval',
                      style: TextStyle(
                        color: JLWColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: JLWColors.mintAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: JLWColors.mintAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '${lines.length} Lines',
                        style: const TextStyle(
                          color: JLWColors.mintAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (provider.isWaitingLinesLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (provider.waitingLinesError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      provider.waitingLinesError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: JLWColors.buttonReject,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (lines.isEmpty)
                  const _NoWaitingLinesWidget()
                else ...[
                  ...lines.map(_buildWaitingLineCard),
                ],
              ],
            ),
          ),
          _buildDecisionTray(context, order, provider),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(OrderModel order) {
    final supplierName = order.id == '2323135'
        ? "James O' Malley Global Sourcing Ltd."
        : order.supplierName;
    final orderDate = order.id == '2323135' ? '10-OCT-2026' : order.orderDate;

    return Container(
      decoration: BoxDecoration(
        color: JLWColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: JLWColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Text(
              'ORDER SUMMARY',
              style: TextStyle(
                color: JLWColors.mintAccent,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const Divider(color: JLWColors.borderColor, height: 1),
          _summaryGridRow(
            leftLabel: 'ORIGINATOR',
            leftValue: order.originator,
            rightLabel: 'RESPONSIBLE PARTY',
            rightValue: order.responsible,
            bottomBorder: true,
          ),
          // _summaryFullRow('PROJECT ID', order.projectIdFull,
          //     bottomBorder: true),
          _summaryGridRow(
            leftLabel: 'CO NUMBER',
            leftValue: order.coNumber,
            rightLabel: 'ORDER DATE',
            rightValue: orderDate,
            bottomBorder: true,
          ),
          _summaryStatusRow(order.status),
          _summaryFullRow(
            'SUPPLIER NAME',
            supplierName,
            valueColor: JLWColors.mintAccent,
          ),
        ],
      ),
    );
  }

  Widget _summaryGridRow({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
    bool bottomBorder = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: bottomBorder
            ? const Border(bottom: BorderSide(color: JLWColors.borderColor))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: _summaryCell(leftLabel, leftValue, rightBorder: true)),
          Expanded(child: _summaryCell(rightLabel, rightValue)),
        ],
      ),
    );
  }

  Widget _summaryFullRow(
    String label,
    String value, {
    bool bottomBorder = false,
    Color valueColor = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: bottomBorder
            ? const Border(bottom: BorderSide(color: JLWColors.borderColor))
            : null,
      ),
      child: _summaryCell(label, value, valueColor: valueColor),
    );
  }

  Widget _summaryStatusRow(String status) {
    late Color dotColor;
    late Color textColor;

    if (status == 'Approved') {
      dotColor = JLWColors.mintAccent;
      textColor = JLWColors.mintAccent;
    } else if (status == 'Rejected') {
      dotColor = JLWColors.buttonReject;
      textColor = JLWColors.buttonReject;
    } else {
      dotColor = const Color(0xFFF59E0B);
      textColor = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: JLWColors.borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDER STATUS',
            style: TextStyle(
              color: JLWColors.slateText,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCell(
    String label,
    String value, {
    bool rightBorder = false,
    Color valueColor = Colors.black,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: rightBorder
            ? const Border(right: BorderSide(color: JLWColors.borderColor))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: JLWColors.slateText,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // Legacy mock line-item UI (kept temporarily for future real line parsing).
  // ignore: unused_element
  Widget _buildLineItemCard(LineItemModel item) {
    final fmt = NumberFormat('#,##0', 'en_US');
    final unitCostFormatted = fmt.format(item.unitCost);
    final extendedCostFormatted = fmt.format(item.extendedCost);

    final quantityFormatted = item.quantity == item.quantity.toInt().toDouble()
        ? '${item.quantity.toInt()} ${item.unit}'
        : '${fmt.format(item.quantity)} ${item.unit}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: JLWColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: JLWColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _lineItemCell(
                  'Line',
                  item.lineNumber.toString(),
                  rightBorder: true,
                  bottomBorder: true,
                ),
              ),
              Expanded(
                flex: 4,
                child: _lineItemCell(
                  'Item Code',
                  item.itemCode,
                  rightBorder: true,
                  bottomBorder: true,
                ),
              ),
              Expanded(
                flex: 4,
                child: _lineItemCell(
                  'Requested Date',
                  item.requestedDate,
                  bottomBorder: true,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: JLWColors.borderColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(
                    color: JLWColors.slateText,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: JLWColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _priceCell(
                      'QTY', quantityFormatted, JLWColors.mintAccent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _priceCell(
                    'Unit Cost',
                    '$unitCostFormatted AED',
                    Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _priceCell(
                    'Extended Cost',
                    '$extendedCostFormatted AED',
                    JLWColors.mintAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingLineCard(GetWaitingPurchaseOrderLineDetails item) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final amount = fmt.format(item.extendedCost);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: JLWColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: JLWColors.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${item.line}',
                    style: const TextStyle(
                      color: JLWColors.textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '${item.um} $amount',
                  style: const TextStyle(
                    color: JLWColors.mintAccent,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _waitingLineRow('Item Number', item.itemNumber),
            _waitingLineRow('Quantity', item.quantity.toString()),
            _waitingLineRow('Unit Cost', item.unitCost.toString()),
            _waitingLineRow('Extended Cost', item.extendedCost.toString()),
            _waitingLineRow('UM', item.um),
            _waitingLineRow('Description', item.description),
          ],
        ),
      ),
    );
  }

  Widget _waitingLineRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                color: JLWColors.slateText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: JLWColors.textDark,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _lineItemCell(
    String label,
    String value, {
    bool rightBorder = false,
    bool bottomBorder = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(
          right: rightBorder
              ? const BorderSide(color: JLWColors.borderColor)
              : BorderSide.none,
          bottom: bottomBorder
              ? const BorderSide(color: JLWColors.borderColor)
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: JLWColors.slateText,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: JLWColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _priceCell(String heading, String value, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: JLWColors.inputBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: JLWColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              color: JLWColors.slateText,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionTray(
    BuildContext context,
    OrderModel order,
    ApprovalsProvider provider,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: JLWColors.darkBg,
        border: Border(top: BorderSide(color: JLWColors.borderColor)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: order.status == 'Awaiting Approval'
            ? Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => _confirmReject(context, provider),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: JLWColors.buttonReject),
                          foregroundColor: JLWColors.buttonReject,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'REJECT ORDER',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmApprove(context, provider),
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text(
                          'APPROVE NOW',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: JLWColors.mintAccent,
                          foregroundColor: JLWColors.darkBg,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: JLWColors.inputBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: order.status == 'Approved'
                        ? JLWColors.mintAccent
                        : JLWColors.buttonReject,
                  ),
                ),
                child: Text(
                  'ORDER ${order.status.toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: order.status == 'Approved'
                        ? JLWColors.mintAccent
                        : JLWColors.buttonReject,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _confirmApprove(
    BuildContext context,
    ApprovalsProvider provider,
  ) async {
    final orderId = widget.order.id;
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Confirm Approval',
      message:
          'Are you sure you want to approve Order #$orderId? This action cannot be undone.',
      confirmLabel: 'Approve',
      isDestructive: false,
    );
    if (confirmed == true && context.mounted) {
      provider.approveOrder(orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #$orderId approved successfully'),
          backgroundColor: JLWColors.mintAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmReject(
    BuildContext context,
    ApprovalsProvider provider,
  ) async {
    final orderId = widget.order.id;
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Confirm Rejection',
      message:
          'Are you sure you want to reject Order #$orderId? This action cannot be undone.',
      confirmLabel: 'Reject',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      provider.rejectOrder(orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order rejected'),
          backgroundColor: JLWColors.buttonReject,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required bool isDestructive,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => AlertDialog(
        backgroundColor: JLWColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: JLWColors.borderColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: JLWColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: JLWColors.slateText,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: JLWColors.slateText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDestructive ? JLWColors.buttonReject : JLWColors.mintAccent,
              foregroundColor:
                  isDestructive ? Colors.white : JLWColors.textDark,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoWaitingLinesWidget extends StatelessWidget {
  const _NoWaitingLinesWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: JLWColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: JLWColors.borderColor),
      ),
      child: const Column(
        children: [
          Icon(Icons.inbox_outlined, color: JLWColors.slateText, size: 42),
          SizedBox(height: 10),
          Text(
            'No Lines are waiting for approval',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: JLWColors.textDark,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'This purchase order has no pending line items.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: JLWColors.slateText,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
