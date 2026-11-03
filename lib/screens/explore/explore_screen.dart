import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/screen_state.dart';
import '../../viewmodels/explore_viewmodel.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/event_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../events/event_detail_screen.dart';

/// S08: Explore Events Screen with Multi-Category Filter
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exploreVM = context.watch<ExploreViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Khám phá sự kiện'),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingScreenPadding),
            child: AppTextField(
              controller: _searchController,
              label: 'Tìm kiếm sự kiện, CLB, địa điểm...',
              prefixIcon: Icons.search,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        exploreVM.searchEvents(query: '');
                      },
                    )
                  : null,
              onChanged: (val) {
                exploreVM.searchEvents(query: val);
              },
            ),
          ),
          const SizedBox(height: 12),

          // Category Chips Horizontal Scroll
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingScreenPadding),
              itemCount: exploreVM.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = exploreVM.categories[index];
                return AppFilterChip(
                  label: cat,
                  isSelected: exploreVM.selectedCategory == cat,
                  onSelected: (_) => exploreVM.selectCategory(cat),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Results Section
          Expanded(
            child: switch (exploreVM.state) {
              StateInitial() || StateLoading() => const LoadingView(message: 'Đang tìm kiếm sự kiện...'),
              StateEmpty(message: final msg) => EmptyView(
                  message: msg,
                  actionLabel: 'Xóa bộ lọc',
                  onAction: () {
                    _searchController.clear();
                    exploreVM.selectCategory('Tất cả');
                  },
                ),
              StateError(error: final err) => ErrorView(
                  errorMessage: err,
                  onRetry: () => exploreVM.loadExploreData(),
                ),
              StateData(data: final events) => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingScreenPadding),
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
          ),
        ],
      ),
    );
  }
}
