import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/order.dart';
import '../providers/approvals_provider.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final VoidCallback onBack;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApprovalsProvider>(context);
    final order = provider.getOrderById(orderId);
    final lineItems = provider.getLineItemsForOrder(orderId);

    if (order == null) {
      return Scaffold(
        backgroundColor: JLWColors.darkBg,
        body: const Center(
          child: CircularProgressIndicator(color: JLWColors.mintAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: JLWColors.darkBg,
      appBar: AppBar(
        backgroundColor: JLWColors.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JLWColors.mintAccent),
          onPressed: onBack,
        ),
        title: Text(
          "Order No: $orderId",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: JLWColors.mintAccent),
            onPressed: onBack,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                children: [
                  // Section 1: ORDER SUMMARY Card
                  _buildOrderSummaryCard(order),

                  const SizedBox(height: 24),

                  // Section 2: Line Items Title Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Line Items",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: JLWColors.inputBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: JLWColors.borderColor),
                        ),
                        child: Text(
                          "${lineItems.length} Items",
                          style: const TextStyle(
                            color: JLWColors.mintAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Section 3: Line Items Listing Card Block
                  ...lineItems.map((item) => _buildLineItemCard(item)),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Persistent Decision Bottom Panel
            _buildDecisionTray(context, order, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: JLWColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JLWColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text(
              "ORDER SUMMARY",
              style: TextStyle(
                color: JLWColors.mintAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(color: JLWColors.borderColor, height: 1),

          // Originator and Responsible Party split row
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: JLWColors.borderColor)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ORIGINATOR", style: TextStyle(color: JLWColors.slateText, fontSize: 9, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(order.originator, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("RESPONSIBLE PARTY", style: TextStyle(color: JLWColors.slateText, fontSize: 9, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(order.responsible, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: JLWColors.borderColor, height: 1),

          // Project ID Full-Width Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: JLWColors.borderColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("PROJECT ID", style: TextStyle(color: JLWColors.slateText, fontSize: 9, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(order.projectIdFull, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // CO NUMBER | ORDER DATE
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: JLWColors.borderColor)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("CO NUMBER", style: TextStyle(color: JLWColors.slateText, fontSize: 9, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(order.coNumber, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ORDER DATE", style: TextStyle(color: JLWColors.slateText, fontSize: 9, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          order.id == '2323135' ? '10-OCT-2026' : order.orderDate,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: JLWColors.borderColor, height: 1),

          // ORDER STATUS Row
          Container(
            padding: const EdgeInsets.all(14),
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: JLWColors.borderColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ORDER STATUS", style: TextStyle(color: JLWColors.slateText, fontSize: 9, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: order.status == 'Approved'
                            ? JLWColors.mintAccent
                            : order.status == 'Rejected'
                                ? JLWColors.buttonReject
                                : const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.status,
                      style: TextStyle(
                        color: order.status == 'Approved'
                            ? JLWColors.mintAccent
                            : order.status == 'Rejected'
                                ? JLWColors.buttonReject
                                : const Color(0xFFF59E0B),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // SUPPLIER NAME Row
          Container(
            padding: const EdgeInsets.all(14),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SUPPLIER NAME", style: TextStyle(color: JLWColors.slateText, fontSize: 9, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  order.id == '2323135' ? "James O' Malley Global Sourcing Ltd." : order.supplierName,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItemCard(LineItemModel item) {
    final fmt = NumberFormat.getNumberInstance(Locale.US);
    final unitCostFormatted = fmt.format(item.unitCost);
    final extendedCostFormatted = fmt.format(item.extendedCost);

    String quantityFormatted = fmt.format(item.quantity);
    if (item.quantity == item.quantity.toInt().toDouble()) {
      quantityFormatted = "${item.quantity.toInt()} ${item.unit}";
    } else {
      quantityFormatted = "$quantityFormatted ${item.unit}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: JLWColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JLWColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header details block split
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: JLWColors.borderColor),
                        bottom: BorderSide(color: JLWColors.borderColor),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Line", style: TextStyle(color: JLWColors.slateText, fontSize: 8, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(item.lineNumber.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: JLWColors.borderColor),
                        bottom: BorderSide(color: JLWColors.borderColor),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Item Code", style: TextStyle(color: JLWColors.slateText, fontSize: 8, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(item.itemCode, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: JLWColors.borderColor)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Requested Date", style: TextStyle(color: JLWColors.slateText, fontSize: 8, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(item.requestedDate, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Description Full Width Block
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: JLWColors.borderColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Description", style: TextStyle(color: JLWColors.slateText, fontSize: 8, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, height: 1.3),
                ),
              ],
            ),
          ),

          // Pricing block row (Qty / Unit Cost / Extended Cost)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(child: _buildPriceCell("QTY", quantityFormatted, JLWColors.mintAccent)),
                const SizedBox(width: 8),
                Expanded(child: _buildPriceCell("Unit Cost", "$unitCostFormatted AED", Colors.white)),
                const SizedBox(width: 8),
                Expanded(child: _buildPriceCell("Extended Cost", "$extendedCostFormatted AED", JLWColors.mintAccent, flex: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCell(String heading, String innerText, Color textColor, {double flex = 1.0}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: JLWColors.inputBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: JLWColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: const TextStyle(color: JLWColors.slateText, fontSize: 8, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            innerText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionTray(BuildContext context, OrderModel order, ApprovalsProvider provider) {
    return Container(
      color: JLWColors.darkBg,
      padding: const EdgeInsets.all(14.0),
      child: order.status == 'Awaiting Approval'
          ? Row(
              children: [
                // REJECT button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.rejectOrder(orderId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JLWColors.buttonReject,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: JLWColors.borderColor),
                      ),
                    ),
                    child: const Text(
                      "REJECT\nORDER",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.extrabold, fontSize: 11, height: 1.2),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // APPROVE NOW button
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.approveOrder(orderId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JLWColors.mintAccent,
                      foregroundColor: JLWColors.textDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle, size: 20),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("APPROVE", style: TextStyle(fontWeight: FontWeight.black, fontSize: 12, height: 1.0)),
                            Text("NOW", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, height: 1.0)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: JLWColors.inputBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: order.status == 'Approved' ? JLWColors.mintAccent : JLWColors.buttonReject,
                ),
              ),
              child: Text(
                "ORDER ${order.status.toUpperCase()} SECURELY BY EXECUTIVE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: order.status == 'Approved' ? JLWColors.mintAccent : JLWColors.buttonReject,
                  fontWeight: FontWeight.black,
                  fontSize: 13,
                ),
              ),
            ),
    );
  }
}
