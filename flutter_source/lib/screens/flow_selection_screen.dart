import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/approval_flow.dart';
import '../providers/approvals_provider.dart';

/// Lets the user pick which approval dashboard to work in after login.
/// Both dashboards share the same order/line/document APIs — only the
/// approve/reject endpoints (and on-screen wording) differ per [ApprovalFlow].
class FlowSelectionScreen extends StatefulWidget {
  final ValueChanged<ApprovalFlow> onFlowSelected;
  final VoidCallback onLogout;

  const FlowSelectionScreen({
    super.key,
    required this.onFlowSelected,
    required this.onLogout,
  });

  @override
  State<FlowSelectionScreen> createState() => _FlowSelectionScreenState();
}

class _FlowSelectionScreenState extends State<FlowSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final userData = context.watch<ApprovalsProvider>().loginSuccessResponse;

    return Scaffold(
      backgroundColor: JLWColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Select Dashboard',
          style: TextStyle(
            color: JLWColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => _confirmLogout(context),
              style: TextButton.styleFrom(
                backgroundColor: JLWColors.buttonReject,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (userData != null) ...[
                Text(
                  'Welcome, ${userData.username}',
                  style: const TextStyle(
                    color: JLWColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose which approvals you want to work on.',
                  style: TextStyle(color: JLWColors.slateText, fontSize: 13),
                ),
                const SizedBox(height: 28),
              ],
              _FlowCard(
                icon: Icons.assignment_turned_in_outlined,
                title: 'PO Dashboard',
                subtitle: 'Purchase Order approvals',
                onTap: () => widget.onFlowSelected(ApprovalFlow.purchaseOrder),
              ),
              const SizedBox(height: 16),
              _FlowCard(
                icon: Icons.fact_check_outlined,
                title: 'PR Dashboard',
                subtitle: 'Purchase Requisition approvals',
                onTap: () =>
                    widget.onFlowSelected(ApprovalFlow.purchaseRequisition),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
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
          style:
              TextStyle(color: JLWColors.slateText, fontSize: 14, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                  color: JLWColors.slateText, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: JLWColors.buttonReject,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ApprovalsProvider>().logoutWithApi();
      if (context.mounted) widget.onLogout();
    }
  }
}

class _FlowCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FlowCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JLWColors.cardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: JLWColors.borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: JLWColors.mintAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: JLWColors.mintAccent, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: JLWColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: JLWColors.slateText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: JLWColors.slateText),
            ],
          ),
        ),
      ),
    );
  }
}
