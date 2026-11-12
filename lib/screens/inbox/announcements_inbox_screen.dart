import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/screen_state.dart';
import '../../models/announcement_model.dart';
import '../../viewmodels/inbox_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/empty_view.dart';

/// Màn hình Hộp thư thông báo (Announcements Inbox) của sinh viên.
///
/// Lắng nghe trực tiếp các thông báo phát thanh thời gian thực từ Web Admin Portal,
/// hỗ trợ lọc theo danh mục, hiển thị huy hiệu vai trò người gửi và thông điệp ghim quan trọng.
class AnnouncementsInboxScreen extends StatefulWidget {
  /// Khởi tạo [AnnouncementsInboxScreen].
  const AnnouncementsInboxScreen({super.key});

  /// Tạo state quản lý cập nhật người dùng và ghi nhận analytics khi mở màn hình.
  @override
  State<AnnouncementsInboxScreen> createState() => _AnnouncementsInboxScreenState();
}

class _AnnouncementsInboxScreenState extends State<AnnouncementsInboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().currentUser;
      context.read<InboxViewModel>().updateCurrentUser(user?.id);
      context.read<InboxViewModel>().logOpenInbox();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inboxVM = context.watch<InboxViewModel>();
    final state = inboxVM.state;
    final announcements = inboxVM.filteredAnnouncements;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Hộp thư thông báo'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppTheme.hairline),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả', 'All', inboxVM),
                  const SizedBox(width: 8),
                  _buildFilterChip('Duyệt vé', 'ticket_approved', inboxVM),
                  const SizedBox(width: 8),
                  _buildFilterChip('Khẩn cấp', 'urgent', inboxVM),
                  const SizedBox(width: 8),
                  _buildFilterChip('Nhắc nhở', 'reminder', inboxVM),
                  const SizedBox(width: 8),
                  _buildFilterChip('Chung', 'general', inboxVM),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppTheme.hairline),

          // Content Area with ScreenState
          Expanded(
            child: switch (state) {
              StateLoading() => const LoadingView(message: 'Đang tải thông báo từ máy chủ...'),
              StateError(:final error) => ErrorView(
                  errorMessage: error,
                  onRetry: () => inboxVM.listenToAnnouncements(),
                ),
              StateEmpty(:final message) => EmptyView(message: message),
              StateData() || StateInitial() => announcements.isEmpty
                  ? const EmptyView(message: 'Không có thông báo nào trong mục này.')
                  : RefreshIndicator(
                      onRefresh: () async => inboxVM.listenToAnnouncements(),
                      color: AppTheme.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
                        itemCount: announcements.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = announcements[index];
                          return _buildAnnouncementCard(context, item);
                        },
                      ),
                    ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String categoryKey, InboxViewModel vm) {
    final isSelected = vm.selectedCategory == categoryKey;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppTheme.primary : AppTheme.textMuted,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => vm.setCategory(categoryKey),
      selectedColor: const Color(0xFFFFF4EB),
      backgroundColor: AppTheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : AppTheme.hairline,
          width: 1,
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, AnnouncementModel item) {
    final dateFormat = DateFormat('HH:mm · dd/MM/yyyy');
    final formattedTime = dateFormat.format(item.createdAt);

    Color tagColor = AppTheme.primary;
    Color tagBg = const Color(0xFFFFF4EB);
    String tagLabel = 'THÔNG BÁO';

    if (item.category == 'ticket_approved') {
      tagColor = AppTheme.successInk;
      tagBg = AppTheme.successSoft;
      tagLabel = 'DUYỆT VÉ THÀNH CÔNG';
    } else if (item.category == 'urgent') {
      tagColor = AppTheme.error;
      tagBg = const Color(0xFFFFEBEE);
      tagLabel = 'KHẨN CẤP';
    } else if (item.category == 'reminder') {
      tagColor = const Color(0xFFF57C00);
      tagBg = const Color(0xFFFFF3E0);
      tagLabel = 'NHẮC NHỞ';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: item.isPinned ? AppTheme.primary.withValues(alpha: 0.4) : AppTheme.hairline,
          width: item.isPinned ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category tag + Pinned badge + Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tagLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: tagColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (item.isPinned) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.push_pin, size: 10, color: AppTheme.primary),
                            SizedBox(width: 2),
                            Text(
                              'GHIM',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.obsidian,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            // Content
            Text(
              item.content,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.onSurface,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),

            // Author footer
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 13, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  'Phát thanh bởi: ${item.authorRole == 'organizer' ? 'Ban Tổ Chức CLB' : 'Phòng CTSV'}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
