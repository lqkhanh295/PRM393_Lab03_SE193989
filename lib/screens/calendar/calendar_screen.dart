import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// S25: Campus Calendar Screen
/// Anti-slop Editorial Academic Agenda: 1px hairline calendar matrix, tabular numbers, clean timeline events.
class CampusCalendarScreen extends StatelessWidget {
  const CampusCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Lịch biểu Campus'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppTheme.hairline),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Month Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.hairline, width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tháng 10, 2026',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.obsidian,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 20),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 20),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
                  const SizedBox(height: 12),
                  // Days of week
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text('T2', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppTheme.textMuted)),
                      Text('T3', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppTheme.textMuted)),
                      Text('T4', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppTheme.primary)),
                      Text('T5', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppTheme.textMuted)),
                      Text('T6', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppTheme.textMuted)),
                      Text('T7', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppTheme.textMuted)),
                      Text('CN', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Highlighted current date row (28 Oct 2026)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDateCell('26', false),
                      _buildDateCell('27', false),
                      _buildDateCell('28', true, hasDot: true), // Today
                      _buildDateCell('29', false),
                      _buildDateCell('30', false, hasDot: true),
                      _buildDateCell('31', false),
                      _buildDateCell('1', false),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'LỊCH TRÌNH HÔM NAY · 28/10/2026',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // Event Item Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.hairline, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '13:30 - 17:30 · Hội trường Trịnh Công Sơn',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.successSoft,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 10, color: AppTheme.successInk),
                            SizedBox(width: 3),
                            Text(
                              'ĐÃ CÓ VÉ',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.successInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(Icons.confirmation_number_outlined, size: 13, color: AppTheme.textMuted),
                      SizedBox(width: 4),
                      Text(
                        'Mã vé: CE2026-083291',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCell(String day, bool isSelected, {bool hasDot = false}) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.obsidian : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            day,
            style: TextStyle(
              fontSize: 13,
              fontFeatures: const [FontFeature.tabularFigures()],
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 3),
        if (hasDot)
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          )
        else
          const SizedBox(height: 4),
      ],
    );
  }
}
