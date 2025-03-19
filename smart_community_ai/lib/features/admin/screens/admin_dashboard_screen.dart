import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';
import 'package:smart_community_ai/core/utils/app_colors.dart';
import 'package:smart_community_ai/core/widgets/custom_app_bar.dart';
import 'package:smart_community_ai/features/admin/screens/admin_announcements_screen.dart';
import 'package:smart_community_ai/features/admin/screens/admin_issues_screen.dart';
import 'package:smart_community_ai/features/admin/screens/admin_messaging_screen.dart';
import 'package:smart_community_ai/features/admin/screens/admin_payments_screen.dart';
import 'package:smart_community_ai/features/admin/screens/admin_users_screen.dart';
import 'package:smart_community_ai/features/surveys/screens/admin_surveys_screen.dart';
import 'package:smart_community_ai/features/auth/screens/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const String routeName = '/admin-dashboard';

  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const AdminHomeScreen(),
    const AdminAnnouncementsScreen(),
    const AdminPaymentsScreen(),
    const AdminMessagingScreen(),
    const AdminUsersScreen(),
    const AdminSurveysScreen(),
  ];

  final List<String> _titles = [
    'Yönetici Paneli',
    'Duyurular',
    'Ödemeler',
    'Mesajlar',
    'Kullanıcılar',
    'Anketler',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _titles[_currentIndex],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Duyurular',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Ödemeler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mesajlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Kullanıcılar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.poll),
            label: 'Anketler',
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }
}

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(context),
          SizedBox(height: 24.h),
          _buildStatisticsSection(context),
          SizedBox(height: 24.h),
          _buildQuickActionsSection(context),
          SizedBox(height: 24.h),
          _buildRecentActivitiesSection(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: AppColors.primary,
              child: Text(
                user?.name.substring(0, 1) ?? 'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş Geldiniz,',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user?.name ?? 'Yönetici',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Site Yöneticisi',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Çevrimiçi',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genel İstatistikler',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Toplam Kullanıcı',
                '124',
                Icons.people,
                Colors.blue,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                context,
                'Toplam Duyurular',
                '12',
                Icons.announcement,
                Colors.purple,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Bekleyen Ödemeler',
                '32',
                Icons.payment,
                Colors.red,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                context,
                'Okunmamış Mesajlar',
                '8',
                Icons.message,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İşlemler',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Duyuru Yönetimi',
                Icons.announcement,
                Colors.purple,
                () {
                  Navigator.pushNamed(context, AdminAnnouncementsScreen.routeName);
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildActionCard(
                context,
                'Ödeme Yönetimi',
                Icons.payment,
                Colors.green,
                () {
                  Navigator.pushNamed(context, AdminPaymentsScreen.routeName);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Kullanıcı Yönetimi',
                Icons.people,
                Colors.orange,
                () {
                  Navigator.pushNamed(context, AdminUsersScreen.routeName);
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildActionCard(
                context,
                'Mesajlar',
                Icons.message,
                Colors.blue,
                () {
                  Navigator.pushNamed(context, AdminMessagingScreen.routeName);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Aktiviteler',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Tüm aktiviteleri görüntüle
              },
              child: Text(
                'Tümünü Gör',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[300],
            ),
            itemBuilder: (context, index) {
              return _buildActivityItem(context, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, int index) {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'Yeni duyuru eklendi',
        'description': 'Site yönetimi yeni bir duyuru yayınladı',
        'time': '10 dakika önce',
        'icon': Icons.announcement,
        'color': Colors.purple,
      },
      {
        'title': 'Ödeme yapıldı',
        'description': 'Ayşe Demir aidat ödemesini tamamladı',
        'time': '1 saat önce',
        'icon': Icons.payment,
        'color': Colors.green,
      },
      {
        'title': 'Yeni mesaj',
        'description': 'Ahmet Yılmaz yeni bir mesaj gönderdi',
        'time': '3 saat önce',
        'icon': Icons.message,
        'color': Colors.blue,
      },
      {
        'title': 'Ödeme hatırlatması',
        'description': 'Ödeme hatırlatma bildirimleri gönderildi',
        'time': '5 saat önce',
        'icon': Icons.notifications,
        'color': Colors.orange,
      },
      {
        'title': 'Yeni kullanıcı',
        'description': 'Mehmet Kaya sisteme kaydoldu',
        'time': '1 gün önce',
        'icon': Icons.person_add,
        'color': Colors.indigo,
      },
    ];

    final activity = activities[index];

    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: activity['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          activity['icon'],
          color: activity['color'],
          size: 24.sp,
        ),
      ),
      title: Text(
        activity['title'],
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        activity['description'],
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey[600],
        ),
      ),
      trailing: Text(
        activity['time'],
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey,
        ),
      ),
      onTap: () {
        // Aktivite detayına git
      },
    );
  }
} 