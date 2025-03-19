import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';
import 'package:smart_community_ai/features/admin/screens/admin_dashboard_screen.dart';
import 'package:smart_community_ai/features/admin/screens/admin_payments_screen.dart';
import 'package:smart_community_ai/features/admin/screens/admin_announcements_screen.dart';
import 'package:smart_community_ai/features/admin/screens/admin_issues_screen.dart';
import 'package:smart_community_ai/features/admin/screens/admin_messaging_screen.dart';
import 'package:smart_community_ai/features/admin/screens/admin_users_screen.dart';

class CustomDrawer extends StatelessWidget {
  final String currentRoute;

  const CustomDrawer({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40.r,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  user?.name ?? 'Yönetici',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? 'admin@example.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Ana Sayfa',
            route: AdminDashboardScreen.routeName,
            isSelected: currentRoute == AdminDashboardScreen.routeName,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.people,
            title: 'Kullanıcılar',
            route: AdminUsersScreen.routeName,
            isSelected: currentRoute == AdminUsersScreen.routeName,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.payment,
            title: 'Ödemeler',
            route: AdminPaymentsScreen.routeName,
            isSelected: currentRoute == AdminPaymentsScreen.routeName,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.announcement,
            title: 'Duyurular',
            route: AdminAnnouncementsScreen.routeName,
            isSelected: currentRoute == AdminAnnouncementsScreen.routeName,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.build,
            title: 'Arıza Bildirimleri',
            route: AdminIssuesScreen.routeName,
            isSelected: currentRoute == AdminIssuesScreen.routeName,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.message,
            title: 'Mesajlar',
            route: AdminMessagingScreen.routeName,
            isSelected: currentRoute == AdminMessagingScreen.routeName,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Çıkış Yap'),
            onTap: () async {
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        if (route != currentRoute) {
          Navigator.pushReplacementNamed(context, route);
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
} 