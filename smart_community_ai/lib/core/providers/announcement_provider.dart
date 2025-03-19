import 'package:flutter/material.dart';
import 'package:smart_community_ai/core/models/announcement_model.dart';
import 'package:smart_community_ai/core/services/api_service.dart';
import 'package:smart_community_ai/core/constants/api_constants.dart';
import 'package:uuid/uuid.dart';

class AnnouncementProvider extends ChangeNotifier {
  final ApiService _apiService;
  final bool isTestMode;
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  String? _error;

  AnnouncementProvider({
    required ApiService apiService,
    this.isTestMode = false, // Test modunu varsayılan olarak devre dışı bırak
  }) : _apiService = apiService;

  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AnnouncementModel> get importantAnnouncements => 
      _announcements.where((announcement) => announcement.isImportant).toList();

  List<AnnouncementModel> get recentAnnouncements => 
      _announcements.take(5).toList();

  Future<bool> fetchAnnouncements() async {
    // Eğer zaten yükleme yapılıyorsa, işlemi tekrarlama
    if (_isLoading) {
      print('Duyurular zaten yükleniyor, işlem tekrarlanmayacak');
      return false;
    }
    
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      if (isTestMode) {
        // Test modunda örnek duyurular
        await Future.delayed(const Duration(seconds: 1));
        _announcements = _getTestAnnouncements();
        _isLoading = false;
        Future.microtask(() => notifyListeners());
        return true;
      }
      
      // Normal API çağrısı
      final response = await _apiService.get(ApiConstants.announcementsEndpoint);
      
      if (response['success']) {
        final List<dynamic> data = response['data'];
        _announcements = data.map((item) => AnnouncementModel.fromJson(item)).toList();
        _isLoading = false;
        Future.microtask(() => notifyListeners());
        return true;
      } else {
        _error = response['message'] ?? 'Duyurular alınamadı';
        _isLoading = false;
        Future.microtask(() => notifyListeners());
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      
      // Hata durumunda test verilerini kullan
      if (isTestMode) {
        _announcements = _getTestAnnouncements();
        Future.microtask(() => notifyListeners());
        return true;
      }
      
      Future.microtask(() => notifyListeners());
      return false;
    }
  }

