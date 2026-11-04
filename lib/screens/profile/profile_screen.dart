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
                    user?.name ?? 'Chưa đăng nhập',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.obsidian,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (user?.email != null && user!.email.isNotEmpty)
                    Text(
                      user.email,
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
                      user?.major ?? 'Sinh viên FPTU',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.obsidian,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ActivityPointsBadge(points: user?.activityPoints ?? 0),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ==========================================
            // HẬU CẦN PHỤC VỤ SINH VIÊN (LEADER & ADMIN REPOSITIONING)
            // ==========================================
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
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.hairline, width: 1),
                        ),
                        child: const Text(
                          'HẬU CẦN PHỤC VỤ SINH VIÊN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.obsidian,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Định vị kiến trúc: Ứng dụng di động ưu tiên 100% cho Sinh viên. Công cụ điểm danh cửa nằm gọn trong Profile CTV; nghiệp vụ quản trị văn phòng được chuyển lên Web Portal.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
                  const SizedBox(height: 14),

                  // 1. Leader (Ban tổ chức cửa) - Bàn điểm danh cổng 1.5s
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      border: Border.all(color: AppTheme.hairline, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.obsidian,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Bàn Điểm Danh Cổng',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.obsidian,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(3),
                                          border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                                        ),
                                        child: const Text(
                                          '1.5s SCAN',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF92400E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Dành cho Leader / CTV tại cửa hội trường',
                                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mục đích duy nhất: Quét mã vé cho sinh viên bước qua cửa trong 1.5 giây mà không làm tắc nghẽn hàng chờ, cảnh báo vé trùng lập tức.',
                          style: TextStyle(fontSize: 11.5, color: AppTheme.onSurface, height: 1.35),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.obsidian,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => const MobileDeskScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.camera_alt_outlined, size: 16),
                            label: const Text(
                              'Mở Bàn Điểm Danh Cổng (Quét vé)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2. Admin (Phòng CTSV) - Chuyển hẳn lên Web Portal máy tính
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                      border: Border.all(color: AppTheme.hairline, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.hairline, width: 1),
                              ),
                              child: const Icon(
                                Icons.desktop_windows_rounded,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Phòng CTSV — Web Portal',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.obsidian,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(3),
                                          border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                                        ),
                                        child: const Text(
                                          'DESKTOP',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF1D4ED8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Dành cho Chuyên viên CTSV & Ban Quản trị',
                                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Được chuyển hẳn lên Web Portal trên máy tính: Duyệt ngân sách, kiểm tra an toàn PCCC, và xuất file Excel 10.000 sinh viên là tác vụ văn phòng máy tính, không làm trên màn hình điện thoại 6-inch.',
                          style: TextStyle(fontSize: 11.5, color: AppTheme.onSurface, height: 1.35),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.obsidian,
                              side: const BorderSide(color: AppTheme.hairline, width: 1),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () => _showWebPortalInfoModal(context),
                            icon: const Icon(Icons.info_outline_rounded, size: 16),
                            label: const Text(
                              'Xem Cấu Trúc Web Portal CTSV',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
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

  void _showWebPortalInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusCard)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.hairline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.hairline, width: 1),
                    ),
                    child: const Icon(
                      Icons.desktop_windows_rounded,
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
                          'Cổng Quản Trị CTSV (Web Portal)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.obsidian,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Kiến trúc tách biệt tác vụ quản trị văn phòng',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
              const SizedBox(height: 16),

              // Rationale Alert Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.hairline, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'TẠI SAO CHUYỂN HẲN LÊN WEB PORTAL MÁY TÍNH?',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Việc duyệt ngân sách, kiểm tra an toàn PCCC, hay xuất file Excel 10.000 sinh viên là tác vụ văn phòng máy tính, đòi hỏi màn hình lớn, chuột và bàn phím. Không ai làm trên màn hình điện thoại 6-inch để tránh sai sót và không làm loãng app di động của sinh viên.',
                      style: TextStyle(fontSize: 12, color: AppTheme.obsidian, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                '3 Nghiệp vụ Chuyên sâu trên Desktop Web Portal:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.obsidian),
              ),
              const SizedBox(height: 10),

              // 1. Budget
              _buildWebFeatureTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Thẩm định & Duyệt Ngân sách CLB',
                desc: 'Xem bảng dự toán chi tiết nhiều danh mục, kiểm soát hạn mức chi tiêu theo học kỳ.',
              ),
              const SizedBox(height: 8),

              // 2. PCCC
              _buildWebFeatureTile(
                icon: Icons.fire_extinguisher_outlined,
                title: 'Hồ sơ An toàn PCCC & Sức chứa',
                desc: 'Thẩm định phương án thoát hiểm và khống chế hạn mức 1.200 chỗ hội trường Trịnh Công Sơn.',
              ),
              const SizedBox(height: 8),

              // 3. Excel 10,000
              _buildWebFeatureTile(
                icon: Icons.table_chart_outlined,
                title: 'Xuất Báo cáo Excel 10.000 Sinh viên',
                desc: 'Xử lý batch data, trích xuất danh sách điểm danh và Điểm rèn luyện (.xlsx) nộp Ban Giám hiệu.',
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.hairline, width: 1),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.link_rounded, size: 16, color: AppTheme.textMuted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'URL Nội bộ: https://ctsv-portal.fptu.edu.vn',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: AppTheme.obsidian,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.obsidian,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Đã hiểu định vị kiến trúc', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebFeatureTile({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.hairline, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.obsidian),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.obsidian,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
