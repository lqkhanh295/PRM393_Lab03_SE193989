import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// S25: Campus Calendar Screen
class CampusCalendarScreen extends StatelessWidget {
  const CampusCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Lịch biểu Campus'),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tháng 10, 2026',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary),
                      ),
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 12),
                  // Days of week
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text('T2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('T3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('T4', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primary)),
                      Text('T5', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('T6', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('T7', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('CN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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

            Text(
              'Lịch trình hôm nay (28/10/2026)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            // Event Item Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: const Border(left: BorderSide(color: AppTheme.primary, width: 4)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(
                        child: Text(
                          '13:30 - 17:30 · Hội trường Trịnh Công Sơn',
                          style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.check_circle, size: 16, color: AppTheme.success),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bạn đã có vé điện tử hợp lệ (CE2026-083291)',
                    style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            day,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.onSurface,
            ),
          ),
        ),
        if (hasDot) ...[
          const SizedBox(height: 2),
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
          ),
        ] else
          const SizedBox(height: 7),
      ],
    );
  }
}
