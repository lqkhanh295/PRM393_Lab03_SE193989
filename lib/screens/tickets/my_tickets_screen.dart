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
class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ticketVM = context.watch<MyTicketsViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Vé sự kiện của tôi'),
      ),
      body: Column(
        children: [
          // Segmented Tabs Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingScreenPadding, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildTabItem(context, ticketVM, index: 0, label: 'Sắp diễn ra'),
                _buildTabItem(context, ticketVM, index: 1, label: 'Đã tham gia'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Tickets List View
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (user != null) {
                  await ticketVM.loadUserTickets(user.id);
                }
              },
              child: switch (ticketVM.state) {
                StateInitial() || StateLoading() => const LoadingView(message: 'Đang tải vé điện tử...'),
                StateEmpty(message: final msg) => EmptyView(
                    message: msg,
                    actionLabel: 'Làm mới',
                    onAction: () {
                      if (user != null) ticketVM.loadUserTickets(user.id);
                    },
                  ),
                StateError(error: final err) => ErrorView(
                    errorMessage: err,
                    onRetry: () {
                      if (user != null) ticketVM.loadUserTickets(user.id);
                    },
                  ),
                StateData(data: final tickets) => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingScreenPadding, vertical: 8),
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

  Widget _buildTabItem(BuildContext context, MyTicketsViewModel vm, {required int index, required String label}) {
    final isSelected = vm.selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => vm.selectTab(index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DigitalTicketScreen(ticket: ticket),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingCardPadding),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ticket.isCheckedIn ? const Color(0xFFE8F5E9) : AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    ticket.isCheckedIn ? Icons.verified_rounded : Icons.qr_code_2_rounded,
                    color: ticket.isCheckedIn ? AppTheme.success : AppTheme.primary,
                    size: 28,
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
                          Text(
                            ticket.id,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: ticket.isCheckedIn ? const Color(0xFFE8F5E9) : AppTheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ticket.isCheckedIn ? 'ĐÃ ĐIỂM DANH' : 'CHỜ CHECK-IN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: ticket.isCheckedIn ? AppTheme.success : AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.eventTitle,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ticket.eventTime} · ${ticket.eventDate}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppTheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
