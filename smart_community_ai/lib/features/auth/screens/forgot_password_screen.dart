import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';
import 'package:smart_community_ai/core/utils/app_colors.dart';
import 'package:smart_community_ai/core/widgets/custom_button.dart';
import 'package:smart_community_ai/core/widgets/custom_text_field.dart';
import 'package:smart_community_ai/features/auth/screens/login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgot-password';

  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _resetSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifremi Unuttum'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLogo(),
                SizedBox(height: 24.h),
                _buildInstructions(),
                SizedBox(height: 24.h),
                if (!_resetSent) ...[
                  _buildEmailField(),
                  SizedBox(height: 24.h),
                  _buildResetButton(),
                ] else ...[
                  _buildSuccessMessage(),
                  SizedBox(height: 24.h),
                  _buildBackToLoginButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Icon(
          Icons.lock_reset,
          size: 80.sp,
          color: AppColors.primary,
        ),
        SizedBox(height: 16.h),
        Text(
          'Şifre Sıfırlama',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Text(
      'Şifrenizi sıfırlamak için kayıtlı e-posta adresinizi girin. Size şifre sıfırlama talimatlarını içeren bir e-posta göndereceğiz.',
      style: TextStyle(
        fontSize: 16.sp,
        color: Colors.grey[700],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      controller: _emailController,
      labelText: 'E-posta',
      hintText: 'E-posta adresinizi girin',
      prefixIcon: const Icon(Icons.email),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'E-posta alanı boş bırakılamaz';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Geçerli bir e-posta adresi girin';
        }
        return null;
      },
    );
  }

  Widget _buildResetButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return CustomButton(
          text: 'Şifremi Sıfırla',
          isLoading: authProvider.isLoading,
          onPressed: () => _resetPassword(authProvider),
        );
      },
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            'Şifre sıfırlama talimatları e-posta adresinize gönderildi.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.green[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Lütfen e-postanızı kontrol edin ve talimatları takip edin.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return CustomButton(
      text: 'Giriş Sayfasına Dön',
      onPressed: () {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      },
    );
  }

  Future<void> _resetPassword(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      
      // Gerçek uygulamada bu metodu AuthProvider içinde oluşturun
      // Şimdilik simüle ediyoruz
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      setState(() {
        _resetSent = true;
      });
      
      // Gerçek uygulamada aşağıdaki gibi olabilir:
      // final success = await authProvider.resetPassword(email);
      // 
      // if (!mounted) return;
      // 
      // if (success) {
      //   setState(() {
      //     _resetSent = true;
      //   });
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text(authProvider.error ?? 'Şifre sıfırlama başarısız'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      // }
    }
  }
} 