  Future<bool> createAnnouncement(Map<String, dynamic> announcementData) async {
    _setLoading(true);
    _error = null;

    try {
      if (isTestMode) {
        // Test modunda yeni duyuru oluştur
        print('Test modunda duyuru oluşturuluyor: $announcementData');
        await Future.delayed(const Duration(seconds: 1));
        
        final uuid = const Uuid();
        final newAnnouncement = AnnouncementModel(
          id: uuid.v4(),
          title: announcementData['title'] ?? '',
          content: announcementData['content'] ?? '',
          isImportant: announcementData['isImportant'] ?? false,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          imageUrls: announcementData['imageUrls'] as List<String>?,
          fileUrls: announcementData['fileUrls'] as List<String>?,
          targetUserIds: announcementData['targetUserIds'] as List<String>?,
        );
        
        _announcements.insert(0, newAnnouncement);
        _setLoading(false);
        Future.microtask(() => notifyListeners());
        return true;
      }
      
      // Normal API çağrısı
      try {
        final response = await _apiService.post(ApiConstants.announcementsEndpoint, announcementData);
        
        if (response['success']) {
          await fetchAnnouncements();
          return true;
        } else {
          _error = response['message'] ?? 'Duyuru oluşturulamadı';
          _setLoading(false);
          Future.microtask(() => notifyListeners());
          return false;
        }
      } catch (e) {
        _error = 'Duyuru oluşturulurken hata oluştu: $e';
        _setLoading(false);
        Future.microtask(() => notifyListeners());
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      Future.microtask(() => notifyListeners());
      return false;
    }
  }

  Future<bool> updateAnnouncement(Map<String, dynamic> announcementData) async {
    _setLoading(true);
    _error = null;

    try {
      if (isTestMode) {
        // Test modunda duyuru güncelle
        print('Test modunda duyuru güncelleniyor: $announcementData');
        await Future.delayed(const Duration(seconds: 1));
        
        final index = _announcements.indexWhere((a) => a.id == announcementData['id']);
        if (index != -1) {
          // Varolan duyuruyu güncelle
          _announcements[index] = AnnouncementModel(
            id: announcementData['id'],
            title: announcementData['title'] ?? '',
            content: announcementData['content'] ?? '',
            isImportant: announcementData['isImportant'] ?? false,
            createdAt: _announcements[index].createdAt,
            updatedAt: DateTime.now().toIso8601String(),
            imageUrls: announcementData['imageUrls'] as List<String>?,
            fileUrls: announcementData['fileUrls'] as List<String>?,
            targetUserIds: announcementData['targetUserIds'] as List<String>?,
          );
          
          _setLoading(false);
          Future.microtask(() => notifyListeners());
          return true;
        } else {
          _error = 'Duyuru bulunamadı';
          _setLoading(false);
          Future.microtask(() => notifyListeners());
          return false;
        }
      }
      
      // Normal API çağrısı
      try {
        final response = await _apiService.put(
          '${ApiConstants.announcementsEndpoint}/${announcementData['id']}',
          announcementData,
        );
        
        if (response['success']) {
          await fetchAnnouncements();
          return true;
        } else {
          _error = response['message'] ?? 'Duyuru güncellenemedi';
          _setLoading(false);
          Future.microtask(() => notifyListeners());
          return false;
        }
      } catch (e) {
        _error = 'Duyuru güncellenirken hata oluştu: $e';
        _setLoading(false);
        Future.microtask(() => notifyListeners());
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      Future.microtask(() => notifyListeners());
      return false;
    }
  }

  Future<bool> deleteAnnouncement(String id) async {
    _setLoading(true);
    _error = null;

    try {
      if (isTestMode) {
        // Test modunda silme işlemi
        print('Test modunda duyuru siliniyor: $id');
        await Future.delayed(const Duration(seconds: 1));
        
        final index = _announcements.indexWhere((a) => a.id == id);
        if (index != -1) {
          _announcements.removeAt(index);
          _setLoading(false);
          Future.microtask(() => notifyListeners());
          return true;
        } else {
          _error = 'Duyuru bulunamadı';
          _setLoading(false);
          Future.microtask(() => notifyListeners());
          return false;
        }
      }
      
      // Normal API çağrısı
      final response = await _apiService.delete('${ApiConstants.announcementsEndpoint}/$id');
      
      if (response['success']) {
        await fetchAnnouncements();
        return true;
      } else {
        _error = response['message'] ?? 'Duyuru silinemedi';
        _setLoading(false);
        Future.microtask(() => notifyListeners());
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      Future.microtask(() => notifyListeners());
      return false;
    }
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      Future.microtask(() => notifyListeners());
    }
  }
  
  // Test için örnek duyurular
  List<AnnouncementModel> _getTestAnnouncements() {
    return [
      AnnouncementModel(
        id: '1',
        title: 'Site Yönetim Kurulu Toplantısı',
        content: 'Değerli site sakinlerimiz, 15 Haziran 2025 tarihinde saat 19:00\'da site yönetim kurulu toplantısı yapılacaktır. Katılımınızı rica ederiz.',
        isImportant: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        imageUrls: ['https://example.com/images/meeting.jpg'],
        fileUrls: ['https://example.com/files/agenda.pdf'],
      ),
      AnnouncementModel(
        id: '2',
        title: 'Havuz Bakımı Hakkında',
        content: 'Değerli site sakinlerimiz, 10-12 Haziran 2025 tarihleri arasında havuz bakımı yapılacaktır. Bu tarihler arasında havuz kullanıma kapalı olacaktır.',
        isImportant: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      ),
      AnnouncementModel(
        id: '3',
        title: 'Elektrik Kesintisi',
        content: 'Değerli site sakinlerimiz, 20 Haziran 2025 tarihinde saat 10:00-14:00 arasında elektrik kesintisi yaşanacaktır. Bilgilerinize sunarız.',
        isImportant: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      ),
      AnnouncementModel(
        id: '4',
        title: 'Yaz Etkinlikleri',
        content: 'Değerli site sakinlerimiz, yaz aylarında düzenlenecek etkinlikler için önerilerinizi site yönetimine iletebilirsiniz.',
        isImportant: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        imageUrls: ['https://example.com/images/summer.jpg'],
      ),
      AnnouncementModel(
        id: '5',
        title: 'Aidat Ödemeleri Hakkında',
        content: 'Değerli site sakinlerimiz, Haziran ayı aidat ödemelerinin son günü 15 Haziran 2025\'tir. Ödemelerinizi zamanında yapmanızı rica ederiz.',
        isImportant: true,
        createdAt: DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      ),
    ];
  }
} 