import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:smart_community_ai/core/models/notification_model.dart';
import 'package:smart_community_ai/core/services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService;
  final bool isTestMode;
  bool _isLoading = false;
  List<NotificationModel> _notifications = [];
  String? _error;

  NotificationProvider({
    required ApiService apiService,
    this.isTestMode = false, // Test modunu varsayılan olarak devre dışı bırak
  }) : _apiService = apiService;

  bool get isLoading => _isLoading;
  List<NotificationModel> get notifications => _notifications;
  String? get error => _error;

  // Bildirimleri getir
  Future<void> fetchNotifications() async {
    // Eğer zaten yükleme yapılıyorsa, işlemi tekrarlama
    if (_isLoading) {
      print('Bildirimler zaten yükleniyor, işlem tekrarlanmayacak');
      return;
    }
    
    try {
      print('Bildirimler yükleniyor...');
      
      // Yükleme durumunu güncelle ve bildirimleri tetikle
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // API'den bildirimleri al
      final response = await _apiService.get('/api/notifications');
      
      if (response['success']) {
        // Bildirimleri dönüştür
        _notifications = (response['data'] as List)
            .map((item) => NotificationModel.fromJson(item))
            .toList();
        
        // Bildirimleri yerel depolamaya kaydet
        await _saveNotificationsToLocal(_notifications);
        
        print('Bildirimler başarıyla yüklendi: ${_notifications.length} adet');
      } else {
        _error = response['message'] ?? 'Bildirimler alınamadı';
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Bildirimler yüklenirken hata: $e');
      _error = e.toString();
      
      // Hata durumunda yerel depolamadan bildirimleri yükle
      _notifications = await _loadNotificationsFromLocal();
      
      // Yükleme durumunu güncelle
      _isLoading = false;
      notifyListeners();
    }
  }

  // Bildirimleri yerel depolamaya kaydet
  Future<void> _saveNotificationsToLocal(List<NotificationModel> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = notifications.map((n) => n.toJson()).toList();
      await prefs.setString('notifications', jsonEncode(notificationsJson));
      print('Bildirimler yerel depolamaya kaydedildi: ${notifications.length} adet');
    } catch (e) {
      print('Bildirimler yerel depolamaya kaydedilirken hata: $e');
    }
  }
  
  // Bildirimleri yerel depolamadan yükle
  Future<List<NotificationModel>> _loadNotificationsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications');
      
      if (notificationsJson != null) {
        final List<dynamic> decodedList = jsonDecode(notificationsJson);
        final notifications = decodedList.map((json) => NotificationModel.fromJson(json)).toList();
        print('Bildirimler yerel depolamadan yüklendi: ${notifications.length} adet');
        return notifications;
      }
    } catch (e) {
      print('Bildirimler yerel depolamadan yüklenirken hata: $e');
    }
    
    return [];
  }

  // Okunmamış bildirimleri getir
  List<NotificationModel> get unreadNotifications {
    return _notifications.where((notification) => !notification.isRead).toList();
  }

  // Okunmamış bildirim sayısını getir
  int get unreadCount {
    return unreadNotifications.length;
  }

  // Bildirimi okundu olarak işaretle
  Future<void> markAsRead(String id) async {
    try {
      // API'ye bildirim okundu isteği gönder
      final response = await _apiService.put('/api/notifications/$id/read', {});
      
      if (response['success']) {
        // UI'da güncelleme yap
        final index = _notifications.indexWhere((notification) => notification.id == id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          
          // Yerel depolamayı güncelle
          await _saveNotificationsToLocal(_notifications);
          
          notifyListeners();
        }
      } else {
        _error = response['message'] ?? 'Bildirim güncellenemedi';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      
      // Hata olsa bile UI'da güncelleme yap
      final index = _notifications.indexWhere((notification) => notification.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        
        // Yerel depolamayı güncelle
        await _saveNotificationsToLocal(_notifications);
        
        notifyListeners();
      }
    }
  }

  // Tüm bildirimleri okundu olarak işaretle
  Future<void> markAllAsRead() async {
    try {
      // API'ye tüm bildirimler okundu isteği gönder
      final response = await _apiService.put('/api/notifications/read-all', {});
      
      if (response['success']) {
        // Tüm bildirimleri okundu olarak işaretle
        _notifications = _notifications.map((notification) => 
          notification.copyWith(isRead: true)
        ).toList();
        
        // Yerel depolamayı güncelle
        await _saveNotificationsToLocal(_notifications);
        
        notifyListeners();
      } else {
        _error = response['message'] ?? 'Bildirimler güncellenemedi';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      
      // Hata olsa bile UI'da güncelleme yap
      _notifications = _notifications.map((notification) => 
        notification.copyWith(isRead: true)
      ).toList();
      
      // Yerel depolamayı güncelle
      await _saveNotificationsToLocal(_notifications);
      
      notifyListeners();
    }
  }

  // Bildirimi sil
  Future<void> deleteNotification(String id) async {
    try {
      // Gerçek API çağrısı
      final response = await _apiService.delete('/api/notifications/$id');
      
      if (response['success']) {
        await fetchNotifications();
      } else {
        _error = response['message'] ?? 'Bildirim silinemedi';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Türe göre bildirimleri getir
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((notification) => notification.type == type).toList();
  }
} 