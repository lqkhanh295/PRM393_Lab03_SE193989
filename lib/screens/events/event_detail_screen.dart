import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/screen_state.dart';
import '../../models/event_model.dart';
import '../../viewmodels/event_detail_vm.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/gemini_event_insight_card.dart';
import 'registration_modal.dart';
import '../tickets/digital_ticket_screen.dart';
import '../../viewmodels/my_tickets_vm.dart';

/// S13: Event Detail Screen
/// Anti-Slop Architecture: Clear timeline, clean speaker badges, fixed bottom bar.
class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventDetailViewModel>().loadEvent(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailVM = context.watch<EventDetailViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: switch (detailVM.state) {
        StateInitial() || StateLoading() => const Scaffold(
            body: LoadingView(message: 'Đang tải thông tin chi tiết sự kiện...'),
          ),
        StateEmpty(message: final msg) => Scaffold(
            appBar: AppBar(),
            body: EmptyView(message: msg),
          ),
        StateError(error: final err) => Scaffold(
            appBar: AppBar(),
            body: ErrorView(
              errorMessage: err,
              onRetry: () => detailVM.loadEvent(widget.eventId),
            ),
          ),
        StateData(data: final event) => _buildDetailContent(context, event),
      },
    );
  }

  Widget _buildDetailContent(BuildContext context, EventModel event) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Sliver App Bar with Banner
            SliverAppBar(
              expandedHeight: 240.0,
              pinned: true,
              backgroundColor: AppTheme.secondary,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0x990F172A),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  event.bannerUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.secondary,
                    child: const Center(
                      child: Icon(Icons.event, color: AppTheme.textSubtle, size: 56),
                    ),
                  ),
                ),
              ),
            ),

            // Content Body
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Club attribution
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer,
                            borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
                          ),
                          child: Text(
                            event.category.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.onPrimaryContainer,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tổ chức bởi ${event.clubName}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Event Title
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        height: 1.25,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time & Location Box (Flat, 1px hairline border)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        border: Border.all(color: AppTheme.outlineVariant, width: 1),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 18, color: AppTheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${event.time} · Ngày ${event.date}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20, thickness: 1, color: AppTheme.outlineVariant),
                          Row(
                            children: [
                              const Icon(Icons.place_outlined, size: 18, color: AppTheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  event.location,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Description Section
                    const Text(
                      'Giới thiệu sự kiện',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.55,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Level 2 Gemini AI Structured Output Insights
                    GeminiEventInsightCard(event: event),
                    const SizedBox(height: 20),

                    // Speakers Section
                    if (event.speakers.isNotEmpty) ...[
                      const Text(
                        'Diễn giả khách mời',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...event.speakers.map((spk) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                              border: Border.all(color: AppTheme.outlineVariant, width: 1),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppTheme.surfaceContainer,
                                  backgroundImage: NetworkImage(spk.avatarUrl),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        spk.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        spk.role,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 24),
                    ],

                    // Sessions Timeline
                    if (event.sessions.isNotEmpty) ...[
                      const Text(
                        'Lịch trình chi tiết',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...event.sessions.map((sess) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                              border: Border.all(color: AppTheme.outlineVariant, width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
                                  ),
                                  child: Text(
                                    sess.time,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.secondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sess.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Diễn giả: ${sess.speakerName}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 80),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),

        // Docked Action Bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.outlineVariant, width: 1)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.isFull ? 'HẾT CHỖ' : 'CÒN ${event.spotsRemaining} CHỖ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: event.isPast ? AppTheme.textMuted : (event.isFull ? AppTheme.error : AppTheme.success),
                      ),
                    ),
                    Text(
                      event.isPast ? 'Đã đóng đăng ký' : 'Miễn phí tham gia',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Builder(
                    builder: (btnCtx) {
                      final existingTicket = btnCtx.watch<MyTicketsViewModel>().getTicketForEvent(event.id);
                      if (existingTicket != null) {
                        return AppPrimaryButton(
                          label: 'Xem vé của tôi',
                          icon: Icons.confirmation_number_outlined,
                          onPressed: () {
                            Navigator.push(
                              btnCtx,
                              MaterialPageRoute(
                                builder: (_) => DigitalTicketScreen(ticket: existingTicket),
                              ),
                            );
                          },
                        );
                      }
                      if (event.isPast) {
                        return const AppPrimaryButton(
                          label: 'Sự kiện đã kết thúc',
                          onPressed: null,
                        );
                      }
                      return AppPrimaryButton(
                        label: event.isFull ? 'Đã hết chỗ' : 'Đăng ký tham gia',
                        onPressed: event.isFull
                            ? null
                            : () {
                                final user = btnCtx.read<AuthViewModel>().currentUser;
                                if (user != null) {
                                  showModalBottomSheet(
                                    context: btnCtx,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => RegistrationModal(event: event, user: user),
                                  );
                                } else {
                                  ScaffoldMessenger.of(btnCtx).showSnackBar(
                                    const SnackBar(content: Text('Vui lòng đăng nhập để đăng ký sự kiện')),
                                  );
                                }
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
