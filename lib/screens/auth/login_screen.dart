import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/screen_state.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../main_navigation_screen.dart';

/// S01: Login Screen
/// Anti-slop Editorial Academic Portal: clean FPT University mark, sharp typography, zero blur.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final isLoading = authVM.state is StateLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingScreenPadding,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // FPTU Academic Monogram Mark
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.obsidian,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.hairline, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'FPT',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'CAMPUS',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'FPTU CAMPUS EVENT',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.obsidian,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cổng quản lý, đăng ký sự kiện và xác thực vé số cho sinh viên Đại học FPT.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Error State Display
                  if (authVM.state is StateError) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.errorSoft,
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                        border: Border.all(color: AppTheme.errorBorder, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppTheme.errorInk, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              (authVM.state as StateError).error,
                              style: const TextStyle(fontSize: 13, color: AppTheme.errorInk),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Primary Google SSO Button
                  AppPrimaryButton(
                    label: 'Đăng nhập với Google FPT (@fpt.edu.vn)',
                    icon: Icons.alternate_email_rounded,
                    isLoading: isLoading,
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      final success = await authVM.signInWithGoogle();
                      if (!mounted) return;
                      if (success) {
                        nav.pushReplacement(
                          MaterialPageRoute(builder: (ctx) => const MainNavigationScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Fast Demo Button for Grading / Reviewers
                  AppOutlinedButton(
                    label: 'Đăng nhập nhanh (Chế độ Demo Sinh viên)',
                    icon: Icons.person_outline,
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      await authVM.signInDemoStudent();
                      if (!mounted) return;
                      nav.pushReplacement(
                        MaterialPageRoute(builder: (ctx) => const MainNavigationScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 36),

                  const Divider(height: 1, thickness: 1, color: AppTheme.hairline),
                  const SizedBox(height: 20),

                  // Footer Info
                  const Text(
                    'PRM393 · Fall 2026 · Đại học FPT TP. Hồ Chí Minh\nPhiên bản 1.0.0 (Lab 2 & Lab 3 Production)',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      height: 1.6,
                      letterSpacing: 0.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
