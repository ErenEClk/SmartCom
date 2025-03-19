import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_ai/core/models/announcement_model.dart';
import 'package:smart_community_ai/core/models/user_model.dart';
import 'package:smart_community_ai/core/providers/announcement_provider.dart';
import 'package:smart_community_ai/core/providers/auth_provider.dart';
import 'package:smart_community_ai/core/theme/app_colors.dart';
import 'package:smart_community_ai/core/widgets/custom_app_bar.dart';
import 'package:smart_community_ai/core/widgets/custom_button.dart';
import 'package:smart_community_ai/core/widgets/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminAnnouncementsScreen extends StatefulWidget {
  static const String routeName = '/admin-announcements';

  const AdminAnnouncementsScreen({Key? key}) : super(key: key);

  @override
  State<AdminAnnouncementsScreen> createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<UserModel> _users = [];
  bool _isLoadingUsers = false;
  
  // Eksik değişkenleri ekliyorum
  File? _selectedImage;
  String? _imageFileName;
  File? _selectedFile;
  String? _fileFileName;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAnnouncements() async {
    final announcementProvider = Provider.of<AnnouncementProvider>(context, listen: false);
    await announcementProvider.fetchAnnouncements();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _users = authProvider.isTestMode ? _getTestUsers() : await authProvider.getUsers();
    } catch (e) {
      print('Kullanıcılar yüklenirken hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcılar yüklenirken hata oluştu: $e')),
      );
      _users = _getTestUsers(); // Hata durumunda test verilerini kullan
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
  }

  // Test için örnek kullanıcılar
  List<UserModel> _getTestUsers() {
    return [
      UserModel(
        id: 'user1',
        name: 'Test Kullanıcı 1',
        email: 'user1@example.com',
        role: 'user',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      UserModel(
        id: 'user2',
        name: 'Test Kullanıcı 2',
        email: 'user2@example.com',
        role: 'user',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Duyuru Yönetimi',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildAnnouncementsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAnnouncementDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: CustomTextField(
        controller: _searchController,
        hintText: 'Duyuru ara...',
        prefixIcon: const Icon(Icons.search),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return Consumer<AnnouncementProvider>(
      builder: (context, announcementProvider, child) {
        if (announcementProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (announcementProvider.error != null) {
          return Center(
            child: Text(
              'Hata: ${announcementProvider.error}',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16.sp,
              ),
            ),
          );
        }

        final announcements = announcementProvider.announcements;
        
        if (announcements.isEmpty) {
          return Center(
            child: Text(
              'Henüz duyuru bulunmamaktadır',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          );
        }

        // Arama filtrelemesi
        final filteredAnnouncements = _searchQuery.isEmpty
            ? announcements
            : announcements.where((announcement) {
                return announcement.title.toLowerCase().contains(_searchQuery) ||
                    announcement.content.toLowerCase().contains(_searchQuery);
              }).toList();

        if (filteredAnnouncements.isEmpty) {
          return Center(
            child: Text(
              'Arama sonucu bulunamadı',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadAnnouncements,
          child: ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: filteredAnnouncements.length,
            itemBuilder: (context, index) {
              final announcement = filteredAnnouncements[index];
              return _buildAnnouncementCard(announcement);
            },
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.r),
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
                Expanded(
                  child: Text(
                    announcement.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (announcement.isImportant)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.r,
                      vertical: 4.r,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Önemli',
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
              announcement.content,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
            
            // Fotoğraflar
            if (announcement.imageUrls != null && announcement.imageUrls!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Text(
                'Fotoğraflar',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                height: 100.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: announcement.imageUrls!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Fotoğrafı tam ekran görüntüleme
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Image.network(
                              announcement.imageUrls![index],
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 100.w,
                        height: 100.h,
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          image: DecorationImage(
                            image: NetworkImage(announcement.imageUrls![index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            // Dosyalar
            if (announcement.fileUrls != null && announcement.fileUrls!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Text(
                'Dosyalar',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Column(
                children: announcement.fileUrls!.map((fileUrl) {
                  final fileName = fileUrl.split('/').last;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _getFileIcon(fileName),
                      color: AppColors.primary,
                    ),
                    title: Text(fileName),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        // Dosya indirme işlemi
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$fileName indiriliyor...'),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
            
            // Hedef kullanıcılar
            if (announcement.targetUserIds != null && announcement.targetUserIds!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Özel Duyuru: ${announcement.targetUserIds!.length} kullanıcı',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
            
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tarih: ${_formatDate(announcement.createdAt)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () => _showEditAnnouncementDialog(announcement),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _showDeleteConfirmationDialog(announcement),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _showAddAnnouncementDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    bool isImportant = false;
    List<File> selectedImages = [];
    List<File> selectedFiles = [];
    List<String> selectedUserIds = [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Dialog içinde kullanılacak dosya ve resim seçme fonksiyonları
          Future<void> pickImage() async {
            try {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              
              if (image != null) {
                setState(() {
                  selectedImages.add(File(image.path));
                });
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Resim seçilirken hata oluştu: $e')),
              );
            }
          }

          Future<void> pickFile() async {
            try {
              final ImagePicker picker = ImagePicker();
              final XFile? file = await picker.pickImage(source: ImageSource.gallery);
              
              if (file != null) {
                setState(() {
                  selectedFiles.add(File(file.path));
                });
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dosya seçilirken hata oluştu: $e')),
              );
            }
          }

          return AlertDialog(
            title: const Text('Yeni Duyuru Ekle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: titleController,
                    labelText: 'Başlık',
                    hintText: 'Duyuru başlığını girin',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Başlık alanı boş bırakılamaz';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    controller: contentController,
                    labelText: 'İçerik',
                    hintText: 'Duyuru içeriğini girin',
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'İçerik alanı boş bırakılamaz';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Checkbox(
                        value: isImportant,
                        onChanged: (value) {
                          setState(() {
                            isImportant = value ?? false;
                          });
                        },
                      ),
                      const Text('Önemli Duyuru'),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
                  // Fotoğraf ekleme bölümü
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Fotoğraflar (${selectedImages.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_photo_alternate),
                        onPressed: () async {
                          await pickImage();
                        },
                      ),
                    ],
                  ),
                  if (selectedImages.isNotEmpty)
                    Container(
                      height: 100.h,
                      margin: EdgeInsets.symmetric(vertical: 8.h),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                width: 100.w,
                                height: 100.h,
                                margin: EdgeInsets.only(right: 8.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  image: DecorationImage(
                                    image: FileImage(selectedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 8.w,
                                top: 0,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedImages.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 16.h),
                  
                  // Dosya ekleme bölümü
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Dosyalar (${selectedFiles.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () async {
                          await pickFile();
                        },
                      ),
                    ],
                  ),
                  if (selectedFiles.isNotEmpty)
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8.h),
                      child: Column(
                        children: selectedFiles.map((file) {
                          return ListTile(
                            leading: const Icon(Icons.insert_drive_file),
                            title: Text(file.path.split('/').last),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedFiles.remove(file);
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  SizedBox(height: 16.h),
                  
                  // Hedef kullanıcı seçme bölümü
                  Text(
                    'Hedef Kullanıcılar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _isLoadingUsers
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: selectedUserIds.length == _users.length,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedUserIds = _users.map((user) => user.id).toList();
                                      } else {
                                        selectedUserIds = [];
                                      }
                                    });
                                  },
                                ),
                                const Text('Tüm Kullanıcılar'),
                              ],
                            ),
                            Container(
                              height: 150.h,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: ListView.builder(
                                itemCount: _users.length,
                                itemBuilder: (context, index) {
                                  final user = _users[index];
                                  return CheckboxListTile(
                                    title: Text(user.name),
                                    subtitle: Text(user.email),
                                    value: selectedUserIds.contains(user.id),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedUserIds.add(user.id);
                                        } else {
                                          selectedUserIds.remove(user.id);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              Consumer<AnnouncementProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: 'Ekle',
                    isLoading: provider.isLoading,
                    onPressed: () async {
                      if (titleController.text.isEmpty || contentController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lütfen tüm alanları doldurun'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Şimdilik dosya ve fotoğraf yükleme işlemini simüle ediyoruz
                      // Gerçek uygulamada burada dosya ve fotoğrafları sunucuya yükleyip URL'lerini alacağız
                      List<String> imageUrls = selectedImages.isNotEmpty 
                          ? ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'] 
                          : [];
                      
                      List<String> fileUrls = selectedFiles.isNotEmpty 
                          ? ['https://example.com/file1.pdf', 'https://example.com/file2.docx'] 
                          : [];

                      final newAnnouncement = {
                        'title': titleController.text.trim(),
                        'content': contentController.text.trim(),
                        'isImportant': isImportant,
                        'imageUrls': imageUrls,
                        'fileUrls': fileUrls,
                        'targetUserIds': selectedUserIds.isEmpty ? null : selectedUserIds,
                      };

                      try {
                        final success = await provider.createAnnouncement(newAnnouncement);

                        if (!mounted) return;

                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Duyuru başarıyla eklendi'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(provider.error ?? 'Duyuru eklenemedi'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Duyuru eklerken hata oluştu: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditAnnouncementDialog(AnnouncementModel announcement) async {
    final titleController = TextEditingController(text: announcement.title);
    final contentController = TextEditingController(text: announcement.content);
    bool isImportant = announcement.isImportant;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Duyuru Düzenle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: titleController,
                    labelText: 'Başlık',
                    hintText: 'Duyuru başlığını girin',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Başlık alanı boş bırakılamaz';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    controller: contentController,
                    labelText: 'İçerik',
                    hintText: 'Duyuru içeriğini girin',
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'İçerik alanı boş bırakılamaz';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Checkbox(
                        value: isImportant,
                        onChanged: (value) {
                          setState(() {
                            isImportant = value ?? false;
                          });
                        },
                      ),
                      const Text('Önemli Duyuru'),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              Consumer<AnnouncementProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: 'Güncelle',
                    isLoading: provider.isLoading,
                    onPressed: () async {
                      if (titleController.text.isEmpty || contentController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lütfen tüm alanları doldurun'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final updatedAnnouncement = {
                        'id': announcement.id,
                        'title': titleController.text.trim(),
                        'content': contentController.text.trim(),
                        'isImportant': isImportant,
                      };

                      final success = await provider.updateAnnouncement(updatedAnnouncement);

                      if (!mounted) return;

                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Duyuru başarıyla güncellendi'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(provider.error ?? 'Duyuru güncellenemedi'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(AnnouncementModel announcement) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duyuru Sil'),
        content: Text('${announcement.title} başlıklı duyuruyu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          Consumer<AnnouncementProvider>(
            builder: (context, provider, child) {
              return CustomButton(
                text: 'Sil',
                isLoading: provider.isLoading,
                color: Colors.red,
                onPressed: () async {
                  final success = await provider.deleteAnnouncement(announcement.id);

                  if (!mounted) return;

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Duyuru başarıyla silindi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.error ?? 'Duyuru silinemedi'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateInput) {
    try {
      if (dateInput is DateTime) {
        return DateFormat('dd.MM.yyyy HH:mm').format(dateInput);
      } else if (dateInput is String) {
        final date = DateTime.parse(dateInput);
        return DateFormat('dd.MM.yyyy HH:mm').format(date);
      } else {
        return 'Geçersiz tarih';
      }
    } catch (e) {
      print('Tarih formatı hatası: $e, tarih: $dateInput');
      return dateInput.toString();
    }
  }
} 