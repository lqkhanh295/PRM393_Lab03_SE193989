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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingScreenPadding),
        child: Column(
          children: [
            // Student Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user?.avatarUrl ?? 'https://i.pravatar.cc/150'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Nguyễn Văn An',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'an.nv@fptu.edu.vn',
                    style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.major ?? 'Kỹ thuật Phần mềm (SE18)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 14),
                  ActivityPointsBadge(points: user?.activityPoints ?? 25),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mobile Check-in Desk Switcher
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EBF8),
                borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                border: Border.all(color: AppTheme.primaryContainer.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Chế độ Điểm danh sự kiện tại cổng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        Text('Dành cho Ban tổ chức và Check-in Staff', style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MobileDeskScreen(),
                        ),
                      );
                    },
                    child: const Text('Mở máy quét'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // FIREBASE DEMO AREA (LAB 3 SECTION 3)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.primary, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.cloud_done_rounded, color: AppTheme.primary, size: 22),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'FIREBASE DEMO AREA (LAB 3 CHUẨN)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Khu vực kiểm thử trực tiếp 6 dịch vụ Firebase theo yêu cầu Mục 3 đề cương Lab 3.',
                    style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                  ),
                  const Divider(height: 24),

                  // 1. Cloud Storage Export & Upload
                  const Text('1. Cloud Storage File Upload (reports/{uid}/...)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
                    LinearProgressIndicator(value: profileVM.uploadProgress),
                  ],
                  if (profileVM.lastUploadedUrl != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Download URL:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.success)),
                          SelectableText(
                            profileVM.lastUploadedUrl!,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF1B5E20)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Divider(height: 24),

                  // 2. Cloud Messaging (FCM)
                  const Text('2. Cloud Messaging (FCM Foreground Test)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  AppOutlinedButton(
                    label: 'Mô phỏng nhận Push Notification (FCM)',
                    icon: Icons.notification_add_rounded,
                    onPressed: () {
                      profileVM.triggerDemoPushNotification();
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('Danh sách thông báo gần đây (${fcmService.notifications.length}):', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  ...fcmService.notifications.take(2).map((n) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.surfaceContainer, borderRadius: BorderRadius.circular(8)),
                        child: Text('• ${n.title}: ${n.body}', style: const TextStyle(fontSize: 11)),
                      )),
                  const Divider(height: 24),

                  // 3. Remote Config Toggles
                  const Text('3. Remote Config (max_featured_events & Banner)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  AppOutlinedButton(
                    label: 'Chuyển đổi Remote Config (5 <-> 2 sự kiện)',
                    icon: Icons.tune_rounded,
                    onPressed: () async {
                      await profileVM.toggleRemoteConfigDemo();
                      homeVM.refreshRemoteConfig();
                    },
                  ),
                  const Divider(height: 24),

                  // 4. Crashlytics Error Handling & Crash
                  const Text('4. Crashlytics (Handled Non-fatal & Test Crash)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(color: AppTheme.primary),
                          ),
                          onPressed: () {
                            if (user != null) {
                              profileVM.triggerHandledErrorDemo(user.id);
                            }
                          },
                          child: const Text('Gửi Non-fatal', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.error,
                            side: const BorderSide(color: AppTheme.error),
                          ),
                          onPressed: () {
                            profileVM.triggerTestCrash();
                          },
                          child: const Text('Kích hoạt Crash', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),
                  const Text('5. Cloud Firestore (Khởi tạo & Đồng bộ dữ liệu)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  AppOutlinedButton(
                    label: 'Khởi tạo & Đồng bộ Collections Firestore',
                    icon: Icons.cloud_upload_rounded,
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
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        profileVM.statusMessage!,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign out Button
            AppOutlinedButton(
              label: 'Đăng xuất tài khoản',
              icon: Icons.logout_rounded,
              onPressed: () async {
                await authVM.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
