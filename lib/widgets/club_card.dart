import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/club_model.dart';
import '../theme/app_theme.dart';

/// ClubCard Widget
/// Clean Anti-slop Editorial card presenting an official FPTU Club profile.
class ClubCard extends StatelessWidget {
  final ClubModel club;
  final VoidCallback? onTap;

  const ClubCard({
    super.key,
    required this.club,
    this.onTap,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return const Color(0xFF2563EB); // Royal Blue
      case 'sports':
        return const Color(0xFF059669); // Emerald
      case 'media':
        return const Color(0xFFD97706); // Amber
      case 'arts':
        return const Color(0xFF7C3AED); // Purple
      case 'languages':
      case 'skills':
        return const Color(0xFF0891B2); // Cyan
      case 'community':
        return const Color(0xFFDC2626); // Crimson
      case 'business':
        return const Color(0xFF4F46E5); // Indigo
      default:
        return AppTheme.primary;
    }
  }

  void _showClubDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusCard)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header indicator
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Title and Acronym
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(club.category).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getCategoryColor(club.category).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        (club.acronym ?? club.name).characters.take(3).toString().toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: _getCategoryColor(club.category),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.obsidian,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(club.category).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                club.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _getCategoryColor(club.category),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.people_outline, size: 14, color: AppTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              '${club.followerCount} theo dõi',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Description
              Text(
                club.description,
                style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
              const SizedBox(height: 12),

              // Links List
              if (club.officialUrl != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.public, color: AppTheme.primary, size: 20),
                  title: const Text('Hồ sơ chính thức (FPTU)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(club.officialUrl!, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    tooltip: 'Sao chép liên kết',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: club.officialUrl!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã sao chép liên kết hồ sơ FPTU')),
                      );
                    },
                  ),
                ),

              if (club.fanpageUrl != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 20),
                  title: const Text('Fanpage / Nền tảng Cộng đồng', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(club.fanpageUrl!, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    tooltip: 'Sao chép liên kết',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: club.fanpageUrl!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã sao chép liên kết Fanpage')),
                      );
                    },
                  ),
                ),

              if (club.email != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.email_outlined, color: AppTheme.obsidian, size: 20),
                  title: const Text('Email liên hệ chính thức', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(club.email!, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    tooltip: 'Sao chép Email',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: club.email!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã sao chép email liên hệ')),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppTheme.hairline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput)),
                  ),
                  child: const Text('Đóng', style: TextStyle(color: AppTheme.obsidian)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(club.category);

    return InkWell(
      onTap: onTap ?? () => _showClubDetails(context),
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: AppTheme.hairline, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Monogram, Name & Acronym, Category
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monogram Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: catColor.withValues(alpha: 0.25), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      (club.acronym ?? club.name).characters.take(3).toString().toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: catColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Acronym
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              club.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.obsidian,
                                height: 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (club.acronym != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.hairline, width: 0.8),
                              ),
                              child: Text(
                                club.acronym!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.obsidian,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                club.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: catColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.people_outline, size: 13, color: AppTheme.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              '${club.followerCount}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                            if (club.email != null) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.email_outlined, size: 13, color: AppTheme.textSubtle),
                            ],
                            if (club.fanpageUrl != null) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.facebook, size: 13, color: Color(0xFF1877F2)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              club.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.onSurfaceVariant,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

