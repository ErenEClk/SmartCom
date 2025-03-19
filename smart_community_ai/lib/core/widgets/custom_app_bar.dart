import 'package:flutter/material.dart';
import 'package:smart_community_ai/core/utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;
  final String? routeName;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.titleColor,
    this.elevation = 0,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.showBackButton = false,
    this.routeName,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isHomePage = ModalRoute.of(context)?.settings.name == '/dashboard' || 
                           ModalRoute.of(context)?.settings.name == '/admin-dashboard';
    
    final bool shouldShowBackButton = !isHomePage && (showBackButton || automaticallyImplyLeading);
    
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: elevation,
      actions: actions,
      leading: shouldShowBackButton 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            )
          : leading,
      automaticallyImplyLeading: shouldShowBackButton,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom != null 
      ? kToolbarHeight + bottom!.preferredSize.height 
      : kToolbarHeight);
} 