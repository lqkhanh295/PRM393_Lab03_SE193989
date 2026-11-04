import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/screen_state.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../main_navigation_screen.dart';

/// S01: Login Screen
/// Supports both Google SSO and FPT University Email/Password Authentication.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                  const SizedBox(height: 28),

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

                  // Email & Password Form for FPT Students
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: _emailController,
                          label: 'Email FPT (@fpt.edu.vn)',
                          hintText: 'an.nv@fpt.edu.vn',
                          prefixIcon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng nhập địa chỉ email FPT';
                            }
                            final clean = val.trim().toLowerCase();
                            if (!clean.endsWith('@fpt.edu.vn') &&
                                !clean.endsWith('@fe.edu.vn') &&
                                !clean.endsWith('@fptu.edu.vn')) {
                              return 'Email phải có đuôi @fpt.edu.vn, @fe.edu.vn hoặc @fptu.edu.vn';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Mật khẩu',
                          hintText: 'Nhập mật khẩu (tối thiểu 6 ký tự)',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 20,
                              color: AppTheme.textMuted,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (val.trim().length < 6) {
                              return 'Mật khẩu phải từ 6 ký tự trở lên';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppPrimaryButton(
                          label: 'Đăng nhập với Email FPT',
                          icon: Icons.login_rounded,
                          isLoading: isLoading,
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final nav = Navigator.of(context);
                              final success = await authVM.signInWithEmailPassword(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                              if (!mounted) return;
                              if (success) {
                                nav.pushReplacement(
                                  MaterialPageRoute(builder: (ctx) => const MainNavigationScreen()),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Divider with "HOẶC"
                  Row(
                    children: const [
                      Expanded(child: Divider(color: AppTheme.hairline, thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'HOẶC TIẾP TỤC VỚI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppTheme.hairline, thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Google SSO Button
                  AppOutlinedButton(
                    label: 'Đăng nhập với Google FPT (@fpt.edu.vn)',
                    icon: Icons.g_mobiledata_rounded,
                    onPressed: isLoading
                        ? null
                        : () async {
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
                  const SizedBox(height: 32),

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
