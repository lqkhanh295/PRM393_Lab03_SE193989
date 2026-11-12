import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/screen_state.dart';
import '../../models/certificate_model.dart';
import '../../models/gate_assignment_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/points_badge.dart';
import '../auth/login_screen.dart';
import '../staff/mobile_desk_screen.dart';

/// S27: Student Profile Screen & Mandatory Lab 3 Firebase Demo Area
/// Anti-slop Editorial Profile: flat hairline cards, clean diagnostic terminal for Firebase verification.
/// Task 4 (Đạt): Analytics DebugView 7-event trigger panel + Crashlytics verification controls.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authVM = context.read<AuthViewModel>();
      await authVM.refreshProfile();
      final user = authVM.currentUser;
      if (user != null && mounted) {
        context.read<ProfileViewModel>().loadProfileCertificates(user.id);
        context.read<ProfileViewModel>().loadGateAssignments(user.email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final profileVM = context.watch<ProfileViewModel>();
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
      body: RefreshIndicator(
        onRefresh: () async {
          final auth = context.read<AuthViewModel>();
          final prof = context.read<ProfileViewModel>();
          await auth.refreshProfile();
          final u = auth.currentUser;
          if (u != null && mounted) {
            await prof.loadProfileCertificates(u.id);
            await prof.loadGateAssignments(u.email);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    backgroundImage: NetworkImage(
                      user?.avatarUrl ?? 'https://i.pravatar.cc/150',
                    ),
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
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppTheme.hairline,
                            width: 1,
                          ),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.hairline,
                  ),
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
                  // 1. Leader / CTV: Bàn Điểm Danh Cổng (Phân công ca trực Cloud Firestore)
                  Builder(
                    builder: (ctx) {
                      final assignments = profileVM.gateAssignments;
                      final hasAssignment = assignments.isNotEmpty;
                      final userEmail = user?.email.toLowerCase() ?? '';
                      final isCtsvStaff = userEmail.contains('ctsv') ||
                          userEmail.contains('@fe.edu.vn') ||
                          userEmail == 'quockhoatg2020@gmail.com' ||
                          userEmail == 'lqkhanh292005@gmail.com';

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: hasAssignment
                              ? const Color(0xFFF0FDF4)
                              : AppTheme.surfaceSubtle,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusInput),
                          border: Border.all(
                            color: hasAssignment
                                ? AppTheme.successBorder
                                : AppTheme.hairline,
                            width: 1,
                          ),
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
                                    color: hasAssignment
                                        ? AppTheme.successInk
                                        : AppTheme.obsidian,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 1.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: hasAssignment
                                                  ? AppTheme.successSoft
                                                  : const Color(0xFFFEF3C7),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              border: Border.all(
                                                color: hasAssignment
                                                    ? AppTheme.successBorder
                                                    : const Color(0xFFFDE68A),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              hasAssignment
                                                  ? 'ĐÃ PHÂN CÔNG'
                                                  : (isCtsvStaff
                                                      ? 'CTSV ADMIN'
                                                      : 'CHƯA PHÂN CÔNG'),
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: hasAssignment
                                                    ? AppTheme.successInk
                                                    : const Color(0xFF92400E),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        hasAssignment
                                            ? '${assignments.first.role} • ${assignments.first.gateName}'
                                            : (isCtsvStaff
                                                ? 'Cán bộ CTSV toàn quyền giám sát'
                                                : 'Chỉ CTV được phân công mới có thể quét'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: hasAssignment
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: hasAssignment
                                              ? AppTheme.successInk
                                              : AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (hasAssignment) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppTheme.successBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.event_available_rounded,
                                          size: 14,
                                          color: AppTheme.successInk,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            assignments.first.eventTitle,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.obsidian,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Vị trí: ${assignments.first.gateName} | Ca trực: ${assignments.first.shiftTime}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ] else if (!isCtsvStaff) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFFDE68A),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Tài khoản ${user?.email ?? ''} chưa được phân công ca trực cổng. Vui lòng liên hệ Phòng CTSV để được cấp quyền trên Web Portal.',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF92400E),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: hasAssignment || isCtsvStaff
                                      ? AppTheme.obsidian
                                      : Colors.grey.shade400,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusInput,
                                    ),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () {
                                  if (hasAssignment) {
                                    if (assignments.length == 1) {
                                      final a = assignments.first;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) => MobileDeskScreen(
                                            eventId: a.eventId,
                                            eventTitle: a.eventTitle,
                                            gateName: a.gateName,
                                            staffRole: a.role,
                                          ),
                                        ),
                                      );
                                    } else {
                                      _showDutySelectorBottomSheet(
                                          context, assignments);
                                    }
                                  } else if (isCtsvStaff) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) =>
                                            const MobileDeskScreen(),
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: const Text(
                                            'Chưa Phân Công Ca Trực'),
                                        content: Text(
                                          'Tài khoản ${user?.email ?? ''} hiện chưa có ca trực điểm danh nào được kích hoạt trên Cloud Firestore.\n\nNếu bạn là CTV của CLB, vui lòng liên hệ Cán bộ Phòng CTSV để phân công ca trực tại tab "Phân Công Ca Trực Cổng" trên Web Portal Quản Trị.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(c);
                                              if (user?.email != null) {
                                                profileVM.loadGateAssignments(
                                                    user!.email);
                                              }
                                            },
                                            child: const Text(
                                                'Làm mới kiểm tra lại'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(c),
                                            child: const Text('Đã hiểu'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  hasAssignment || isCtsvStaff
                                      ? Icons.camera_alt_outlined
                                      : Icons.lock_outline_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  hasAssignment
                                      ? 'Mở Bàn Điểm Danh: ${assignments.first.gateName}'
                                      : (isCtsvStaff
                                          ? 'Mở Bàn Điểm Danh (Toàn trường)'
                                          : 'Chưa có phân công ca trực'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
                                border: Border.all(
                                  color: AppTheme.hairline,
                                  width: 1,
                                ),
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFBFDBFE),
                                            width: 1,
                                          ),
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
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Được chuyển hẳn lên Web Portal trên máy tính: Duyệt ngân sách, kiểm tra an toàn PCCC, và xuất file Excel 10.000 sinh viên là tác vụ văn phòng máy tính, không làm trên màn hình điện thoại 6-inch.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.onSurface,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.obsidian,
                              side: const BorderSide(
                                color: AppTheme.hairline,
                                width: 1,
                              ),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusInput,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () => _showWebPortalInfoModal(context),
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                            ),
                            label: const Text(
                              'Xem Cấu Trúc Web Portal CTSV',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
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
            // CHỨNG NHẬN & HOẠT ĐỘNG CỦA TÔI
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppTheme.hairline,
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'CHỨNG NHẬN E-CERTIFICATE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.obsidian,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final certState = profileVM.certificatesState;
                      if (certState is StateLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      final certs =
                          certState is StateData<List<CertificateModel>>
                          ? certState.data
                          : <CertificateModel>[];
                      if (certs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceSubtle,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusInput,
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.workspace_premium_outlined,
                                color: AppTheme.textMuted,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Chưa có e-Certificate. Hãy tham gia sự kiện và gửi đánh giá để nhận chứng nhận có chữ ký số!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: certs
                            .map(
                              (c) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusInput,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.hairline,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppTheme.hairline,
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.workspace_premium_rounded,
                                        color: AppTheme.primary,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.eventTitle,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.obsidian,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Mã số: ${c.verificationHash.length > 16 ? c.verificationHash.substring(0, 16) : c.verificationHash} · ${c.issueDate}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.download_rounded,
                                        size: 20,
                                        color: AppTheme.obsidian,
                                      ),
                                      tooltip: 'Tải / In chứng nhận PDF',
                                      onPressed: () {
                                        profileVM.viewAndDownloadCertificatePdf(c);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // TASK 4 (ĐẠT): BẢNG ĐIỀU KHIỂN CHẨN ĐOÁN LAB 3 (EXPANSION TILE THU GỌN)
            // ==========================================
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.hairline, width: 1),
              ),
              child: Material(
                color: Colors.transparent,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                  initiallyExpanded: false,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  leading: const Icon(Icons.build_circle_outlined, color: AppTheme.textMuted, size: 22),
                  title: const Text(
                    'Bảng điều khiển kiểm định Lab 3',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.obsidian),
                  ),
                  subtitle: const Text(
                    'Analytics 7 events & Crashlytics (dành cho giảng viên / nghiệm thu)',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  children: [
                    _buildAnalyticsTriggerPanel(context, profileVM, user?.id ?? ''),
                    const SizedBox(height: 14),
                    _buildCrashlyticsPanel(context, profileVM),
                  ],
                ),
              ),
            ),),
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
    ),
  );
}

  // ─── TASK 4 (ĐẠT): ANALYTICS 7-EVENT TRIGGER PANEL ──────────────────────────
  /// Renders a card with 7 labeled buttons, one per mandatory Analytics event.
  /// Each button delegates to ProfileViewModel which calls the AnalyticsService.
  /// Strictly zero-PII: event parameters contain only anonymous IDs and counts.
  Widget _buildAnalyticsTriggerPanel(
    BuildContext context,
    ProfileViewModel vm,
    String userId,
  ) {
    return Container(
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
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                ),
                child: const Text(
                  'ANALYTICS DEBUGVIEW — PHỤ LỤC A',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Kích hoạt tuần tự 7 events sau khi bật ADB DebugView. Không có PII trong tham số.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
          ),
          if (vm.statusMessage != null && vm.statusMessage!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.hairline, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.terminal_rounded, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vm.statusMessage!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: AppTheme.obsidian,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
          const SizedBox(height: 12),
          // Event 1 — login
          _buildAnalyticsEventTile(
            index: 1,
            eventName: 'login',
            description: 'Đăng nhập Email FPT · method="email_fpt", role="student"',
            icon: Icons.login_rounded,
            onTap: () => vm.triggerAnalyticsLogin(),
          ),
          _buildAnalyticsEventTile(
            index: 2,
            eventName: 'search',
            description: 'Tìm kiếm sự kiện · search_term="AI", result_count=3',
            icon: Icons.search_rounded,
            onTap: () => vm.triggerAnalyticsSearch(),
          ),
          _buildAnalyticsEventTile(
            index: 3,
            eventName: 'view_item',
            description: 'Xem chi tiết sự kiện · item_id=event_id, category="Technology"',
            icon: Icons.visibility_outlined,
            onTap: () => vm.triggerAnalyticsViewItem(),
          ),
          _buildAnalyticsEventTile(
            index: 4,
            eventName: 'register_event',
            description: 'Đăng ký giữ chỗ 1-chạm · event_id, club_id, duration_s',
            icon: Icons.how_to_reg_outlined,
            onTap: () => vm.triggerAnalyticsRegisterEvent(),
          ),
          _buildAnalyticsEventTile(
            index: 5,
            eventName: 'live_interact',
            description: 'Upvote câu hỏi Live Q&A · action_type="upvote", question_length',
            icon: Icons.favorite_border_rounded,
            onTap: () => vm.triggerAnalyticsLiveInteract(),
          ),
          _buildAnalyticsEventTile(
            index: 6,
            eventName: 'submit_feedback',
            description: 'Đánh giá 5 sao sau sự kiện · rating_stars=5, has_text_comment=1',
            icon: Icons.star_border_rounded,
            onTap: () => vm.triggerAnalyticsSubmitFeedback(),
          ),
          _buildAnalyticsEventTile(
            index: 7,
            eventName: 'export_report',
            description: 'Xuất e-Certificate PDF & upload Storage · export_type="certificate"',
            icon: Icons.file_upload_outlined,
            onTap: () => vm.triggerAnalyticsExportReport(),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsEventTile({
    required int index,
    required String eventName,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSubtle,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.hairline, width: 1),
                  ),
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.obsidian,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.obsidian,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppTheme.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_outline_rounded, size: 18, color: AppTheme.primary),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
      ],
    );
  }

  // ─── TASK 4 (ĐẠT): CRASHLYTICS VERIFICATION PANEL ───────────────────────────
  /// Renders the Crashlytics test card with Non-fatal and Test Crash buttons.
  /// Stack trace: "Simulated Crashlytics Test Crash: Verified in demo mode"
  Widget _buildCrashlyticsPanel(BuildContext context, ProfileViewModel vm) {
    return Container(
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
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFECACA), width: 1),
                ),
                child: const Text(
                  'CRASHLYTICS VERIFICATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF991B1B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Chỉ dùng trên thiết bị kiểm thử đã cấu hình Firebase. Khởi động lại app sau crash để đẩy log lên console.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSubtle,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text(
              'Stack trace: "Simulated Crashlytics Test Crash: Verified in demo mode"',
              style: TextStyle(
                fontSize: 10.5,
                fontFamily: 'monospace',
                color: AppTheme.obsidian,
              ),
            ),
          ),
          const SizedBox(height: 12),
          AppOutlinedButton(
            label: 'Gửi Non-fatal Exception',
            icon: Icons.bug_report_outlined,
            onPressed: () => vm.triggerHandledErrorDemo(),
          ),
          const SizedBox(height: 8),
          AppOutlinedButton(
            label: 'Kích hoạt Test Crash (fatal)',
            icon: Icons.warning_amber_rounded,
            onPressed: vm.triggerTestCrash,
          ),
        ],
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
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusCard),
          ),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.obsidian,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                '3 Nghiệp vụ Chuyên sâu trên Desktop Web Portal:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.obsidian,
                ),
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
                desc: 'Thẩm định phương án thoát hiểm và khống chế hạn mức 400 chỗ hội trường Trịnh Công Sơn.',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.hairline, width: 1),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.link_rounded,
                      size: 16,
                      color: AppTheme.textMuted,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'URL Nội bộ: http://localhost:3000 (Cổng Quản Trị CTSV)',
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
                  child: const Text(
                    'Đã hiểu định vị kiến trúc',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDutySelectorBottomSheet(
    BuildContext context,
    List<GateAssignmentModel> assignments,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSheet)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn Ca Trực Cổng Của Bạn',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Bạn được phân công làm nhiệm vụ điểm danh tại nhiều sự kiện. Vui lòng chọn sự kiện bạn đang trực:',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 14),
            ...assignments.map(
              (a) => ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppTheme.hairline),
                ),
                leading: const Icon(Icons.meeting_room_outlined,
                    color: AppTheme.obsidian),
                title: Text(a.eventTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                subtitle: Text('${a.gateName} • ${a.shiftTime} (${a.role})',
                    style: const TextStyle(fontSize: 11)),
                trailing:
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => MobileDeskScreen(
                        eventId: a.eventId,
                        eventTitle: a.eventTitle,
                        gateName: a.gateName,
                        staffRole: a.role,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
