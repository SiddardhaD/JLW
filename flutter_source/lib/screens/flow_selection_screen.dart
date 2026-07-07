import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/approval_flow.dart';
import '../providers/approvals_provider.dart';

/// Lets the user pick which approval dashboard to work in after login.
/// Both dashboards share the same order/line/document APIs — only the
/// approve/reject endpoints (and on-screen wording) differ per [ApprovalFlow].
class FlowSelectionScreen extends StatelessWidget {
  final ValueChanged<ApprovalFlow> onFlowSelected;
  final VoidCallback onLogout;

  const FlowSelectionScreen({
    super.key,
    required this.onFlowSelected,
    required this.onLogout,
  });

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
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: JLWColors.slateText),
            tooltip: 'Logout',
            onPressed: onLogout,
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
                onTap: () => onFlowSelected(ApprovalFlow.purchaseOrder),
              ),
              const SizedBox(height: 16),
              _FlowCard(
                icon: Icons.fact_check_outlined,
                title: 'PR Dashboard',
                subtitle: 'Purchase Requisition approvals',
                onTap: () => onFlowSelected(ApprovalFlow.purchaseRequisition),
              ),
            ],
          ),
        ),
      ),
    );
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
