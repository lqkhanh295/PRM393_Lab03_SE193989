import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/ticket_model.dart';
import '../theme/app_theme.dart';

/// Pass-Style Digital Ticket Card
/// Anti-Slop Architecture: Perforated pass aesthetics, tabular typography, high-contrast QR.
class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback? onBoostBrightness;

  const TicketCard({
    super.key,
    required this.ticket,
    this.onBoostBrightness,
  });

  @override
  Widget build(BuildContext context) {
    final isCheckedIn = ticket.isCheckedIn;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
      ),
      child: Column(
        children: [
          // Header: Event Title and Status Pill
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Monospace Ticket ID
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
                          ),
                          child: Text(
                            ticket.id,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppTheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCheckedIn ? AppTheme.successSoft : AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
                        border: Border.all(
                          color: isCheckedIn
                              ? AppTheme.successBorder
                              : AppTheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCheckedIn ? Icons.check_circle : Icons.sensors,
                            size: 13,
                            color: isCheckedIn ? AppTheme.successInk : AppTheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isCheckedIn ? 'ĐÃ CHECK-IN' : 'VÉ HỢP LỆ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isCheckedIn ? AppTheme.successInk : AppTheme.onPrimaryContainer,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  ticket.eventTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    height: 1.3,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                // Metadata Rows
                _buildMetaRow(Icons.schedule, '${ticket.eventDate} · ${ticket.eventTime}'),
                const SizedBox(height: 6),
                _buildMetaRow(Icons.place_outlined, ticket.eventLocation),
                const SizedBox(height: 6),
                _buildMetaRow(Icons.person_outline, ticket.studentName),
              ],
            ),
          ),

          // Perforated Divider
          Row(
            children: [
              // Left Notch Cutout
              Container(
                width: 12,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border(
                    top: BorderSide(color: AppTheme.outlineVariant),
                    right: BorderSide(color: AppTheme.outlineVariant),
                    bottom: BorderSide(color: AppTheme.outlineVariant),
                  ),
                ),
              ),
              // Dashed separator line
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final boxWidth = constraints.constrainWidth();
                    const dashWidth = 6.0;
                    const dashSpace = 4.0;
                    final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
                    return Flex(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      direction: Axis.horizontal,
                      children: List.generate(dashCount, (_) {
                        return const SizedBox(
                          width: dashWidth,
                          height: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: AppTheme.outlineVariant),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
              // Right Notch Cutout
              Container(
                width: 12,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  border: Border(
                    top: BorderSide(color: AppTheme.outlineVariant),
                    left: BorderSide(color: AppTheme.outlineVariant),
                    bottom: BorderSide(color: AppTheme.outlineVariant),
                  ),
                ),
              ),
            ],
          ),

          // Lower Segment: QR Matrix View
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(color: AppTheme.outlineVariant, width: 1.5),
                    ),
                    child: QrImageView(
                      data: ticket.qrToken,
                      version: QrVersions.auto,
                      size: 190.0,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppTheme.secondary,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'VÉ OFFLINE TỰ ĐỘNG LƯU TRỮ TRÊN THIẾT BỊ',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
