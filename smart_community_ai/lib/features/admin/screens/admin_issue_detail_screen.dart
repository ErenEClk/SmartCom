import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/models/issue_model.dart';
import 'package:smart_community_ai/core/providers/issue_provider.dart';
import 'dart:io';

class AdminIssueDetailScreen extends StatefulWidget {
  final String issueId;

  const AdminIssueDetailScreen({
    super.key,
    required this.issueId,
  });

  @override
  State<AdminIssueDetailScreen> createState() => _AdminIssueDetailScreenState();
}

class _AdminIssueDetailScreenState extends State<AdminIssueDetailScreen> {
  bool _isLoading = true;
  String? _error;
  IssueModel? _issue;
  final TextEditingController _commentController = TextEditingController();
  bool _isSendingComment = false;
  bool _isUpdatingStatus = false;

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
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Arıza detaylarını yükle
      final issueProvider = Provider.of<IssueProvider>(context, listen: false);
      _issue = await issueProvider.getIssueById(widget.issueId);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _updateIssueStatus(String status) async {
    try {
      setState(() {
        _isUpdatingStatus = true;
      });

      // Arıza durumunu güncelle
      final issueProvider = Provider.of<IssueProvider>(context, listen: false);
      await issueProvider.updateIssueStatus(widget.issueId, status);

      // Arıza detaylarını yeniden yükle
      await _loadIssueDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arıza durumu başarıyla güncellendi: $status'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    try {
      setState(() {
        _isSendingComment = true;
      });

      // Yorumu gönder
      final issueProvider = Provider.of<IssueProvider>(context, listen: false);
      await issueProvider.addComment(
        widget.issueId,
        _commentController.text.trim(),
      );

      // Arıza detaylarını yeniden yükle
      await _loadIssueDetails();

      // Yorum alanını temizle
      _commentController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yorum başarıyla gönderildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingComment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arıza Detayı'),
        actions: [
          if (!_isLoading && _issue != null)
            PopupMenuButton<String>(
              onSelected: _updateIssueStatus,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Bekliyor',
                  child: Text('Bekliyor'),
                ),
                const PopupMenuItem<String>(
                  value: 'İşleniyor',
                  child: Text('İşleniyor'),
                ),
                const PopupMenuItem<String>(
                  value: 'Tamamlandı',
                  child: Text('Tamamlandı'),
                ),
                const PopupMenuItem<String>(
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
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hata: $_error',
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadIssueDetails,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : _issue == null
                  ? const Center(child: Text('Arıza bulunamadı'))
                  : SafeArea(
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildIssueHeader(),
                                  SizedBox(height: 16.h),
                                  _buildIssueDetails(),
                                  SizedBox(height: 16.h),
                                  if (_issue!.images.isNotEmpty) ...[
                                    _buildIssueImages(),
                                    SizedBox(height: 16.h),
                                  ],
                                  _buildIssueComments(),
                                ],
                              ),
                            ),
                          ),
                          _buildCommentInput(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildIssueHeader() {
    // Durum rengini belirle
    Color statusColor;
    switch (_issue!.status) {
      case 'Bekliyor':
        statusColor = Colors.orange;
        break;
      case 'İşleniyor':
        statusColor = Colors.blue;
        break;
      case 'Tamamlandı':
        statusColor = Colors.green;
        break;
      case 'İptal Edildi':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _issue!.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    children: [
                      if (_isUpdatingStatus)
                        SizedBox(
                          width: 12.w,
                          height: 12.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: statusColor,
                          ),
                        )
                      else
                        Icon(
                          _getStatusIcon(_issue!.status),
                          size: 14.sp,
                          color: statusColor,
                        ),
                      SizedBox(width: 4.w),
                      Text(
                        _issue!.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (_issue!.isUrgent)
              Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.priority_high,
                      size: 14.sp,
                      color: Colors.red,
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
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16.sp,
                  color: Colors.grey,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Bildiren: ${_issue!.reportedBy}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16.sp,
                  color: Colors.grey,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Tarih: ${_issue!.reportDate}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  _getCategoryIcon(_issue!.category),
                  size: 16.sp,
                  color: Colors.grey,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Kategori: ${_issue!.category}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Açıklama',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              _issue!.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueImages() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fotoğraflar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                  return Container(
                    width: 120.w,
                    height: 120.h,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _issue!.images[index].startsWith('http')
                          ? Image.network(
                              _issue!.images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[600],
                                    size: 40.sp,
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            )
                          : Image.file(
                              File(_issue!.images[index]),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[600],
                                    size: 40.sp,
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
        ),
      ),
    );
  }

  Widget _buildIssueComments() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yorumlar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8.h),
            if (_issue!.comments == null || _issue!.comments!.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    'Henüz yorum yok',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _issue!.comments!.length,
                separatorBuilder: (context, index) => Divider(height: 24.h),
                itemBuilder: (context, index) {
                  final comment = _issue!.comments![index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            comment.author,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            comment.date,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        comment.comment,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Yorum ekleyin...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.newline,
            ),
          ),
          SizedBox(width: 8.w),
          IconButton(
            onPressed: _isSendingComment ? null : _sendComment,
            icon: _isSendingComment
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(),
                  )
                : const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Bekliyor':
        return Icons.hourglass_empty;
      case 'İşleniyor':
        return Icons.engineering;
      case 'Tamamlandı':
        return Icons.check_circle;
      case 'İptal Edildi':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Elektrik':
        return Icons.electrical_services;
      case 'Su':
        return Icons.water_drop;
      case 'Doğalgaz':
        return Icons.local_fire_department;
      case 'İnternet':
        return Icons.wifi;
      case 'Asansör':
        return Icons.elevator;
      case 'Ortak Alan':
        return Icons.meeting_room;
      default:
        return Icons.build;
    }
  }
} 