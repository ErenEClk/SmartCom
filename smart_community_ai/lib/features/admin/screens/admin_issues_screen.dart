import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/models/issue_model.dart';
import 'package:smart_community_ai/core/providers/issue_provider.dart';
import 'package:smart_community_ai/features/admin/screens/admin_issue_detail_screen.dart';
import 'package:smart_community_ai/core/utils/app_colors.dart';
import 'package:smart_community_ai/core/widgets/custom_app_bar.dart';
import 'package:smart_community_ai/core/widgets/custom_button.dart';
import 'package:smart_community_ai/core/widgets/custom_text_field.dart';

class AdminIssuesScreen extends StatefulWidget {
  static const String routeName = '/admin-issues';

  const AdminIssuesScreen({Key? key}) : super(key: key);

  @override
  State<AdminIssuesScreen> createState() => _AdminIssuesScreenState();
}

class _AdminIssuesScreenState extends State<AdminIssuesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tümü';
  final List<String> _categories = [
    'Tümü',
    'Elektrik',
    'Su Tesisatı',
    'Asansör',
    'Bahçe',
    'Spor Salonu',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadIssues();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadIssues() async {
    final issueProvider = Provider.of<IssueProvider>(context, listen: false);
    await issueProvider.fetchIssues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Arıza Yönetimi',
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          labelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.sp,
          ),
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Beklemede'),
            Tab(text: 'İşleniyor'),
            Tab(text: 'Tamamlandı'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.announcement),
            tooltip: 'Arıza Duyurusu Oluştur',
            onPressed: () {
              _showCreateAnnouncementDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _searchController,
                    hintText: 'Arıza ara...',
                    prefixIcon: const Icon(Icons.search),
                    onChanged: (value) {
                      // Arama işlemi
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                DropdownButton<String>(
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                  items: _categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<IssueProvider>(
              builder: (context, issueProvider, child) {
                if (issueProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildIssuesList(issueProvider.issues),
                    _buildIssuesList(issueProvider.getIssuesByStatus('Beklemede')),
                    _buildIssuesList(issueProvider.getIssuesByStatus('İşleniyor')),
                    _buildIssuesList(issueProvider.getIssuesByStatus('Tamamlandı')),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesList(List<dynamic> issues) {
    final filteredIssues = issues.where((issue) {
      final matchesSearch = _searchController.text.isEmpty ||
          issue.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          issue.description.toLowerCase().contains(_searchController.text.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'Tümü' || issue.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();

    if (filteredIssues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build_outlined,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              'Arıza bildirimi bulunamadı',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadIssues,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: filteredIssues.length,
        itemBuilder: (context, index) {
          final issue = filteredIssues[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          issue.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(issue.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          issue.status,
                          style: TextStyle(
                            color: _getStatusColor(issue.status),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _getCategoryIcon(issue.category),
                      SizedBox(width: 8.w),
                      Text(
                        issue.category,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Icon(
                        Icons.access_time,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _formatDate(issue.reportDate),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                      if (issue.isUrgent) ...[
                        SizedBox(width: 16.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.priority_high,
                                size: 12.sp,
                                color: Colors.red,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Acil',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    issue.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Bildiren: ${issue.reportedBy}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Yorum: ${issue.comments.length}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          CustomButton(
                            text: 'Detay',
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/admin-issue-detail',
                                arguments: issue.id,
                              );
                            },
                            type: ButtonType.outline,
                            isFullWidth: false,
                            width: 80.w,
                            height: 36.h,
                          ),
                          SizedBox(width: 8.w),
                          CustomButton(
                            text: 'Durum Değiştir',
                            onPressed: () {
                              _showChangeStatusDialog(issue);
                            },
                            type: ButtonType.primary,
                            isFullWidth: false,
                            width: 120.w,
                            height: 36.h,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
      case 'Su Tesisatı':
        iconData = Icons.water_drop;
        color = Colors.blue;
        break;
      case 'Asansör':
        iconData = Icons.elevator;
        color = Colors.purple;
        break;
      case 'Bahçe':
        iconData = Icons.grass;
        color = Colors.green;
        break;
      case 'Spor Salonu':
        iconData = Icons.fitness_center;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.build;
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 16.sp,
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

  void _showIssueDetailsDialog(dynamic issue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(issue.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(issue.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      issue.status,
                      style: TextStyle(
                        color: _getStatusColor(issue.status),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      issue.category,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (issue.isUrgent) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.priority_high,
                            size: 12.sp,
                            color: Colors.red,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Acil',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                'Açıklama:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                issue.description,
                style: TextStyle(
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Bildirim Tarihi: ${_formatDate(issue.reportDate)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Bildiren: ${issue.reportedBy}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16.h),
              if (issue.images.isNotEmpty) ...[
                Text(
                  'Görseller:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  height: 100.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: issue.images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            issue.images[index],
                            width: 100.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100.w,
                                height: 100.h,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              Text(
                'Yorumlar:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              if (issue.comments.isEmpty)
                Text(
                  'Henüz yorum yapılmamış.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: issue.comments.length,
                  itemBuilder: (context, index) {
                    final comment = issue.comments[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                comment.author,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _formatDate(comment.date),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            comment.text,
                            style: TextStyle(
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              SizedBox(height: 16.h),
              CustomTextField(
                hintText: 'Yorum ekle...',
                maxLines: 3,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    final issueProvider = Provider.of<IssueProvider>(context, listen: false);
                    issueProvider.addComment(issue.id, value);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Yorum başarıyla eklendi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showChangeStatusDialog(dynamic issue) {
    String selectedStatus = issue.status;
    final List<String> statuses = ['Beklemede', 'İşleniyor', 'Tamamlandı', 'İptal Edildi'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Durum Değiştir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mevcut Durum: ${issue.status}'),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Yeni Durum',
                border: OutlineInputBorder(),
              ),
              value: selectedStatus,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  selectedStatus = newValue;
                }
              },
              items: statuses.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedStatus != issue.status) {
                final issueProvider = Provider.of<IssueProvider>(context, listen: false);
                issueProvider.updateIssueStatus(issue.id, selectedStatus);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Durum başarıyla güncellendi'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  // Arıza duyurusu oluşturma diyaloğu
  void _showCreateAnnouncementDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedCategory = 'Diğer';
    bool isUrgent = false;
    final List<String> selectedUsers = []; // Seçilen kullanıcı ID'leri
    bool isAllUsers = true; // Tüm kullanıcılara görünür olsun mu?

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Arıza Duyurusu Oluştur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: titleController,
                  hintText: 'Duyuru Başlığı',
                  labelText: 'Başlık',
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: descriptionController,
                  hintText: 'Duyuru Açıklaması',
                  labelText: 'Açıklama',
                  maxLines: 3,
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Checkbox(
                      value: isUrgent,
                      onChanged: (value) {
                        setState(() {
                          isUrgent = value!;
                        });
                      },
                    ),
                    const Text('Acil Duyuru'),
                  ],
                ),
                SizedBox(height: 16.h),
                const Text(
                  'Duyuruyu Görebilecek Kullanıcılar:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isAllUsers,
                      onChanged: (value) {
                        setState(() {
                          isAllUsers = value!;
                        });
                      },
                    ),
                    const Text('Tüm Kullanıcılar'),
                  ],
                ),
                if (!isAllUsers)
                  const Text(
                    'Not: Şu an test modunda olduğunuz için kullanıcı seçimi devre dışıdır. Gerçek API bağlantısında kullanıcı listesi burada görünecektir.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen başlık ve açıklama alanlarını doldurun'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final issueProvider = Provider.of<IssueProvider>(context, listen: false);
                
                // Tüm kullanıcılar seçiliyse boş liste gönder, değilse seçilen kullanıcıları gönder
                final List<String> visibleToUsers = isAllUsers ? [] : selectedUsers;
                
                final result = await issueProvider.createAnnouncementIssue(
                  titleController.text,
                  descriptionController.text,
                  selectedCategory,
                  isUrgent,
                  visibleToUsers,
                );

                if (result != null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Arıza duyurusu başarıyla oluşturuldu'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Arıza duyurusu oluşturulurken bir hata oluştu: ${issueProvider.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
} 