// lib/views/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'customer/customer_dashboard.dart';
import 'admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleLoginSuccess(BuildContext context, String role) {
    if (role == 'admin') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CustomerDashboard()),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(role == 'admin' ? "Selamat datang kembali Admin!" : "Login berhasil! Selamat datang!"),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 36),

                  // Premium Futsal Logo Area (Clean Corporate Standard)
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.25),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // App Branding (Real Commercial Look)
                  const Text(
                    "FUTSAL RESERVE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Text(
                    "TUPAREV",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      letterSpacing: 5.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Pemesanan Futsal Premium & Jadwal Real-time",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Error Banner
                  if (authProvider.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Circular Progress Loader
                  if (authProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: CircularProgressIndicator(color: AppTheme.primary),
                      ),
                    )
                  else ...[
                    // Authentic Google Sign-In Button
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final success = await authProvider.signInWithGoogle();
                          if (!context.mounted) return;
                          if (success) {
                            _handleLoginSuccess(context, authProvider.currentUser!.role);
                          }
                        },
                        icon: Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png',
                          height: 22,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.g_mobiledata, color: Colors.blue, size: 28);
                          },
                        ),
                        label: const Text(
                          "Masuk dengan Google",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
}
