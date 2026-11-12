import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';

/// Thẻ hiển thị sự kiện dạng khối biên tập (Editorial Campus Event Card).
///
/// Thể hiện ảnh bìa tỷ lệ 16:9, nhãn phân loại, huy hiệu trạng thái (Đang mở ĐK, Hết chỗ, Đã kết thúc),
/// tiêu đề sự kiện, tên câu lạc bộ chủ trì cùng lưới thông tin thời gian - địa điểm trực quan.
class EventGlassCard extends StatelessWidget {
  /// Dữ liệu sự kiện [EventModel].
  final EventModel event;

  /// Hàm gọi lại khi người dùng bấm vào thẻ sự kiện để chuyển sang trang chi tiết.
  final VoidCallback onTap;

  /// Khởi tạo [EventGlassCard] với sự kiện [event] và sự kiện bấm [onTap].
  const EventGlassCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  /// Xây dựng giao diện thẻ sự kiện.
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sự kiện ${event.title}, câu lạc bộ ${event.clubName}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: AppTheme.outlineVariant, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashColor: AppTheme.primaryContainer,
              highlightColor: AppTheme.surfaceContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Image with Category Tag and Capacity Indicator
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          event.bannerUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppTheme.surfaceContainer,
                            child: const Center(
                              child: Icon(Icons.calendar_month_outlined, size: 40, color: AppTheme.textSubtle),
                            ),
                          ),
                        ),
                      ),
                      // Top Row Overlay: Category & Seat Status
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Category Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xCC0F172A), // 80% Obsidian
                                borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
                              ),
                              child: Text(
                                event.category.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            // Spot Availability Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: event.isPast
                                    ? AppTheme.surfaceContainer
                                    : (event.isFull ? AppTheme.errorSoft : AppTheme.successSoft),
                                borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
                                border: Border.all(
                                  color: event.isPast
                                      ? AppTheme.outlineVariant
                                      : (event.isFull ? AppTheme.errorBorder : AppTheme.successBorder),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                event.isPast
                                    ? '${event.registeredCount}/${event.capacity} ĐÃ ĐK'
                                    : (event.isFull ? 'HẾT CHỖ' : 'CÒN ${event.spotsRemaining} CHỖ'),
                                style: TextStyle(
                                  color: event.isPast
                                      ? AppTheme.textMuted
                                      : (event.isFull ? AppTheme.errorInk : AppTheme.successInk),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Event Details Body
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingCardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Club attribution line
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.clubName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMuted,
                                  letterSpacing: 0.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (event.isPast)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppTheme.outlineVariant, width: 1),
                                ),
                                child: const Text(
                                  'ĐÃ KẾT THÚC',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              )
                            else if (event.isFull)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorSoft,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'HẾT CHỖ',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.errorInk,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'ĐANG MỞ ĐK',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            height: 1.3,
                            color: AppTheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // Time & Location Grid
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule, size: 14, color: AppTheme.textMuted),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '${event.time} · ${event.date}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 12,
                                color: AppTheme.outlineVariant,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              const Icon(Icons.place_outlined, size: 14, color: AppTheme.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  event.location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
