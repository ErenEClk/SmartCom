import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';
import 'package:smart_community_ai/core/utils/app_colors.dart';
import 'package:smart_community_ai/features/admin/screens/admin_dashboard_screen.dart';
import 'package:smart_community_ai/features/auth/screens/login_screen.dart';
import 'package:smart_community_ai/features/dashboard/screens/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    // 3 saniye sonra giriş kontrolü yap
    Future.delayed(const Duration(seconds: 3), () {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = await authProvider.isAuthenticated();

    if (!mounted) return;

    if (isAuthenticated) {
      final isAdmin = authProvider.currentUser?.role == 'admin';
      if (isAdmin) {
        Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animasyonu
            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.apartment,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Uygulama adı
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'SmartCommunityAI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Slogan
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'Akıllı Site Yönetimi',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Yükleniyor göstergesi
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
} 