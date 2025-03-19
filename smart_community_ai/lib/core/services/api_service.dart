import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_community_ai/core/models/user_model.dart';
import 'package:smart_community_ai/core/models/payment_model.dart';
import 'package:smart_community_ai/core/models/announcement_model.dart';
import 'package:smart_community_ai/core/models/notification_model.dart';
import 'package:smart_community_ai/core/models/issue_model.dart';
import 'package:smart_community_ai/core/models/survey_model.dart';
import 'package:smart_community_ai/core/models/message_model.dart';
import 'package:smart_community_ai/core/constants/api_constants.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;
  final int maxRetries;
  final bool isTestMode;

  ApiService({
    required this.baseUrl,
    http.Client? client,
    this.maxRetries = 3,
    this.isTestMode = ApiConstants.isTestMode,
  }) : _client = client ?? http.Client();

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        print('Token bulundu: ${token.substring(0, math.min(token.length, 10))}...');
      } else {
        print('Token bulunamadı!');
      }
      return token;
    } catch (e) {
      print('Token alınırken hata: $e');
      return null;
    }
  }

  Map<String, String> _getHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      print('Authorization header eklendi');
    } else {
      print('Token olmadığı için Authorization header eklenemedi');
    }
    
    return headers;
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams, int retryCount = 0}) async {
    // Test modunda ve auth endpoint'i değilse sahte yanıt döndür
    if (isTestMode && !endpoint.contains('/auth')) {
      print('TEST MODE: GET isteği simüle ediliyor: $endpoint');
      await Future.delayed(const Duration(milliseconds: 500)); // Gerçekçi gecikme
      return {'success': true, 'data': []};
    }
    
    try {
      final uri = ApiConstants.buildUri(endpoint, queryParams);
      print('GET isteği gönderiliyor: $uri');
      
      final token = await _getToken();
      final response = await _client.get(
        uri,
        headers: _getHeaders(token),
      ).timeout(Duration(seconds: ApiConstants.timeoutDuration));
      
      print('GET yanıtı: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('GET hatası: $e');
      return {'success': false, 'message': 'İstek gönderilirken hata oluştu: $e'};
    }
  }

  Future<dynamic> post(String endpoint, dynamic data, {int retryCount = 0}) async {
    // Test modunda ve auth endpoint'i değilse sahte yanıt döndür
    if (isTestMode && !endpoint.contains('/auth')) {
      print('TEST MODE: POST isteği simüle ediliyor: $endpoint');
      await Future.delayed(const Duration(milliseconds: 500)); // Gerçekçi gecikme
      return {'success': true, 'data': {}};
    }
    
    try {
      final uri = ApiConstants.buildUri(endpoint);
      print('POST isteği gönderiliyor: $uri');
      
      final token = await _getToken();
      final response = await _client.post(
        uri,
        headers: _getHeaders(token),
        body: json.encode(data),
      ).timeout(Duration(seconds: ApiConstants.timeoutDuration));
      
      print('POST yanıtı: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('POST hatası: $e');
      return {'success': false, 'message': 'İstek gönderilirken hata oluştu: $e'};
    }
  }

  Future<dynamic> put(String endpoint, dynamic data, {int retryCount = 0}) async {
    // Test modunda ve auth endpoint'i değilse sahte yanıt döndür
    if (isTestMode && !endpoint.contains('/auth')) {
      print('TEST MODE: PUT isteği simüle ediliyor: $endpoint');
      await Future.delayed(const Duration(milliseconds: 500)); // Gerçekçi gecikme
      return {'success': true, 'data': {}};
    }
    
    try {
      final uri = ApiConstants.buildUri(endpoint);
      print('PUT isteği gönderiliyor: $uri');
      
      final token = await _getToken();
      final response = await _client.put(
        uri,
        headers: _getHeaders(token),
        body: json.encode(data),
      ).timeout(Duration(seconds: ApiConstants.timeoutDuration));
      
      print('PUT yanıtı: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('PUT hatası: $e');
      return {'success': false, 'message': 'İstek gönderilirken hata oluştu: $e'};
    }
  }

  Future<dynamic> delete(String endpoint, {int retryCount = 0}) async {
    // Test modunda ve auth endpoint'i değilse sahte yanıt döndür
    if (isTestMode && !endpoint.contains('/auth')) {
      print('TEST MODE: DELETE isteği simüle ediliyor: $endpoint');
      await Future.delayed(const Duration(milliseconds: 500)); // Gerçekçi gecikme
      return {'success': true};
    }
    
    try {
      final uri = ApiConstants.buildUri(endpoint);
      print('DELETE isteği gönderiliyor: $uri');
      
      final token = await _getToken();
      final response = await _client.delete(
        uri,
        headers: _getHeaders(token),
      ).timeout(Duration(seconds: ApiConstants.timeoutDuration));
      
      print('DELETE yanıtı: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('DELETE hatası: $e');
      return {'success': false, 'message': 'İstek gönderilirken hata oluştu: $e'};
    }
  }

  dynamic _handleResponse(http.Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          print('Başarılı yanıt, boş gövde');
          return {'success': true};
        }
        
        try {
          final jsonResponse = jsonDecode(response.body);
          print('Başarılı yanıt: ${jsonResponse.toString().substring(0, math.min(100, jsonResponse.toString().length))}...');
          return jsonResponse;
        } catch (e) {
          print('Yanıt ayrıştırma hatası: $e');
          print('Ham yanıt: ${response.body.substring(0, math.min(100, response.body.length))}...');
          return {'success': true, 'raw_response': response.body};
        }
      } else if (response.statusCode == 401) {
        print('Kimlik doğrulama hatası (401): Oturum sonlanmış olabilir');
        return {
          'success': false,
          'error': 'auth_error',
          'message': 'Oturumunuz sonlanmış. Lütfen tekrar giriş yapın.'
        };
      } else if (response.statusCode == 404) {
        print('Kaynak bulunamadı hatası (404)');
        return {
          'success': false,
          'error': 'not_found',
          'message': 'İstenen kaynak bulunamadı.'
        };
      } else if (response.statusCode >= 500) {
        print('Sunucu hatası (${response.statusCode})');
        return {
          'success': false,
          'error': 'server_error',
          'message': 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.'
        };
      } else {
        try {
          if (response.body.isEmpty) {
            print('Hata yanıtı, boş gövde. Durum kodu: ${response.statusCode}');
            return {
              'success': false,
              'error': 'http_error',
              'message': 'HTTP Hatası: ${response.statusCode} - ${response.reasonPhrase}'
            };
          }
          
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? 'Bilinmeyen hata';
          print('API Hatası: $errorMessage');
          return {
            'success': false,
            'error': errorData['error'] ?? 'api_error',
            'message': errorMessage
          };
        } catch (e) {
          print('Hata yanıtı ayrıştırma hatası: $e');
          return {
            'success': false,
            'error': 'parse_error',
            'message': 'API Hatası: ${response.statusCode} - ${response.reasonPhrase}'
          };
        }
      }
    } catch (e) {
      print('_handleResponse içinde beklenmeyen hata: $e');
      return {
        'success': false,
        'error': 'unexpected_error',
        'message': 'Beklenmeyen bir hata oluştu: $e'
      };
    }
  }

  // Kimlik doğrulama işlemleri
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Login isteği gönderiliyor: $email');
      final uri = ApiConstants.buildUri(ApiConstants.loginEndpoint);
      print('API URL: $uri');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: ApiConstants.timeoutDuration), onTimeout: () {
        throw TimeoutException('Login isteği zaman aşımına uğradı');
      });
      
      print('Login yanıtı alındı: ${response.statusCode}');
      
      final data = _handleResponse(response);
      
      // Token'ı kaydet
      if (data['token'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        print('Token kaydedildi');
      }
      
      return data;
    } on SocketException catch (e) {
      print('Login için bağlantı hatası: $e');
      throw Exception('Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.');
    } on TimeoutException catch (e) {
      print('Login zaman aşımı: $e');
      throw Exception('Login isteği zaman aşımına uğradı. Lütfen daha sonra tekrar deneyin.');
    } catch (e) {
      print('Login hatası: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    
    return _handleResponse(response);
  }

  Future<bool> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    return true;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/forgot-password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'email': email,
      }),
    );
    
    return _handleResponse(response);
  }

  // Kullanıcı işlemleri
  Future<UserModel> getUserProfile() async {
    try {
      print('Kullanıcı profili alınıyor...');
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/profile'),
        headers: await _getHeaders(await _getToken()),
      );
      
      print('Profil yanıtı: ${response.statusCode}');
      
      if (response.statusCode == 401) {
        throw Exception('Yetkilendirme hatası: Lütfen tekrar giriş yapın');
      }
      
      final data = _handleResponse(response);
      
      if (data['data'] != null) {
        print('Kullanıcı profili başarıyla alındı');
        return UserModel.fromJson(data['data']);
      } else if (data['user'] != null) {
        print('Kullanıcı profili başarıyla alındı (user key)');
        return UserModel.fromJson(data['user']);
      } else {
        throw Exception('Kullanıcı profili alınamadı: Veri formatı hatalı');
      }
    } catch (e) {
      print('Kullanıcı profili alınırken hata: $e');
      throw e;
    }
  }

  Future<UserModel> updateUserProfile(Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/profile'),
      headers: await _getHeaders(await _getToken()),
      body: json.encode(userData),
    );
    
    final data = _handleResponse(response);
    return UserModel.fromJson(data['data']);
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/change-password'),
      headers: await _getHeaders(await _getToken()),
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    
    return _handleResponse(response);
  }

  // Ödeme işlemleri
  Future<List<PaymentModel>> getPayments() async {
    try {
      print('Ödemeler alınıyor...');
      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/user'),
        headers: await _getHeaders(await _getToken()),
      );
      
      print('Ödemeler yanıtı: ${response.statusCode}');
      
      final data = _handleResponse(response);
      print('Ödemeler başarıyla alındı: ${data['data']?.length ?? 0} adet');
      
      if (data['data'] != null) {
        return (data['data'] as List)
            .map((payment) => PaymentModel.fromJson(payment))
            .toList();
      }
      return [];
    } catch (e) {
      print('Ödemeler alınırken hata: $e');
      return [];
    }
  }
  
  Future<PaymentModel?> getPaymentById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/$id'),
        headers: await _getHeaders(await _getToken()),
      );
      
      final data = _handleResponse(response);
      
      if (data['data'] != null) {
        return PaymentModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Ödeme detayı alınırken hata: $e');
      return null;
    }
  }
  
  Future<bool> makePayment(String paymentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/$paymentId/pay'),
        headers: await _getHeaders(await _getToken()),
      );
      
      final data = _handleResponse(response);
      
      return data['success'] == true;
    } catch (e) {
      print('Ödeme yapılırken hata: $e');
      return false;
    }
  }
  
  Future<Map<String, dynamic>> getTotalPayments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/total'),
        headers: await _getHeaders(await _getToken()),
      );
      
      final data = _handleResponse(response);
      
      if (data['success'] == true && data['data'] != null) {
        return data['data'];
      }
      return {
        'total': 0,
        'count': 0,
        'monthly': []
      };
    } catch (e) {
      print('Toplam ödemeler alınırken hata: $e');
      return {
        'total': 0,
        'count': 0,
        'monthly': []
      };
    }
  }

  // Duyuru işlemleri
  Future<List<dynamic>> getAnnouncements() async {
    try {
      print('Duyurular alınıyor...');
      final response = await http.get(
        Uri.parse('$baseUrl/api/announcements'),
        headers: await _getHeaders(await _getToken()),
      );
      
      print('Duyurular yanıtı: ${response.statusCode}');
      
      final data = _handleResponse(response);
      print('Duyurular başarıyla alındı: ${data['data']?.length ?? 0} adet');
      return data['data'] ?? [];
    } catch (e) {
      print('Duyurular alınırken hata: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getAnnouncementById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/announcements/$id'),
      headers: await _getHeaders(await _getToken()),
    );
    
    return _handleResponse(response);
  }

  // Bildirim işlemleri
  Future<List<dynamic>> getNotifications() async {
    try {
      print('Bildirimler alınıyor...');
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/user'),
        headers: await _getHeaders(await _getToken()),
      );
      
      print('Bildirimler yanıtı: ${response.statusCode}');
      
      final data = _handleResponse(response);
      print('Bildirimler başarıyla alındı: ${data['data']?.length ?? 0} adet');
      
      return data['data'] ?? [];
    } catch (e) {
      print('Bildirimler alınırken hata: $e');
      return [];
    }
  }
  
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
        headers: await _getHeaders(await _getToken()),
      );
      
      final data = _handleResponse(response);
      
      return data['success'] == true;
    } catch (e) {
      print('Bildirim okundu olarak işaretlenirken hata: $e');
      return false;
    }
  }
  
  Future<bool> markAllNotificationsAsRead() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/read-all'),
        headers: await _getHeaders(await _getToken()),
      );
      
      final data = _handleResponse(response);
      
      return data['success'] == true;
    } catch (e) {
      print('Tüm bildirimler okundu olarak işaretlenirken hata: $e');
      return false;
    }
  }

  // Arıza bildirimi işlemleri
  Future<List<dynamic>> getFaults() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/faults'),
      headers: await _getHeaders(await _getToken()),
    );
    
    final data = _handleResponse(response);
    return data['data'];
  }

  Future<Map<String, dynamic>> getFaultById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/faults/$id'),
      headers: await _getHeaders(await _getToken()),
    );
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createFault(Map<String, dynamic> faultData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/faults'),
      headers: await _getHeaders(await _getToken()),
      body: json.encode(faultData),
    );
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateFault(String id, Map<String, dynamic> faultData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/faults/$id'),
      headers: await _getHeaders(await _getToken()),
      body: json.encode(faultData),
    );
    
    return _handleResponse(response);
  }

  // Anket işlemleri
  Future<List<dynamic>> getSurveys() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/surveys'),
      headers: await _getHeaders(await _getToken()),
    );
    
    final data = _handleResponse(response);
    return data['data'];
  }

  Future<Map<String, dynamic>> getSurveyById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/surveys/$id'),
      headers: await _getHeaders(await _getToken()),
    );
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> submitSurveyResponse(String id, Map<String, dynamic> responseData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/surveys/$id/respond'),
      headers: await _getHeaders(await _getToken()),
      body: json.encode(responseData),
    );
    
    return _handleResponse(response);
  }

  // Mesajlaşma işlemleri
  Future<List<dynamic>> getConversations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/messages'),
      headers: await _getHeaders(await _getToken()),
    );
    
    final data = _handleResponse(response);
    return data['data'];
  }

  Future<Map<String, dynamic>> getConversationById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/messages/$id'),
      headers: await _getHeaders(await _getToken()),
    );
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createConversation(Map<String, dynamic> conversationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/messages'),
      headers: await _getHeaders(await _getToken()),
      body: json.encode(conversationData),
    );
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> sendMessage(String conversationId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/messages/$conversationId/messages'),
      headers: await _getHeaders(await _getToken()),
      body: json.encode({
        'content': content,
      }),
    );
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> markConversationAsRead(String id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/messages/$id/read'),
      headers: await _getHeaders(await _getToken()),
    );
    
    return _handleResponse(response);
  }

  // Dosya yükleme
  Future<List<String>> uploadFiles(List<File> files) async {
    try {
      List<String> uploadedFileUrls = [];
      
      for (var file in files) {
        // Multipart request oluştur
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/api/upload'),
        );
        
        // Token ekle
        final headers = await _getHeaders(await _getToken());
        request.headers.addAll(headers);
        
        // Dosyayı ekle
        var fileStream = http.ByteStream(file.openRead());
        var length = await file.length();
        var multipartFile = http.MultipartFile(
          'file',
          fileStream,
          length,
          filename: file.path.split('/').last,
        );
        
        request.files.add(multipartFile);
        
        // İsteği gönder
        var response = await request.send();
        
        // Yanıtı kontrol et
        if (response.statusCode >= 200 && response.statusCode < 300) {
          var responseData = await response.stream.bytesToString();
          var data = json.decode(responseData);
          uploadedFileUrls.add(data['fileUrl']);
        } else {
          throw Exception('Dosya yükleme hatası: ${response.statusCode}');
        }
      }
      
      return uploadedFileUrls;
    } catch (e) {
      print('Dosya yükleme hatası: $e');
      throw e;
    }
  }

  // Arıza bildirimi oluştur
  Future<Map<String, dynamic>> createIssue(Map<String, dynamic> issueData, List<File>? images) async {
    try {
      // Önce dosyaları yükle
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        imageUrls = await uploadFiles(images);
      }
      
      // Arıza verilerine dosya URL'lerini ekle
      issueData['images'] = imageUrls;
      
      // Arıza bildirimini oluştur
      final response = await http.post(
        Uri.parse('$baseUrl/api/faults'),
        headers: await _getHeaders(await _getToken()),
        body: json.encode(issueData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      print('Arıza bildirimi oluşturulurken hata: $e');
      throw e;
    }
  }
} 