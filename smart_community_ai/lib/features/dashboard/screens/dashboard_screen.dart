import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_community_ai/shared/constants/app_constants.dart';
import 'package:smart_community_ai/features/payments/screens/payments_screen.dart';
import 'package:smart_community_ai/features/announcements/screens/announcements_screen.dart';
import 'package:smart_community_ai/features/profile/screens/profile_screen.dart';
import 'package:smart_community_ai/features/messaging/screens/conversations_screen.dart';
import 'package:smart_community_ai/features/surveys/screens/surveys_screen.dart';
import 'package:smart_community_ai/features/notifications/screens/notifications_screen.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/providers/payment_provider.dart';
import 'package:smart_community_ai/core/providers/announcement_provider.dart';
import 'package:smart_community_ai/core/providers/notification_provider.dart';
import 'package:smart_community_ai/core/utils/app_colors.dart';
import 'package:smart_community_ai/features/dashboard/screens/home_screen.dart';
import 'package:smart_community_ai/features/issues/screens/issues_screen.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;
  final List<Widget> _screens = [
    const HomeScreen(),
    const PaymentsScreen(),
    const ConversationsScreen(),
    const ProfileScreen(),
  ];

  void navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // _loadData() doğrudan çağırmak yerine bir sonraki frame'e erteliyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      if (!mounted) return;
      
      setState(() {
        _isLoading = true;
      });
      
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      final announcementProvider = Provider.of<AnnouncementProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

      // Tüm verileri paralel olarak yükle
      await Future.wait([
        paymentProvider.fetchPayments(),
        announcementProvider.fetchAnnouncements(),
        notificationProvider.fetchNotifications(),
      ]);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      
      print('Ana sayfa verileri başarıyla yüklendi');
    } catch (e) {
      print('Ana sayfa verileri yüklenirken hata: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
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
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// Ana sayfa ekranı
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // _loadData() doğrudan çağırmak yerine bir sonraki frame'e erteliyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      if (!mounted) return;
      
      setState(() {
        _isLoading = true;
      });
      
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      final announcementProvider = Provider.of<AnnouncementProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

      // Tüm verileri paralel olarak yükle
      await Future.wait([
        paymentProvider.fetchPayments(),
        announcementProvider.fetchAnnouncements(),
        notificationProvider.fetchNotifications(),
      ]);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      
      print('Ana sayfa verileri başarıyla yüklendi');
    } catch (e) {
      print('Ana sayfa verileri yüklenirken hata: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final announcementProvider = Provider.of<AnnouncementProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCommunityAI'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Bildirimler ekranına git
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              if (notificationProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16.w,
                      minHeight: 16.w,
                    ),
                    child: Text(
                      notificationProvider.unreadCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(context),
                      SizedBox(height: 20.h),
                      _buildQuickActions(context),
                      SizedBox(height: 20.h),
                      _buildRecentAnnouncements(context, announcementProvider),
                      SizedBox(height: 20.h),
                      _buildPaymentSummary(context, paymentProvider),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Merhaba, Ahmet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8.h),
            Text(
              'Yeşil Vadi Sitesi, A Blok, Daire 5',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Bugün',
                  subtitle: '15 Şubat 2025',
                ),
                _buildInfoItem(
                  context,
                  icon: Icons.thermostat,
                  title: 'Sıcaklık',
                  subtitle: '22°C',
                ),
                _buildInfoItem(
                  context,
                  icon: Icons.water_drop,
                  title: 'Nem',
                  subtitle: '%65',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24.sp),
        SizedBox(height: 4.h),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İşlemler',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionButton(
              context,
              icon: Icons.payment,
              label: 'Aidat Öde',
              onTap: () {
                // Ödemeler ekranına git
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PaymentsScreen(),
                  ),
                );
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.message,
              label: 'Mesaj Gönder',
              onTap: () {
                // Mesaj gönder ekranına git
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ConversationsScreen(),
                  ),
                );
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.poll,
              label: 'Anketler',
              onTap: () {
                // Anketler ekranına git
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SurveysScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 75.w,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAnnouncements(BuildContext context, AnnouncementProvider announcementProvider) {
    final recentAnnouncements = announcementProvider.recentAnnouncements;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Duyurular',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // Duyurular ekranına git
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AnnouncementsScreen(),
                  ),
                );
              },
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        recentAnnouncements.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Text(
                    'Duyuru bulunmamaktadır',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentAnnouncements.length,
                itemBuilder: (context, index) {
                  final announcement = recentAnnouncements[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        child: Icon(
                          Icons.announcement,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        announcement.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        announcement.createdAt,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: announcement.isImportant
                          ? const Icon(
                              Icons.priority_high,
                              color: Colors.red,
                            )
                          : null,
                      onTap: () {
                        // Duyurular ekranına git
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AnnouncementsScreen(),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildPaymentSummary(BuildContext context, PaymentProvider paymentProvider) {
    final pendingPayments = paymentProvider.pendingPayments;
    final totalPendingAmount = paymentProvider.totalPendingAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ödeme Özeti',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // Alt navigasyon çubuğundaki Ödemeler sekmesine geç
                (context.findAncestorStateOfType<_DashboardScreenState>()
                        as _DashboardScreenState)
                    ._currentIndex = 1;
              },
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bekleyen Ödemeler',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${pendingPayments.length} adet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Toplam Tutar',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${totalPendingAmount.toStringAsFixed(2)} TL',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: pendingPayments.isEmpty
                        ? null
                        : () {
                            // Ödemeler ekranına git
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PaymentsScreen(),
                              ),
                            );
                          },
                    child: const Text('Öde'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 