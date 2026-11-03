import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../services/fcm_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/points_badge.dart';
import '../auth/login_screen.dart';
import '../staff/mobile_desk_screen.dart';

/// S27: Student Profile Screen & Mandatory Lab 3 Firebase Demo Area
/// Anti-slop Editorial Profile: flat hairline cards, clean diagnostic terminal for Firebase verification.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().currentUser;
      if (user != null) {
        context.read<ProfileViewModel>().loadProfileCertificates(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final profileVM = context.watch<ProfileViewModel>();
    final homeVM = context.read<HomeViewModel>();
    final fcmService = context.watch<FCMService>();
    final user = authVM.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppTheme.hairline),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
        child: Column(
          children: [
            // Student Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.hairline, width: 1),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.surfaceSubtle,
                    backgroundImage: NetworkImage(user?.avatarUrl ?? 'https://i.pravatar.cc/150'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Nguyễn Văn An',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.obsidian,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'an.nv@fptu.edu.vn',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      user?.major ?? 'Kỹ thuật Phần mềm (SE18)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.obsidian,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ActivityPointsBadge(points: user?.activityPoints ?? 25),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Mobile Check-in Desk Switcher
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.hairline, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      border: Border.all(color: AppTheme.hairline, width: 1),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppTheme.obsidian,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Chế độ Check-in Cổng',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Dành cho Ban tổ chức và Staff điểm danh QR',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.obsidian,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const MobileDeskScreen(),
                        ),
                      );
                    },
                    child: const Text('Mở quét', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // FIREBASE DEMO AREA (LAB 3 SECTION 3)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.hairline, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'FIREBASE LAB 3 TERMINAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.onPrimaryContainer,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kiểm thử trực tiếp 6 dịch vụ Firebase theo tiêu chí đánh giá Mục 3.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
                  const SizedBox(height: 14),

                  // 1. Cloud Storage Export & Upload
                  const Text(
                    '1. Cloud Storage File Upload (reports/{uid}/...)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  AppPrimaryButton(
                    label: 'Xuất chứng nhận PDF & Upload Cloud Storage',
                    icon: Icons.upload_file_rounded,
                    isLoading: profileVM.isUploading,
                    onPressed: () {
                      if (user != null) {
                        profileVM.generateAndUploadPdfSummary(user);
                      }
                    },
                  ),
                  if (profileVM.isUploading) ...[
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: profileVM.uploadProgress,
                      backgroundColor: AppTheme.surfaceSubtle,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ],
                  if (profileVM.lastUploadedUrl != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.successSoft,
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                        border: Border.all(color: AppTheme.successBorder, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Download URL (Storage):',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.successInk),
                          ),
                          const SizedBox(height: 2),
                          SelectableText(
                            profileVM.lastUploadedUrl!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: AppTheme.successInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
                  const SizedBox(height: 14),

                  // 2. Cloud Messaging (FCM)
                  const Text(
                    '2. Cloud Messaging (FCM Foreground Test)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  AppOutlinedButton(
                    label: 'Mô phỏng nhận Push Notification (FCM)',
                    icon: Icons.notifications_none_rounded,
                    onPressed: () {
                      profileVM.triggerDemoPushNotification();
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thông báo gần đây (${fcmService.notifications.length}):',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 4),
                  ...fcmService.notifications.take(2).map(
                        (n) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceSubtle,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.hairline, width: 1),
                          ),
                          child: Text(
                            '• ${n.title}: ${n.body}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.onSurface),
                          ),
                        ),
                      ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
                  const SizedBox(height: 14),

                  // 3. Remote Config Toggles
                  const Text(
                    '3. Remote Config (max_featured_events & Banner)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  AppOutlinedButton(
                    label: 'Chuyển đổi Remote Config (5 <-> 2 sự kiện)',
                    icon: Icons.tune_rounded,
                    onPressed: () async {
                      await profileVM.toggleRemoteConfigDemo();
                      homeVM.refreshRemoteConfig();
                    },
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
                  const SizedBox(height: 14),

                  // 4. Crashlytics Error Handling & Crash
                  const Text(
                    '4. Crashlytics (Handled Non-fatal & Test Crash)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.obsidian,
                            side: const BorderSide(color: AppTheme.hairline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                          ),
                          onPressed: () {
                            if (user != null) {
                              profileVM.triggerHandledErrorDemo(user.id);
                            }
                          },
                          child: const Text(
                            'Gửi Non-fatal',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorInk,
                            side: const BorderSide(color: AppTheme.errorBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                          ),
                          onPressed: () {
                            profileVM.triggerTestCrash();
                          },
                          child: const Text(
                            'Kích hoạt Crash',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
                  const SizedBox(height: 14),

                  // 5. Cloud Firestore
                  const Text(
                    '5. Cloud Firestore (Khởi tạo & Đồng bộ dữ liệu)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  AppOutlinedButton(
                    label: 'Khởi tạo & Đồng bộ Collections Firestore',
                    icon: Icons.cloud_upload_outlined,
                    onPressed: () async {
                      await profileVM.seedFirestoreCollectionsDemo();
                      homeVM.loadHomeScreenData();
                    },
                  ),

                  // Status feedback message
                  if (profileVM.statusMessage != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceSubtle,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.hairline, width: 1),
                      ),
                      child: Text(
                        profileVM.statusMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.obsidian,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sign out Button
            AppOutlinedButton(
              label: 'Đăng xuất tài khoản',
              icon: Icons.logout_rounded,
              onPressed: () async {
                await authVM.signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
