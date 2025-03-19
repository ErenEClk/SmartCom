import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/models/issue_model.dart';
import 'package:smart_community_ai/core/providers/issue_provider.dart';
import 'package:smart_community_ai/core/utils/app_colors.dart';
import 'package:smart_community_ai/core/widgets/custom_app_bar.dart';
import 'package:smart_community_ai/features/issues/screens/create_issue_screen.dart';
import 'package:smart_community_ai/features/issues/screens/issue_detail_screen.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';

class IssuesScreen extends StatefulWidget {
  static const String routeName = '/issues';

  const IssuesScreen({Key? key}) : super(key: key);

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadIssues();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadIssues() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Provider.of<IssueProvider>(context, listen: false).fetchIssues();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
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
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Arıza Bildirimleri',
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          labelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey,
          ),
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Beklemede'),
            Tab(text: 'İşleniyor'),
            Tab(text: 'Tamamlandı'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Hata: $_error'),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadIssues,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadIssues,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildIssuesList(null),
                      _buildIssuesList('Beklemede'),
                      _buildIssuesList('İşleniyor'),
                      _buildIssuesList('Tamamlandı'),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, CreateIssueScreen.routeName);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildIssuesList(String? status) {
    final issueProvider = Provider.of<IssueProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Kullanıcı rolüne göre arızaları getir
    final isAdmin = authProvider.currentUser?.role == 'admin';
    final List<IssueModel> filteredIssues;
    
    if (isAdmin) {
      // Yönetici ise tüm arızaları getir
      filteredIssues = status != null
          ? issueProvider.getIssuesByStatus(status)
          : issueProvider.issues;
    } else {
      // Normal kullanıcı ise sadece kendi arızalarını getir
      final userIssues = issueProvider.getUserIssues(authProvider.currentUser?.id ?? '');
      filteredIssues = status != null
          ? userIssues.where((issue) => issue.status == status).toList()
          : userIssues;
    }

    if (filteredIssues.isEmpty) {
      return Center(
        child: Text(
          status != null
              ? '$status durumunda arıza bildirimi bulunamadı'
              : 'Henüz arıza bildirimi bulunmamaktadır',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: filteredIssues.length,
      itemBuilder: (context, index) {
        return _buildIssueCard(filteredIssues[index]);
      },
    );
  }

  Widget _buildIssueCard(IssueModel issue) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            IssueDetailScreen.routeName,
            arguments: issue.id,
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getCategoryIcon(issue.category),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      issue.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (issue.isUrgent)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'Acil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                issue.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        issue.category,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _formatDate(issue.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Container(
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
                ],
              ),
            ],
          ),
        ),
      ),
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return dateString;
    }
  }
} 