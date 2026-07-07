import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/order.dart';
import '../providers/approvals_provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final Function(OrderModel) onOrderSelect;
  final VoidCallback onLogout;
  final VoidCallback onSwitchDashboard;

  const DashboardScreen({
    super.key,
    required this.onOrderSelect,
    required this.onLogout,
    required this.onSwitchDashboard,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ApprovalsProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<ApprovalsProvider>();
      _provider!.addListener(_onProviderChange);
      _provider!.fetchOrdersBasedOnFilter('Q');
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChange);
    super.dispose();
  }

  void _onProviderChange() {
    if (!mounted) return;
    if (_provider?.isSessionExpired == true) {
      _provider?.removeListener(_onProviderChange);
      _showSessionExpiredDialog();
    }
  }

  Future<void> _showSessionExpiredDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (ctx) => AlertDialog(
        backgroundColor: JLWColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: JLWColors.borderColor),
        ),
        title: const Text(
          'Session Expired',
          style: TextStyle(
            color: JLWColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Your session has expired. Please login again to continue.',
          style: TextStyle(color: JLWColors.slateText, fontSize: 14, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: JLWColors.mintAccent,
              foregroundColor: JLWColors.darkBg,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Login Again', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (mounted) widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApprovalsProvider>(context);
    final orders = provider.filteredOrders;
    final userData = provider.loginSuccessResponse;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _showExitDialog(context);
      },
      child: Scaffold(
      backgroundColor: JLWColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox(),
        title: Text(
          '${provider.flow.shortLabel} Orders Awaiting Approval',
          style: const TextStyle(
            color: JLWColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.home, color: JLWColors.slateText),
            tooltip: 'Switch Dashboard',
            onPressed: widget.onSwitchDashboard,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => _confirmLogout(context, provider),
              style: TextButton.styleFrom(
                backgroundColor: JLWColors.buttonReject,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            context.read<ApprovalsProvider>().fetchOrdersBasedOnFilter('Q');
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  style:
                      const TextStyle(color: JLWColors.textDark, fontSize: 14),
                  onChanged: provider.search,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: JLWColors.inputBg,
                    prefixIcon: const Icon(Icons.search,
                        color: JLWColors.slateText, size: 20),
                    hintText: 'Search by Order No., Supplier...',
                    hintStyle: const TextStyle(
                      color: JLWColors.slateText,
                      fontSize: 13,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: JLWColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: JLWColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: JLWColors.mintAccent),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (userData?.role.trim() == '*ALL') ...[
                // SizedBox(
                //   height: 36,
                //   child: ListView(
                //     scrollDirection: Axis.horizontal,
                //     padding: const EdgeInsets.symmetric(horizontal: 16),
                //     children: [
                //       'Queued',
                //       'Waiting Approval',
                //       'Approved',
                //       'Rejected',
                //       'Failure',
                //     ].map((filter) {
                //       final isSelected = provider.selectedFilter == filter;
                //       return Padding(
                //         padding: const EdgeInsets.only(right: 8),
                //         child: GestureDetector(
                //           onTap: () => provider.selectFilter(filter),
                //           child: Container(
                //             padding: const EdgeInsets.symmetric(horizontal: 16),
                //             alignment: Alignment.center,
                //             decoration: BoxDecoration(
                //               color: isSelected
                //                   ? JLWColors.mintAccent
                //                   : JLWColors.cardBg,
                //               borderRadius: BorderRadius.circular(20),
                //               border: Border.all(
                //                 color: isSelected
                //                     ? JLWColors.mintAccent
                //                     : JLWColors.borderColor,
                //               ),
                //             ),
                //             child: Text(
                //               filter,
                //               style: TextStyle(
                //                 color: isSelected
                //                     ? JLWColors.darkBg
                //                     : JLWColors.slateText,
                //                 fontWeight: FontWeight.w600,
                //                 fontSize: 12,
                //               ),
                //             ),
                //           ),
                //         ),
                //       );
                //     }).toList(),
                //   ),
                // ),
                const SizedBox(height: 8),
              ],
              Expanded(
                child: provider.isOrdersLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.ordersError != null
                        ? Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                provider.ordersError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: JLWColors.buttonReject,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : orders.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.folder_open,
                                        size: 64, color: JLWColors.slateText),
                                    SizedBox(height: 16),
                                    Text(
                                      'No orders found',
                                      style: TextStyle(
                                        color: JLWColors.textDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Adjust filters or search parameters',
                                      style: TextStyle(
                                        color: JLWColors.slateText,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  final order = orders[index];
                                  return _OrderCardItem(
                                    order: order,
                                    onTap: () => widget.onOrderSelect(order),
                                  );
                                },
                              ),
              ),
              const SizedBox(height: 30)
            ],
          )),
      ),
    );
  }

  Future<void> _showExitDialog(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => AlertDialog(
        backgroundColor: JLWColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: JLWColors.borderColor),
        ),
        title: const Text(
          'Exit App',
          style: TextStyle(
            color: JLWColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Are you sure you want to exit?',
          style: TextStyle(color: JLWColors.slateText, fontSize: 14, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: JLWColors.slateText, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: JLWColors.buttonReject,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Exit', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (shouldExit == true) SystemNavigator.pop();
  }

  Future<void> _confirmLogout(
    BuildContext context,
    ApprovalsProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => AlertDialog(
        backgroundColor: JLWColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: JLWColors.borderColor),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: JLWColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
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
              backgroundColor: JLWColors.buttonReject,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.logoutWithApi();
      if (context.mounted) widget.onLogout();
    }
  }

  Widget _buildBottomNav(VoidCallback onLogout) {
    return Container(
      decoration: const BoxDecoration(
        color: JLWColors.cardBg,
        border: Border(top: BorderSide(color: JLWColors.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                icon: Icons.assignment_turned_in_outlined,
                label: 'Approvals',
                isActive: true,
              ),
              _navItem(
                icon: Icons.assignment_outlined,
                label: 'Review',
                isActive: false,
              ),
              _navItem(
                icon: Icons.person_outline,
                label: 'Account',
                isActive: false,
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? JLWColors.mintAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? JLWColors.textDark : JLWColors.slateText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? JLWColors.textDark : JLWColors.slateText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
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

  const _OrderCardItem({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_US');
    final formattedAmount = fmt.format(order.orderAmount);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: JLWColors.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: JLWColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  if (order.priority == 'HIGH VALUE') ...[
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: JLWColors.statusHighValue,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      'ORDER NO. #${order.id}',
                      style: const TextStyle(
                        color: JLWColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // _buildPriorityBadge(order.priority),
                ],
              ),
            ),
            const Divider(color: JLWColors.borderColor, height: 1),
            _buildGridCell(
              leftLabel: 'Originator',
              leftValue: order.originator,
              rightLabel: 'Responsible',
              rightValue: order.responsible,
              bottomBorder: true,
            ),
            _buildGridCell(
              leftLabel: 'Order Ty',
              leftValue: order.orderType,
              rightLabel: 'Request Date',
              rightValue: order.orderDate,
              bottomBorder: true,
            ),
            _buildFullWidthCell('Supplier Name', order.supplierName),
            const Divider(color: JLWColors.borderColor, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Amount',
                          style: TextStyle(
                            color: JLWColors.slateText,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: formattedAmount,
                                style: const TextStyle(
                                  color: JLWColors.mintAccent,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                              TextSpan(
                                text: ' ${order.currency}',
                                style: const TextStyle(
                                  color: JLWColors.mintAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (order.status == 'Approved')
                    _buildStatusLabel(
                      'APPROVED',
                      JLWColors.mintAccent,
                      Icons.check_circle_outline,
                    )
                  else if (order.status == 'Rejected')
                    _buildStatusLabel(
                      'REJECTED',
                      JLWColors.buttonReject,
                      Icons.cancel_outlined,
                    )
                  else
                    _viewOrderButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCell({
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
            child: _cellContent(leftLabel, leftValue, rightBorder: true),
          ),
          Expanded(child: _cellContent(rightLabel, rightValue)),
        ],
      ),
    );
  }

  Widget _buildFullWidthCell(String label, String value) {
    return _cellContent(label, value, padding: const EdgeInsets.all(12));
  }

  Widget _cellContent(
    String label,
    String value, {
    bool rightBorder = false,
    EdgeInsets padding = const EdgeInsets.all(12),
  }) {
    return Container(
      padding: padding,
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
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: JLWColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewOrderButton() {
    return SizedBox(
      width: 120,
      height: 36,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: JLWColors.mintAccent,
          foregroundColor: JLWColors.darkBg,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: const Text(
          'VIEW ORDER',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusLabel(String text, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
