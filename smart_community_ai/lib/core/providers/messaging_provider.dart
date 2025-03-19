import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_community_ai/core/constants/api_constants.dart';
import 'package:smart_community_ai/core/models/conversation_model.dart';
import 'package:smart_community_ai/core/models/message_model.dart';
import 'package:smart_community_ai/core/models/user_model.dart';
import 'package:smart_community_ai/core/services/api_service.dart';
import 'package:smart_community_ai/core/services/auth_service.dart';

class MessagingProvider with ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;
  
  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  String? _currentConversationId;
  bool _isLoading = false;
  bool _isTyping = false;
  String? _error;
  bool _testMode = true; // Test modu

  MessagingProvider({
    required ApiService apiService,
    required AuthService authService,
  })  : _apiService = apiService,
        _authService = authService;

  // Getters
  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get error => _error;

  // Konuşmaları yükle
  Future<bool> loadConversations() async {
    // Eğer zaten yükleme yapılıyorsa, işlemi engelle
    if (_isLoading) {
      print('MessagingProvider: Zaten yükleme yapılıyor, işlem iptal edildi');
      return false;
    }
    
    _setLoading(true);
    _error = null;

    try {
      if (_testMode) {
        // Test verileri
        await Future.delayed(const Duration(seconds: 1));
        _conversations = _getTestConversations();
        _setLoading(false);
        return true;
      } else {
        try {
          final response = await _apiService.get(ApiConstants.conversationsEndpoint);
          
          if (response['success']) {
            final List<dynamic> data = response['data'];
            _conversations = data
                .map((item) => ConversationModel.fromJson(item))
                .toList();
            _setLoading(false);
            return true;
          } else {
            _handleError('Konuşmalar yüklenirken hata oluştu: ${response['message'] ?? 'Bilinmeyen hata'}');
            return false;
          }
        } catch (e) {
          _handleError('Konuşmalar yüklenirken hata oluştu: $e');
          return false;
        }
      }
    } catch (e) {
      _handleError('Konuşmalar yüklenirken hata oluştu: $e');
      return false;
    }
  }

  // Konuşma oluştur veya mevcut konuşmayı getir
  Future<ConversationModel?> getOrCreateConversation(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      if (_testMode) {
        // Test verileri
        await Future.delayed(const Duration(milliseconds: 500));
        final conversation = _getTestConversation(userId);
        _currentConversationId = conversation.id;
        _setLoading(false);
        return conversation;
      } else {
        try {
          final response = await _apiService.post(
            ApiConstants.conversationsEndpoint, 
            {'userId': userId}
          );

          if (response['success']) {
            final data = response['data'];
            final conversation = ConversationModel.fromJson(data);
            _currentConversationId = conversation.id;
            _setLoading(false);
            return conversation;
          } else {
            _handleError('Konuşma oluşturulurken hata oluştu: ${response['message'] ?? 'Bilinmeyen hata'}');
            return null;
          }
        } catch (e) {
          _handleError('Konuşma oluşturulurken hata oluştu: $e');
          return null;
        }
      }
    } catch (e) {
      _handleError('Konuşma oluşturulurken hata oluştu: $e');
      _setLoading(false);
      return null;
    }
  }

  Future<bool> loadMessages(String conversationId) async {
    _setLoading(true);
    _error = null;
    _currentConversationId = conversationId;

    try {
      if (_testMode) {
        // Test verileri
        await Future.delayed(const Duration(seconds: 1));
        _messages = _getTestMessages(conversationId);
        _setLoading(false);
        return true;
      } else {
        try {
          final endpoint = '${ApiConstants.conversationsEndpoint}/$conversationId/messages';
          final response = await _apiService.get(endpoint);

          if (response['success']) {
            final List<dynamic> data = response['data'];
            _messages = data
                .map((item) => MessageModel.fromJson(item))
                .toList();
            _setLoading(false);
            return true;
          } else {
            _handleError('Mesajlar yüklenirken hata oluştu: ${response['message'] ?? 'Bilinmeyen hata'}');
            return false;
          }
        } catch (e) {
          _handleError('Mesajlar yüklenirken hata oluştu: $e');
          return false;
        }
      }
    } catch (e) {
      _handleError('Mesajlar yüklenirken hata oluştu: $e');
      _setLoading(false);
      return false;
    }
  }

  // Mesaj gönder
  Future<bool> sendMessage(String receiverId, String content) async {
    _error = null;

    try {
      // Kullanıcı kontrolü
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        _handleError('Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.');
        return false;
      }

      if (content.trim().isEmpty) {
        _handleError('Mesaj içeriği boş olamaz');
        return false;
      }

      // Yeni mesaj oluştur
      final newMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: _currentConversationId ?? 'temp',
        senderId: currentUser.id,
        receiverId: receiverId,
        content: content,
        createdAt: DateTime.now(),
        isRead: false,
      );

      // Mesajı listeye ekle (optimistik güncelleme)
      _messages.add(newMessage);
      Future.microtask(() => notifyListeners());

      if (_testMode) {
        // Test modunda otomatik cevap
        await Future.delayed(const Duration(seconds: 2));
        
        // Rastgele cevaplar
        final responses = [
          'Tamam, anladım.',
          'Teşekkür ederim!',
          'Size nasıl yardımcı olabilirim?',
          'Bu konuda daha fazla bilgi verebilir misiniz?',
          'Harika! En kısa sürede ilgileneceğim.',
        ];
        
        final responseIndex = DateTime.now().second % responses.length;
        final responseMessage = MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: _currentConversationId ?? 'temp',
          senderId: receiverId,
          receiverId: currentUser.id,
          content: responses[responseIndex],
          createdAt: DateTime.now(),
          isRead: false,
        );
        
        _messages.add(responseMessage);
        Future.microtask(() => notifyListeners());
        return true;
      } else {
        try {
          final response = await _apiService.post(
            ApiConstants.messagesEndpoint,
            {
              'receiverId': receiverId,
              'content': content,
              'conversationId': _currentConversationId,
            }
          );

          if (response['success']) {
            // API'dan dönen gerçek mesajı kullan
            if (response['data'] != null) {
              // Optimistik mesajı kaldır ve gerçek mesajı ekle
              _messages.removeLast();
              final serverMessage = MessageModel.fromJson(response['data']);
              _messages.add(serverMessage);
              Future.microtask(() => notifyListeners());
            }
            return true;
          } else {
            // Optimistik mesajı kaldır
            _messages.removeLast();
            Future.microtask(() => notifyListeners());
            _handleError('Mesaj gönderilirken hata oluştu: ${response['message'] ?? 'Bilinmeyen hata'}');
            return false;
          }
        } catch (e) {
          // Optimistik mesajı kaldır
          _messages.removeLast();
          Future.microtask(() => notifyListeners());
          _handleError('Mesaj gönderilirken hata oluştu: $e');
          return false;
        }
      }
    } catch (e) {
      _handleError('Mesaj gönderilirken hata oluştu: $e');
      return false;
    }
  }

  // Mesajı okundu olarak işaretle
  Future<void> markMessageAsRead(String messageId) async {
    try {
      if (_testMode) {
        // Test modunda mesajı bul ve güncelle
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(isRead: true);
          notifyListeners();
        }
      } else {
        final token = await _authService.getToken();
        final response = await http.put(
          Uri.parse('${ApiConstants.baseUrl}/messaging/messages/$messageId/read'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode != 200) {
          _handleError('Mesaj okundu işaretlenirken hata oluştu: ${response.statusCode}');
        }
      }
    } catch (e) {
      _handleError('Mesaj okundu işaretlenirken hata oluştu: $e');
    }
  }

  // Tüm mesajları okundu olarak işaretle
  Future<void> markAllMessagesAsRead(String conversationId) async {
    try {
      if (_testMode) {
        // Test modunda tüm mesajları güncelle
        for (int i = 0; i < _messages.length; i++) {
          if (_messages[i].conversationId == conversationId && !_messages[i].isRead) {
            _messages[i] = _messages[i].copyWith(isRead: true);
          }
        }
        notifyListeners();
      } else {
        final token = await _authService.getToken();
        final response = await http.put(
          Uri.parse('${ApiConstants.baseUrl}/messaging/conversations/$conversationId/read-all'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode != 200) {
          _handleError('Mesajlar okundu işaretlenirken hata oluştu: ${response.statusCode}');
        }
      }
    } catch (e) {
      _handleError('Mesajlar okundu işaretlenirken hata oluştu: $e');
    }
  }

  // Yazıyor durumunu güncelle
  void setTypingStatus(bool isTyping) {
    _isTyping = isTyping;
    notifyListeners();
    
    // TODO: Gerçek uygulamada, yazıyor durumunu sunucuya bildir
  }

  // Yükleme durumunu güncelle
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      // Hemen notify etmek yerine, bir sonraki frame'de notify et
      Future.microtask(() => notifyListeners());
    }
  }

  // Hata durumunu güncelle
  void _handleError(String errorMessage) {
    _error = errorMessage;
    debugPrint('MessagingProvider Error: $errorMessage');
    // Hemen notify etmek yerine, bir sonraki frame'de notify et
    Future.microtask(() => notifyListeners());
  }

  // Test konuşmaları
  List<ConversationModel> _getTestConversations() {
    return [
      ConversationModel(
        id: 'conv1',
        userId: 'user1',
        userName: 'Ahmet Yılmaz',
        lastMessage: 'Merhaba, nasılsınız?',
        unreadCount: 2,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isOnline: true,
      ),
      ConversationModel(
        id: 'conv2',
        userId: 'user2',
        userName: 'Ayşe Demir',
        lastMessage: 'Toplantı saat 15:00\'te başlayacak.',
        unreadCount: 0,
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        isOnline: false,
      ),
      ConversationModel(
        id: 'conv3',
        userId: 'user3',
        userName: 'Mehmet Kaya',
        lastMessage: 'Dosyaları inceledim, yarın konuşalım.',
        unreadCount: 1,
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        isOnline: true,
      ),
    ];
  }

  // Test konuşması
  ConversationModel _getTestConversation(String userId) {
    return ConversationModel(
      id: 'conv_$userId',
      userId: userId,
      userName: userId == 'user1' ? 'Ahmet Yılmaz' : 
               userId == 'user2' ? 'Ayşe Demir' : 
               userId == 'user3' ? 'Mehmet Kaya' : 'Kullanıcı',
      lastMessage: '',
      unreadCount: 0,
      updatedAt: DateTime.now(),
      isOnline: true,
    );
  }

  // Test mesajları
  List<MessageModel> _getTestMessages(String conversationId) {
    final currentUser = 'current_user'; // Normalde auth provider'dan alınacak
    final otherUser = conversationId.replaceAll('conv_', '');
    
    final now = DateTime.now();
    
    return [
      MessageModel(
        id: '1',
        conversationId: conversationId,
        senderId: otherUser,
        receiverId: currentUser,
        content: 'Merhaba, nasılsınız?',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
      ),
      MessageModel(
        id: '2',
        conversationId: conversationId,
        senderId: currentUser,
        receiverId: otherUser,
        content: 'İyiyim, teşekkür ederim. Siz nasılsınız?',
        createdAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 45)),
        isRead: true,
      ),
      MessageModel(
        id: '3',
        conversationId: conversationId,
        senderId: otherUser,
        receiverId: currentUser,
        content: 'Ben de iyiyim. Bugün toplantımız var mı?',
        createdAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 30)),
        isRead: true,
      ),
      MessageModel(
        id: '4',
        conversationId: conversationId,
        senderId: currentUser,
        receiverId: otherUser,
        content: 'Evet, saat 14:00\'te toplantı salonunda buluşalım.',
        createdAt: now.subtract(const Duration(days: 1, hours: 1)),
        isRead: true,
      ),
      MessageModel(
        id: '5',
        conversationId: conversationId,
        senderId: otherUser,
        receiverId: currentUser,
        content: 'Tamam, orada görüşürüz.',
        createdAt: now.subtract(const Duration(days: 1, minutes: 45)),
        isRead: true,
      ),
      MessageModel(
        id: '6',
        conversationId: conversationId,
        senderId: currentUser,
        receiverId: otherUser,
        content: 'Toplantı için hazırladığım dokümanları inceleyebilir misiniz?',
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      MessageModel(
        id: '7',
        conversationId: conversationId,
        senderId: otherUser,
        receiverId: currentUser,
        content: 'Tabii ki, hemen bakıyorum.',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 30)),
        isRead: true,
      ),
      MessageModel(
        id: '8',
        conversationId: conversationId,
        senderId: otherUser,
        receiverId: currentUser,
        content: 'Dokümanları inceledim, çok iyi hazırlanmış. Sadece son sayfada birkaç düzeltme gerekiyor.',
        createdAt: now.subtract(const Duration(hours: 1)),
        isRead: false,
      ),
    ];
  }
} 