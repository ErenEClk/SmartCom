import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/models/issue_model.dart';
import 'package:smart_community_ai/core/providers/announcement_provider.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';
import 'package:smart_community_ai/core/providers/issue_provider.dart';
import 'package:smart_community_ai/core/providers/notification_provider.dart';
import 'package:smart_community_ai/core/providers/payment_provider.dart';
import 'package:smart_community_ai/core/utils/app_colors.dart';
import 'package:smart_community_ai/core/widgets/custom_app_bar.dart';
import 'package:smart_community_ai/features/issues/screens/issue_detail_screen.dart';
import 'package:smart_community_ai/features/notifications/screens/notifications_screen.dart';
import 'package:smart_community_ai/features/issues/screens/create_issue_screen.dart';
import 'package:smart_community_ai/features/payments/screens/payment_screen.dart';
import 'package:smart_community_ai/features/profile/screens/profile_screen.dart';
import 'package:smart_community_ai/features/dashboard/screens/dashboard_screen.dart';
import 'package:smart_community_ai/features/messaging/screens/messaging_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      final announcementProvider = Provider.of<AnnouncementProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      final issueProvider = Provider.of<IssueProvider>(context, listen: false);

      // Tüm verileri paralel olarak yükle
      await Future.wait([
        paymentProvider.fetchPayments(),
        announcementProvider.fetchAnnouncements(),
        notificationProvider.fetchNotifications(),
        issueProvider.fetchIssues(),
      ]);
    } catch (e) {
      print('Ana sayfa verileri yüklenirken hata: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Akıllı Site',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(user),
                    SizedBox(height: 16.h),
                    _buildQuickActions(),
                    SizedBox(height: 16.h),
                    _buildRecentPayments(),
                    SizedBox(height: 16.h),
                    _buildRecentAnnouncements(),
                    SizedBox(height: 16.h),
                    _buildRecentIssues(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeCard(dynamic user) {
    final now = DateTime.now();
    final hour = now.hour;
    
    String greeting;
    if (hour < 12) {
      greeting = 'Günaydın';
    } else if (hour < 18) {
      greeting = 'İyi günler';
    } else {
      greeting = 'İyi akşamlar';
    }
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, ${user?.name ?? 'Değerli Sakin'}',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            user?.residence != null
                ? '${user!.residence!.site} - ${user.residence!.block} Blok, No: ${user.residence!.apartment}'
                : 'Hoş geldiniz',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '${now.day}.${now.month}.${now.year}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
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
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Arıza Bildir',
                icon: Icons.report_problem,
                color: Colors.orange,
                onTap: () {
                  Navigator.pushNamed(context, CreateIssueScreen.routeName);
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildActionCard(
                title: 'Ödeme Yap',
                icon: Icons.payment,
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, PaymentScreen.routeName);
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
                title: 'Mesajlar',
                icon: Icons.message,
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, MessagingScreen.routeName);
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildActionCard(
                title: 'Profil',
                icon: Icons.person,
                color: Colors.purple,
                onTap: () {
                  Navigator.pushNamed(context, ProfileScreen.routeName);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentIssues() {
    final issueProvider = Provider.of<IssueProvider>(context);
    final issues = issueProvider.issues.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Arıza Bildirimleri',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Ana ekranda arıza bildirimleri sekmesine geç
                Navigator.pushNamed(context, '/issues');
              },
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        issues.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    'Henüz arıza bildirimi bulunmamaktadır',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: issues.length,
                itemBuilder: (context, index) {
                  final issue = issues[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: ListTile(
                      leading: _getCategoryIcon(issue.category),
                      title: Text(
                        issue.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${issue.status} • ${_formatDate(issue.createdAt)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(issue.status),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          issue.status,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          IssueDetailScreen.routeName,
                          arguments: issue.id,
                        );
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData iconData;
    Color color;

    switch (category) {
      case 'Elektrik':
        iconData = Icons.electrical_services;
        color = Colors.yellow[700]!;
        break;
      case 'Su':
        iconData = Icons.water_drop;
        color = Colors.blue;
        break;
      case 'Isıtma':
        iconData = Icons.whatshot;
        color = Colors.orange;
        break;
      case 'Asansör':
        iconData = Icons.elevator;
        color = Colors.purple;
        break;
      case 'Güvenlik':
        iconData = Icons.security;
        color = Colors.red;
        break;
      case 'Temizlik':
        iconData = Icons.cleaning_services;
        color = Colors.green;
        break;
      default:
        iconData = Icons.build;
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 24.sp,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Beklemede':
        return Colors.orange;
      case 'İşleniyor':
        return Colors.blue;
      case 'Tamamlandı':
        return Colors.green;
      case 'İptal Edildi':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic dateInput) {
    try {
      if (dateInput is DateTime) {
        return '${dateInput.day.toString().padLeft(2, '0')}.${dateInput.month.toString().padLeft(2, '0')}.${dateInput.year}';
      } else if (dateInput is String) {
        final date = DateTime.parse(dateInput);
        return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
      } else {
        return 'Geçersiz tarih';
      }
    } catch (e) {
      return dateInput.toString();
    }
  }

  Widget _buildRecentPayments() {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final payments = paymentProvider.payments.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Ödemeler',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Ana ekranda ödemeler sekmesine geç
                Navigator.pushNamed(context, '/payments');
              },
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        payments.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    'Henüz ödeme bulunmamaktadır',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: payment.isPaid
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          payment.isPaid ? Icons.check_circle : Icons.pending,
                          color: payment.isPaid ? Colors.green : Colors.red,
                          size: 24.sp,
                        ),
                      ),
                      title: Text(
                        payment.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${payment.amount} TL • ${_formatDate(payment.dueDate)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: payment.isPaid
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'Ödendi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                // Ödeme ekranına git
                                Navigator.pushNamed(
                                  context,
                                  PaymentScreen.routeName,
                                  arguments: payment.id,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 4.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                              child: Text(
                                'Öde',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      onTap: () {
                        // Ödeme detayına git
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildRecentAnnouncements() {
    final announcementProvider = Provider.of<AnnouncementProvider>(context);
    final announcements = announcementProvider.announcements.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Duyurular',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Duyurular ekranına git
              },
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        announcements.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    'Henüz duyuru bulunmamaktadır',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final announcement = announcements[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.announcement,
                          color: Colors.blue,
                          size: 24.sp,
                        ),
                      ),
                      title: Text(
                        announcement.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        _formatDate(announcement.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        // Duyuru detayına git
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }
} 