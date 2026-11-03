import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/ticket_model.dart';
import '../theme/app_theme.dart';

/// Digital Ticket Card with QR Code
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusSheet),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isCheckedIn ? const Color(0xFF2E7D32) : AppTheme.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSheet)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.id,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCheckedIn ? 'ĐÃ CHECK-IN TẠI CỔNG' : 'VÉ HỢP LỆ — SẴN SÀNG QUÉT',
                      style: TextStyle(
                        color: isCheckedIn ? const Color(0xFFC8E6C9) : AppTheme.onPrimaryContainer,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(
                  isCheckedIn ? Icons.verified : Icons.qr_code_2_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),
          ),

          // Event & Student Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.eventTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppTheme.outline),
                    const SizedBox(width: 8),
                    Text('${ticket.eventDate} · ${ticket.eventTime}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppTheme.outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ticket.eventLocation,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: AppTheme.outline),
                    const SizedBox(width: 8),
                    Text(ticket.studentName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(height: 1, thickness: 1, color: AppTheme.surfaceContainer),
                const SizedBox(height: 20),

                // QR View
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.outlineVariant, width: 1.5),
                    ),
                    child: QrImageView(
                      data: ticket.qrToken,
                      version: QrVersions.auto,
                      size: 190.0,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppTheme.primary,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                Center(
                  child: Text(
                    'Mã vé Dynamic QR được lưu trữ ngoại tuyến',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
