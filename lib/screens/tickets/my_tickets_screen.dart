import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/screen_state.dart';
import '../../models/ticket_model.dart';
import '../../viewmodels/my_tickets_vm.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import 'digital_ticket_screen.dart';

/// S19: My Events & Tickets Hub Screen
/// Anti-slop Editorial Pass Wallet: flat hairline containers, monospace ticket codes, tabular dates.
class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().currentUser;
      if (user != null) {
        context.read<MyTicketsViewModel>().loadUserTickets(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ticketVM = context.watch<MyTicketsViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Vé sự kiện của tôi'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppTheme.hairline),
        ),
      ),
      body: Column(
        children: [
          // Segmented Tabs Header
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingScreenPadding,
              vertical: 12,
            ),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              border: Border.all(color: AppTheme.hairline, width: 1),
            ),
            child: Row(
              children: [
                _buildTabItem(context, ticketVM, index: 0, label: 'Sắp diễn ra'),
                _buildTabItem(context, ticketVM, index: 1, label: 'Đã tham gia'),
              ],
            ),
          ),

          // Tickets List View
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              onRefresh: () async {
                if (user != null) {
                  await ticketVM.loadUserTickets(user.id);
                }
              },
              child: switch (ticketVM.state) {
                StateInitial() || StateLoading() => const LoadingView(message: 'Đang tải vé điện tử...'),
                StateEmpty(message: final msg) => EmptyView(
                    title: 'Chưa có vé sự kiện',
                    message: msg,
                    actionLabel: 'Tải lại danh sách',
                    onAction: () {
                      if (user != null) ticketVM.loadUserTickets(user.id);
                    },
                  ),
                StateError(error: final err) => ErrorView(
                    title: 'Lỗi đồng bộ vé',
                    errorMessage: err,
                    onRetry: () {
                      if (user != null) ticketVM.loadUserTickets(user.id);
                    },
                  ),
                StateData(data: final tickets) => ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingScreenPadding,
                      vertical: 6,
                    ),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return _buildTicketListItem(context, ticket);
                    },
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    MyTicketsViewModel vm, {
    required int index,
    required String label,
  }) {
    final isSelected = vm.selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => vm.selectTab(index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected ? Border.all(color: AppTheme.hairline, width: 1) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.obsidian : AppTheme.textMuted,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTicketListItem(BuildContext context, TicketModel ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.hairline, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => DigitalTicketScreen(ticket: ticket),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingCardPadding),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ticket.isCheckedIn ? AppTheme.successSoft : AppTheme.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                    border: Border.all(
                      color: ticket.isCheckedIn ? AppTheme.successBorder : AppTheme.hairline,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    ticket.isCheckedIn ? Icons.verified_outlined : Icons.qr_code_2_rounded,
                    color: ticket.isCheckedIn ? AppTheme.successInk : AppTheme.obsidian,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ticket.id,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ticket.isCheckedIn ? AppTheme.successSoft : AppTheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: ticket.isCheckedIn ? AppTheme.successBorder : AppTheme.outlineVariant,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              ticket.isCheckedIn ? 'ĐÃ ĐIỂM DANH' : 'CHỜ CHECK-IN',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: ticket.isCheckedIn ? AppTheme.successInk : AppTheme.onPrimaryContainer,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ticket.eventTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 12, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '${ticket.eventTime} · ${ticket.eventDate}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFeatures: [FontFeature.tabularFigures()],
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 18, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
