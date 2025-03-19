import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/models/issue_model.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';
import 'package:smart_community_ai/core/providers/issue_provider.dart';
import 'package:smart_community_ai/core/utils/app_colors.dart';
import 'package:smart_community_ai/core/widgets/custom_app_bar.dart';
import 'package:smart_community_ai/core/widgets/custom_button.dart';
import 'package:smart_community_ai/core/widgets/custom_text_field.dart';
import 'dart:io';

class IssueDetailScreen extends StatefulWidget {
  static const String routeName = '/issue-detail';
  final String issueId;

  const IssueDetailScreen({
    Key? key,
    required this.issueId,
  }) : super(key: key);

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final _commentController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  IssueModel? _issue;

  @override
  void initState() {
    super.initState();
    _loadIssueDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadIssueDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final issueProvider = Provider.of<IssueProvider>(context, listen: false);
      final issue = await issueProvider.getIssueById(widget.issueId);
      
      if (mounted) {
        setState(() {
          _issue = issue;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(String status) async {
    if (_issue == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final issueProvider = Provider.of<IssueProvider>(context, listen: false);
      await issueProvider.updateIssueStatus(widget.issueId, status);
      
      // Yeniden yükle
      await _loadIssueDetails();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Durum başarıyla güncellendi: $status')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Durum güncellenirken hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _addComment() async {
    if (_issue == null || _commentController.text.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final issueProvider = Provider.of<IssueProvider>(context, listen: false);
      await issueProvider.addComment(widget.issueId, _commentController.text);
      
      // Yorumu temizle
      _commentController.clear();
      
      // Yeniden yükle
      await _loadIssueDetails();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorum başarıyla eklendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yorum eklenirken hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.currentUser?.role == 'admin';
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Arıza Detayı',
        showBackButton: true,
        actions: isAdmin && _issue != null
            ? [
                PopupMenuButton<String>(
                  onSelected: _updateStatus,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Beklemede',
                      child: Text('Beklemede'),
                    ),
                    const PopupMenuItem(
                      value: 'İşleniyor',
                      child: Text('İşleniyor'),
                    ),
                    const PopupMenuItem(
                      value: 'Tamamlandı',
                      child: Text('Tamamlandı'),
                    ),
                    const PopupMenuItem(
                      value: 'İptal Edildi',
                      child: Text('İptal Edildi'),
                    ),
                  ],
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Text(
                          'Durum',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            : null,
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
                        onPressed: _loadIssueDetails,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : _issue == null
                  ? const Center(child: Text('Arıza bildirimi bulunamadı'))
                  : _buildIssueDetails(),
    );
  }

  Widget _buildIssueDetails() {
    if (_issue == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIssueHeader(),
          SizedBox(height: 16.h),
          _buildIssueInfo(),
          SizedBox(height: 16.h),
          if (_issue!.images.isNotEmpty) ...[
            _buildImagesSection(),
            SizedBox(height: 16.h),
          ],
          _buildCommentsSection(),
          SizedBox(height: 16.h),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildIssueHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _getCategoryIcon(_issue!.category),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                _issue!.title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(_issue!.status),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                _issue!.status,
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
        if (_issue!.isUrgent)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Acil Durum',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildIssueInfo() {
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
            Text(
              'Açıklama',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _issue!.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16.sp,
                  color: Colors.grey,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Bildirim Tarihi: ${_formatDate(_issue!.createdAt)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16.sp,
                  color: Colors.grey,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Bildiren: ${_issue!.reporter.name}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_issue!.status),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _issue!.status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                if (_issue!.isUrgent)
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
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Görseller',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _issue!.images.length,
            itemBuilder: (context, index) {
              final imagePath = _issue!.images[index];
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: imagePath.startsWith('http')
                    ? Image.network(
                        imagePath,
                        width: 120.w,
                        height: 120.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Görsel yüklenirken hata: $error, Yol: $imagePath');
                          return Container(
                            width: 120.w,
                            height: 120.h,
                            color: Colors.grey[300],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Görsel Yüklenemedi',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Image.file(
                        File(imagePath),
                        width: 120.w,
                        height: 120.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Yerel görsel yüklenirken hata: $error, Yol: $imagePath');
                          return Container(
                            width: 120.w,
                            height: 120.h,
                            color: Colors.grey[300],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Yerel Görsel Yüklenemedi',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yorumlar',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        _issue!.comments.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    'Henüz yorum yapılmamış',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _issue!.comments.length,
                itemBuilder: (context, index) {
                  final comment = _issue!.comments[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                comment.user.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _formatDate(comment.createdAt),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            comment.text,
                            style: TextStyle(
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yorum Ekle',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextField(
          controller: _commentController,
          hintText: 'Yorumunuzu yazın...',
          maxLines: 3,
        ),
        SizedBox(height: 8.h),
        CustomButton(
          text: 'Yorum Ekle',
          onPressed: _isSubmitting ? () {} : () { _addComment(); },
          isLoading: _isSubmitting,
          type: ButtonType.primary,
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return dateString;
    }
  }
} 