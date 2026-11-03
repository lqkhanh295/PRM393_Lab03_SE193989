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
import '../events/event_detail_screen.dart';

/// S07: Home Campus Pulse Screen
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
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(user?.avatarUrl ?? 'https://i.pravatar.cc/100'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user != null ? 'Chào ${user.name.split(' ').last} 👋' : 'Chào bạn!',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user?.major ?? 'Kỹ thuật Phần mềm (SE)',
                    style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
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
          AppIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Thông báo',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mở trung tâm thông báo (FCM)')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => homeVM.loadHomeScreenData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingScreenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Remote Config Dynamic Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TIN NÓNG CAMPUS',
                      style: TextStyle(
                        color: Color(0xFFD8CFFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      homeVM.bannerTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Đang hiển thị top ${homeVM.maxFeatured} sự kiện nổi bật',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sự kiện nổi bật',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {
                      homeVM.loadHomeScreenData();
                    },
                    child: const Text('Làm mới'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
