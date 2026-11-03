import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/mobile_desk_vm.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

/// EL02: Mobile Gate Check-in Desk & QR Scanner Screen
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
        title: Column(
          children: [
            const Text('Bàn Điểm Danh Cổng', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              'Đã vào: ${deskVM.checkedInCount}/${deskVM.totalCapacity} (${(deskVM.attendanceRate * 100).toInt()}%)',
              style: const TextStyle(color: Color(0xFFD8CFFF), fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
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

          // Viewfinder Overlay Box
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryContainer, width: 3),
                borderRadius: BorderRadius.circular(24),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Hướng camera về phía mã QR vé của sinh viên',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 14),

                // Fast Simulation Buttons (for reviewer/test without physical QR print)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.onSurface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.keyboard, size: 18),
                        label: const Text('Nhập mã tay', style: TextStyle(fontSize: 12)),
                        onPressed: () => _openManualCodeDialog(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.qr_code, size: 18),
                        label: const Text('Quét thử vé 1', style: TextStyle(fontSize: 12)),
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

    if (mounted) {
      _showResultBottomSheet(context, result);
    }
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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSheet)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: result.isValid
                          ? const Color(0xFFE8F5E9)
                          : (result.isDuplicate ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      result.isValid
                          ? Icons.check_circle_rounded
                          : (result.isDuplicate ? Icons.warning_rounded : Icons.error_outline),
                      color: result.isValid
                          ? AppTheme.success
                          : (result.isDuplicate ? AppTheme.error : Colors.amber.shade900),
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result.isValid
                        ? 'CHECK-IN THÀNH CÔNG!'
                        : (result.isDuplicate ? 'CẢNH BÁO VÉ TRÙNG LẶP!' : 'VÉ KHÔNG HỢP LỆ!'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: result.isValid
                          ? AppTheme.success
                          : (result.isDuplicate ? AppTheme.error : Colors.amber.shade900),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.message,
                    style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  if (result.ticket != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Sinh viên: ${result.ticket!.studentName} (${result.ticket!.id})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                  const SizedBox(height: 24),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Nhập mã vé thủ công', style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sử dụng khi camera bị mờ hoặc màn hình điện thoại của sinh viên bị nứt vỡ.',
                  style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
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
              child: const Text('Hủy'),
            ),
            FilledButton(
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
