import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/mobile_desk_vm.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

/// EL02: Mobile Gate Check-in Desk & QR Scanner Screen
/// Staff Tooling HUD: high-contrast reticle, tabular figures, instant validation feedback.
class MobileDeskScreen extends StatefulWidget {
  const MobileDeskScreen({super.key});

  @override
  State<MobileDeskScreen> createState() => _MobileDeskScreenState();
}

class _MobileDeskScreenState extends State<MobileDeskScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final TextEditingController _manualCodeController = TextEditingController();
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MobileDeskViewModel>().loadEventStats('EVT-2026-01');
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deskVM = context.watch<MobileDeskViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFF262626)),
        ),
        title: Column(
          children: [
            const Text(
              'Bàn Điểm Danh Cổng',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              'Đã vào: ${deskVM.checkedInCount}/${deskVM.totalCapacity} (${(deskVM.attendanceRate * 100).toInt()}%)',
              style: const TextStyle(
                color: Color(0xFFA1A1AA),
                fontSize: 11,
                fontFeatures: [FontFeature.tabularFigures()],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? const Color(0xFFFBBF24) : Colors.white,
            ),
            tooltip: 'Đèn Flash',
            onPressed: () {
              _scannerController.toggleTorch();
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Viewfinder
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _onScanDetected(context, barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // Viewfinder Overlay Reticle
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'SCAN AREA',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Bar Actions
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF27272A), width: 1),
                  ),
                  child: const Text(
                    'Quét mã QR vé 1.5s — Hậu cần giải tỏa hàng chờ cửa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Fast Simulation Buttons (for reviewer/test without physical QR print)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.obsidian,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.keyboard_outlined, size: 18),
                        label: const Text(
                          'Nhập mã tay',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => _openManualCodeDialog(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.qr_code, size: 18),
                        label: const Text(
                          'Quét thử vé 1',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () {
                          _onScanDetected(context, 'QR-TOKEN-CE2026-083291-SECURE-HASH');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onScanDetected(BuildContext context, String rawToken) async {
    final deskVM = context.read<MobileDeskViewModel>();
    if (deskVM.isProcessing) return;

    final result = await deskVM.processCheckInScan(
      qrToken: rawToken,
      eventId: 'EVT-2026-01',
    );

    if (!context.mounted) return;
    _showResultBottomSheet(context, result);
  }

  void _showResultBottomSheet(BuildContext context, CheckInValidationResult result) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSheet)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: result.isValid
                          ? AppTheme.successSoft
                          : (result.isDuplicate ? AppTheme.errorSoft : const Color(0xFFFEF3C7)),
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      border: Border.all(
                        color: result.isValid
                            ? AppTheme.successBorder
                            : (result.isDuplicate ? AppTheme.errorBorder : const Color(0xFFFDE68A)),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      result.isValid
                          ? Icons.check_circle_outline_rounded
                          : (result.isDuplicate ? Icons.warning_amber_rounded : Icons.error_outline),
                      color: result.isValid
                          ? AppTheme.successInk
                          : (result.isDuplicate ? AppTheme.errorInk : const Color(0xFFB45309)),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result.isValid
                        ? 'CHECK-IN THÀNH CÔNG'
                        : (result.isDuplicate ? 'CẢNH BÁO VÉ TRÙNG LẶP' : 'VÉ KHÔNG HỢP LỆ'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: result.isValid
                          ? AppTheme.successInk
                          : (result.isDuplicate ? AppTheme.errorInk : const Color(0xFFB45309)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.message,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  if (result.ticket != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceSubtle,
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                        border: Border.all(color: AppTheme.hairline, width: 1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            result.ticket!.studentName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mã vé: ${result.ticket!.id}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppPrimaryButton(
                          label: 'Quét người tiếp theo',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      if (result.isDuplicate) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppOutlinedButton(
                            label: 'Nhập mã tay',
                            onPressed: () {
                              Navigator.pop(context);
                              _openManualCodeDialog(context);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openManualCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
          title: const Text(
            'Nhập mã vé thủ công',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sử dụng khi camera bị mờ hoặc màn hình điện thoại của sinh viên bị nứt vỡ.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _manualCodeController,
                  label: 'Mã Ticket ID',
                  hintText: 'Ví dụ: CE2026-083291',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.obsidian,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                ),
              ),
              onPressed: () {
                final code = _manualCodeController.text.trim();
                Navigator.pop(context);
                if (code.isNotEmpty) {
                  _onScanDetected(context, code);
                }
              },
              child: const Text('Xác thực'),
            ),
          ],
        );
      },
    );
  }
}
