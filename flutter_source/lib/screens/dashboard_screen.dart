import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/order.dart';
import '../providers/approvals_provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  final Function(String) onOrderSelect;
  final VoidCallback onLogout;

  const DashboardScreen({
    super.key,
    required this.onOrderSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApprovalsProvider>(context);
    final orders = provider.filteredOrders;

    return Scaffold(
      backgroundColor: JLWColors.darkBg,
      appBar: AppBar(
        backgroundColor: JLWColors.darkBg,
        elevation: 0,
        title: const Text(
          "JLW Approvals Board",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: JLWColors.mintAccent),
            tooltip: "Logout Securely",
            onPressed: onLogout,
          )
        ],
      ),
      body: Column(
        children: [
          // Section 1: Dynamic Metrics Stats Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildMetricCard(
                  title: "URGENT",
                  value: "01",
                  highlightColor: JLWColors.statusUrgent,
                ),
                const SizedBox(width: 10),
                _buildMetricCard(
                  title: "HIGH VALUE",
                  value: "02",
                  highlightColor: JLWColors.statusHighValue,
                ),
                const SizedBox(width: 10),
                _buildMetricCard(
                  title: "TOTAL VALUE",
                  value: "324.2M",
                  highlightColor: JLWColors.mintAccent,
                ),
              ],
            ),
          ),

          // Section 2: Search Input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: provider.search,
              decoration: InputDecoration(
                filled: true,
                fillColor: JLWColors.cardBg,
                prefixIcon: const Icon(Icons.search, color: JLWColors.slateText),
                hintText: "Search Order #, Originator, Supplier...",
                hintStyle: const TextStyle(color: JLWColors.slateText, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: JLWColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: JLWColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: JLWColors.mintAccent),
                ),
              ),
            ),
          ),

          // Section 3: Scrollable Category Pills
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                'All',
                'High Value',
                'Today',
                'Pending'
              ].map((filter) {
                final isSelected = provider.selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? JLWColors.textDark : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        provider.selectFilter(filter);
                      }
                    },
                    selectedColor: JLWColors.mintAccent,
                    backgroundColor: JLWColors.cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(
                        color: isSelected ? JLWColors.mintAccent : JLWColors.borderColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Section 4: Dynamic Interactive Order Cards List
          Expanded(
            child: orders.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: JLWColors.slateText),
                        SizedBox(height: 16),
                        Text(
                          "No Purchase Orders Checked In",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Adjust filters or search parameters",
                          style: TextStyle(color: JLWColors.slateText, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _OrderCardItem(
                        order: order,
                        onTap: () => onOrderSelect(order.id),
                        onApprove: () => provider.approveOrder(order.id),
                        onReject: () => provider.rejectOrder(order.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color highlightColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: JLWColors.cardBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: JLWColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: highlightColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(color: JLWColors.slateText, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(color: highlightColor, fontSize: 20, fontWeight: FontWeight.black, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCardItem extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _OrderCardItem({
    required this.order,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '', decimalDigits: 0);
    final formattedAmount = currencyFormatter.format(order.orderAmount);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: JLWColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: order.status == 'Approved'
                ? JLWColors.mintAccent.withOpacity(0.4)
                : order.status == 'Rejected'
                    ? JLWColors.buttonReject.withOpacity(0.4)
                    : JLWColors.borderColor,
          ),
        ),
        child: Column(
          children: [
            // Head Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "${order.orderType}-${order.project}",
                        style: const TextStyle(
                          color: JLWColors.mintAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.id,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  _buildPriorityPill(order.priority),
                ],
              ),
            ),
            const Divider(color: JLWColors.borderColor, height: 1),

            // Card body details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                children: [
                  _buildDetailRow("ORIGINATOR", order.originator, "RESPONSIBLE", order.responsible),
                  const SizedBox(height: 8),
                  _buildFullWidthRow("SUPPLIER", order.supplierName),
                  const SizedBox(height: 10),

                  // Amount presentation box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: JLWColors.inputBg,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: JLWColors.borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "TOTAL ORDER VALUE",
                          style: TextStyle(
                            color: JLWColors.slateText,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          "$formattedAmount ${order.currency}",
                          style: const TextStyle(
                            color: JLWColors.mintAccent,
                            fontWeight: FontWeight.extrabold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: JLWColors.borderColor, height: 1),

            // Interaction section or state stamp
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: _buildFooterSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityPill(String level) {
    Color pillColor;
    Color textColor = Colors.black;

    if (level == 'URGENT') {
      pillColor = JLWColors.statusUrgent;
      textColor = Colors.white;
    } else if (level == 'HIGH VALUE') {
      pillColor = JLWColors.statusHighValue;
      textColor = Colors.black;
    } else {
      pillColor = JLWColors.inputBg;
      textColor = JLWColors.slateText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pillColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String k1, String v1, String k2, String v2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(k1, style: const TextStyle(color: JLWColors.slateText, fontSize: 8, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(v1, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(k2, style: const TextStyle(color: JLWColors.slateText, fontSize: 8, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(v2, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullWidthRow(String title, String value) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: JLWColors.slateText, fontSize: 8, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSection() {
    if (order.status == 'Approved') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle_outline, color: JLWColors.mintAccent, size: 16),
          SizedBox(width: 6),
          Text(
            "ORDER APPROVED SECURELY",
            style: TextStyle(color: JLWColors.mintAccent, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ],
      );
    }

    if (order.status == 'Rejected') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.cancel_outlined, color: JLWColors.buttonReject, size: 16),
          SizedBox(width: 6),
          Text(
            "ORDER REJECTED BY EXECUTIVE",
            style: TextStyle(color: JLWColors.buttonReject, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onReject,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: JLWColors.buttonReject),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text(
              "REJECT",
              style: TextStyle(color: JLWColors.buttonReject, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: onApprove,
            style: ElevatedButton.styleFrom(
              backgroundColor: JLWColors.mintAccent,
              foregroundColor: JLWColors.textDark,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text(
              "APPROVE NOW",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.extrabold),
            ),
          ),
        ),
      ],
    );
  }
}
