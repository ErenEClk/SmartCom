import 'package:flutter/material.dart';
import 'package:smart_community_ai/core/models/issue_model.dart';
import 'package:smart_community_ai/core/services/api_service.dart';
import 'package:smart_community_ai/core/models/user_model.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class IssueProvider extends ChangeNotifier {
  final ApiService _apiService;
  final bool isTestMode;
  
  bool _isLoading = false;
  List<IssueModel> _issues = [];
  String? _error;

  IssueProvider({
    required ApiService apiService,
    this.isTestMode = false, // Test modunu varsayılan olarak devre dışı bırak
  }) : _apiService = apiService;

  bool get isLoading => _isLoading;
  List<IssueModel> get issues => _issues;
  String? get error => _error;

  // Arıza bildirimlerini getir
  Future<void> fetchIssues() async {
    // Eğer zaten yükleme yapılıyorsa, işlemi tekrarlama
    if (_isLoading) {
      print('Arızalar zaten yükleniyor, işlem tekrarlanmayacak');
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Normal API çağrısı
      final response = await _apiService.get('/api/faults');
      if (response['success']) {
        final issuesData = response['data'] as List<dynamic>;
        _issues = issuesData.map((issue) => IssueModel.fromJson(issue)).toList();
        
        // Arızaları tarihe göre sırala (en yeni en üstte)
        _issues.sort((a, b) => DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));
        
        // Arızaları yerel depolamaya kaydet
        await _saveIssuesToLocalStorage();
        _isLoading = false;
        notifyListeners();
      } else {
        // Yerel depolamadan yüklemeyi dene
        await _loadIssuesFromLocalStorage();
        
        _error = response['message'] ?? 'Arıza bildirimleri alınamadı';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      // Hata durumunda yerel depolamadan yüklemeyi dene
      await _loadIssuesFromLocalStorage();
      
      _isLoading = false;
      _error = 'Arıza bildirimleri yüklenirken bir hata oluştu: $e';
      notifyListeners();
    }
  }

  // Arıza bildirimini ID'ye göre getir
  Future<IssueModel?> getIssueById(String id) async {
    // Önce yerel listede ara
    final localIssue = _issues.firstWhere(
      (issue) => issue.id == id,
      orElse: () => IssueModel(
        id: '',
        title: '',
        description: '',
        category: '',
        status: '',
        isUrgent: false,
        images: [],
        comments: [],
        reporter: UserModel(
          id: '',
          name: 'Bilinmeyen',
          email: '',
          role: 'user',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        createdAt: '',
        reportDate: '',
        reportedBy: '',
      ),
    );

    if (localIssue.id.isNotEmpty) {
      return localIssue;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Normal API çağrısı
      final response = await _apiService.get('/api/faults/$id');
      if (response['success']) {
        final issueData = response['data'];
        final issue = IssueModel.fromJson(issueData);
        _isLoading = false;
        notifyListeners();
        return issue;
      } else {
        _isLoading = false;
        _error = response['message'] ?? 'Arıza bildirimi bulunamadı';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Arıza bildirimi yüklenirken bir hata oluştu: $e';
      notifyListeners();
      return null;
    }
  }

  // Yeni arıza bildirimi oluştur
  Future<IssueModel?> createIssue(
    String title,
    String description,
    String category,
    bool isUrgent,
    List<File>? images,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // API'ye gönderilecek veriyi hazırla
      final data = {
        'title': title,
        'description': description,
        'category': category,
        'isUrgent': isUrgent,
      };
      
      // Normal API çağrısı
      final response = await _apiService.post('/api/faults', data);
      
      if (response['success']) {
        // Yeni oluşturulan arıza bildirimini al
        final newIssue = IssueModel.fromJson(response['data']);
        
        // Eğer resimler varsa, bunları yükle
        if (images != null && images.isNotEmpty) {
          // Resim yükleme işlemi burada yapılacak
          // Bu kısım için ayrı bir API endpoint'i gerekebilir
        }
        
        // Arızaları yeniden yükle
        await fetchIssues();
        
        _isLoading = false;
        notifyListeners();
        return newIssue;
      } else {
        _isLoading = false;
        _error = response['message'] ?? 'Arıza bildirimi oluşturulamadı';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Arıza bildirimi oluşturulurken bir hata oluştu: $e';
      notifyListeners();
      return null;
    }
  }

  // Arıza bildirimini güncelle
  Future<bool> updateIssue(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Normal API çağrısı
      final response = await _apiService.put('/api/faults/$id', data);
      
      if (response['success']) {
        // Arızaları yeniden yükle
        await fetchIssues();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = response['message'] ?? 'Arıza bildirimi güncellenemedi';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Arıza bildirimi güncellenirken bir hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  // Arıza durumunu güncelle
  Future<bool> updateIssueStatus(String id, String status) async {
    return await updateIssue(id, {'status': status});
  }

  // Arıza bildirimini sil
  Future<bool> deleteIssue(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Normal API çağrısı
      final response = await _apiService.delete('/api/faults/$id');
      
      if (response['success']) {
        // Arızaları yeniden yükle
        await fetchIssues();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = response['message'] ?? 'Arıza bildirimi silinemedi';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Arıza bildirimi silinirken bir hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  // Arıza bildirimlerine yorum ekle
  Future<bool> addComment(String issueId, String comment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // API'ye gönderilecek veriyi hazırla
      final data = {
        'comment': comment,
      };
      
      // Normal API çağrısı
      final response = await _apiService.post('/api/faults/$issueId/comments', data);
      
      if (response['success']) {
        // Arızaları yeniden yükle
        await fetchIssues();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = response['message'] ?? 'Yorum eklenemedi';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Yorum eklenirken bir hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  // Duruma göre arıza bildirimlerini getir
  List<IssueModel> getIssuesByStatus(String status) {
    if (status == 'Tümü') {
      return _issues;
    }
    return _issues.where((issue) => issue.status == status).toList();
  }

  // Kullanıcıya özel arıza bildirimlerini getir
  List<IssueModel> getUserIssues(String userId) {
    return _issues.where((issue) => issue.reporter.id == userId).toList();
  }

  // Yönetici tarafından arıza duyurusu oluştur
  Future<IssueModel?> createAnnouncementIssue(
    String title,
    String description,
    String category,
    bool isUrgent,
    List<String> visibleToUsers, // Hangi kullanıcıların görebileceği
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // API'ye gönderilecek veriyi hazırla
      final data = {
        'title': title,
        'description': description,
        'category': category,
        'isUrgent': isUrgent,
        'status': 'Duyuru',
        'visibleToUsers': visibleToUsers,
      };
      
      // Normal API çağrısı
      final response = await _apiService.post('/api/faults/announcement', data);
      
      if (response['success']) {
        // Yeni oluşturulan duyuruyu al
        final newIssue = IssueModel.fromJson(response['data']);
        
        // Arızaları yeniden yükle
        await fetchIssues();
        
        _isLoading = false;
        notifyListeners();
        return newIssue;
      } else {
        _isLoading = false;
        _error = response['message'] ?? 'Arıza duyurusu oluşturulamadı';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Arıza duyurusu oluşturulurken bir hata oluştu: $e';
      notifyListeners();
      return null;
    }
  }

  // Arıza bildirimlerini yerel depolamaya kaydet
  Future<void> _saveIssuesToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final issuesJson = _issues.map((issue) => issue.toJson()).toList();
      await prefs.setString('issues', jsonEncode(issuesJson));
    } catch (e) {
      print('Arıza bildirimleri yerel depolamaya kaydedilirken hata: $e');
    }
  }

  // Arıza bildirimlerini yerel depolamadan yükle
  Future<void> _loadIssuesFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final issuesJson = prefs.getString('issues');
      
      if (issuesJson != null) {
        final List<dynamic> decodedList = jsonDecode(issuesJson);
        _issues = decodedList.map((json) => IssueModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Arıza bildirimleri yerel depolamadan yüklenirken hata: $e');
    }
  }
} 