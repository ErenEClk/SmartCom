import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';
import 'package:smart_community_ai/core/utils/app_colors.dart';
import 'package:smart_community_ai/core/widgets/custom_button.dart';
import 'package:smart_community_ai/core/widgets/custom_text_field.dart';
import 'package:smart_community_ai/features/auth/screens/login_screen.dart';
import 'package:smart_community_ai/features/notifications/screens/notification_settings_screen.dart';
import 'package:smart_community_ai/features/profile/screens/change_password_screen.dart';
import 'package:smart_community_ai/features/profile/screens/help_support_screen.dart';
import 'package:smart_community_ai/features/profile/screens/about_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _apartmentNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      _apartmentNumberController.text = user.apartmentNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _apartmentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          if (user == null) {
            return const Center(
              child: Text('Kullanıcı bilgileri yüklenemedi'),
            );
          }
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(user.name),
                  SizedBox(height: 24.h),
                  _buildProfileForm(),
                  SizedBox(height: 24.h),
                  if (_isEditing) _buildSaveButton(authProvider),
                  SizedBox(height: 16.h),
                  _buildLogoutButton(authProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String name) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Icon(
              Icons.person,
              size: 60.r,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            name,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kişisel Bilgiler',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _nameController,
          labelText: 'Ad Soyad',
          hintText: 'Ad ve soyadınızı girin',
          prefixIcon: const Icon(Icons.person),
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ad Soyad alanı boş bırakılamaz';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _emailController,
          labelText: 'E-posta',
          hintText: 'E-posta adresinizi girin',
          prefixIcon: const Icon(Icons.email),
          enabled: false, // E-posta değiştirilemez
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _phoneController,
          labelText: 'Telefon',
          hintText: 'Telefon numaranızı girin',
          prefixIcon: const Icon(Icons.phone),
          enabled: _isEditing,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _addressController,
          labelText: 'Adres',
          hintText: 'Adresinizi girin',
          prefixIcon: const Icon(Icons.home),
          enabled: _isEditing,
          maxLines: 2,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _apartmentNumberController,
          labelText: 'Daire No',
          hintText: 'Daire numaranızı girin',
          prefixIcon: const Icon(Icons.apartment),
          enabled: _isEditing,
        ),
      ],
    );
  }

  Widget _buildSaveButton(AuthProvider authProvider) {
    return CustomButton(
      text: 'Değişiklikleri Kaydet',
      isLoading: authProvider.isLoading,
      onPressed: () => _updateProfile(authProvider),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    return CustomButton(
      text: 'Çıkış Yap',
      backgroundColor: Colors.red,
      onPressed: () => _logout(authProvider),
    );
  }

  Future<void> _updateProfile(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      final success = await authProvider.updateUser(
        id: authProvider.currentUser!.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: authProvider.currentUser!.role,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Profil güncellenemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout(AuthProvider authProvider) async {
    await authProvider.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      LoginScreen.routeName,
      (route) => false,
    );
  }
} 