import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/screen_state.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/event_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/points_badge.dart';
import '../../widgets/app_icon_button.dart';
import '../../viewmodels/inbox_viewmodel.dart';
import '../events/event_detail_screen.dart';
import '../inbox/announcements_inbox_screen.dart';

/// S07: Home Campus Pulse Screen
/// Anti-Slop Architecture: High typographic contrast, hairline rules, zero fuzzy blur.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        titleSpacing: AppTheme.spacingScreenPadding,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.outlineVariant, width: 1.5),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.surfaceContainer,
                backgroundImage: NetworkImage(user?.avatarUrl ?? 'https://i.pravatar.cc/100'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user != null ? 'Chào ${user.name.split(' ').last} 👋' : 'Chào bạn!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: AppTheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user?.major ?? 'Sinh viên FPTU',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActivityPointsBadge(points: user.activityPoints),
            ),
          Consumer<InboxViewModel>(
            builder: (context, inboxVM, child) {
              final unread = inboxVM.unreadCount;
              return Stack(
                children: [
                  AppIconButton(
                    icon: Icons.notifications_none_rounded,
                    tooltip: 'Hộp thư thông báo',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnnouncementsInboxScreen(),
                        ),
                      );
                    },
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => homeVM.loadHomeScreenData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingScreenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Remote Config Dynamic Broadcast Banner (Flat, High Contrast)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(color: const Color(0xFF1E293B), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'TIN NÓNG CAMPUS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'TOP ${homeVM.maxFeatured} NỔI BẬT',
                            style: const TextStyle(
                              color: AppTheme.textSubtle,
                              fontSize: 10,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      homeVM.bannerTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sự kiện nổi bật',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  InkWell(
                    onTap: () => homeVM.loadHomeScreenData(),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'Làm mới',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Explicit States Rendering
              switch (homeVM.state) {
                StateInitial() || StateLoading() => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: LoadingView(message: 'Đang tải sự kiện nổi bật...'),
                  ),
                StateEmpty(message: final msg) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: EmptyView(
                      message: msg,
                      actionLabel: 'Tải lại',
                      onAction: () => homeVM.loadHomeScreenData(),
                    ),
                  ),
                StateError(error: final err) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: ErrorView(
                      errorMessage: err,
                      onRetry: () => homeVM.loadHomeScreenData(),
                    ),
                  ),
                StateData(data: final events) => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventGlassCard(
                        event: event,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailScreen(eventId: event.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
              },

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
