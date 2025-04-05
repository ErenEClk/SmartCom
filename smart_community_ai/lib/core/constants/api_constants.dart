import 'dart:io' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Ana URL - Güvenli erişim için getter kullanıyoruz
  static String get baseUrl {
    try {
      return dotenv.env['API_URL'] ?? 'http://localhost:5000';
    } catch (e) {
      return 'http://localhost:5000';
    }
  }
  
  // Yedek URL'ler
  static const String backupUrl1 = 'http://127.0.0.1:5000';
  static const String backupUrl2 = 'http://localhost:3000';
  
  // Test (geliştirme) modu veya üretim modu
  static const bool isTestMode = true; // Gerçek istekler göndermek için false
  
  // Dotenv'den değeri almak için yardımcı metod
  static bool getTestMode() {
    try {
      return (dotenv.env['IS_TEST_MODE'] ?? 'true') == 'true';
    } catch (e) {
      return true; // Hata durumunda varsayılan olarak test modu aktif
    }
  }
  
  // API zaman aşımı süresi (saniye)
  static const int timeoutDuration = 15;
  
  // Messaging endpoint'leri
  static const String messagingEndpoint = 'api/messaging';
  static const String conversationsEndpoint = 'api/messaging/conversations';
  static const String messagesEndpoint = 'api/messaging/messages';
  
  // Auth endpoint'leri - Güvenli erişim için getter kullanıyoruz
  static String get authEndpoint {
    try {
      return dotenv.env['AUTH_ENDPOINT'] ?? 'api/auth';
    } catch (e) {
      return 'api/auth';
    }
  }
  
  static String get loginEndpoint {
    try {
      return dotenv.env['LOGIN_ENDPOINT'] ?? 'api/auth/login';
    } catch (e) {
      return 'api/auth/login';
    }
  }
  
  static String get registerEndpoint {
    try {
      return dotenv.env['REGISTER_ENDPOINT'] ?? 'api/auth/register';
    } catch (e) {
      return 'api/auth/register';
    }
  }
  
  static const String logoutEndpoint = 'api/auth/logout';
  
  // User endpoint'leri
  static const String usersEndpoint = 'api/users';
  
  // Anket endpoint'leri
  static const String surveysEndpoint = 'api/surveys';
  static const String surveyResponsesEndpoint = 'api/surveys/responses';
  static const String activeSurveysEndpoint = 'api/surveys/active';
  static const String pastSurveysEndpoint = 'api/surveys/past';
  
  // Diğer endpoint'ler
  static const String announcementsEndpoint = 'api/announcements';
  static const String notificationsEndpoint = 'api/notifications';
  static const String paymentsEndpoint = 'api/payments';
  static const String issuesEndpoint = 'api/issues';
  
  // URL'i almak için metod (ileride çeşitli koşullara göre farklı URL'ler döndürebiliriz)
  static String getBaseUrl() {
    try {
      // Platform kontrolünü güvenli bir şekilde yap
      bool isAndroid = false;
      try {
        isAndroid = io.Platform.isAndroid;
      } catch (e) {
        // Web platformunda veya diğer ortamlarda bu hata oluşabilir, görmezden gel
      }
      
      if (isAndroid) {
        // Android emülatör için 10.0.2.2 IP'sini kullan (localhost yerine)
        return 'http://10.0.2.2:5000';
      }
      return baseUrl;
    } catch (e) {
      print('baseUrl alınırken hata: $e, yedek URL döndürülüyor');
      return backupUrl1;
    }
  }
  
  // HTTP durum kodlarını kontrol etmek için yardımcı metod
  static bool isSuccessful(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }
  
  // Endpoint URI oluşturucu
  static Uri buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final baseUrl = getBaseUrl();
    
    // Endpoint'i temizle (başında/sonundaki slash'leri kaldır)
    final cleanEndpoint = endpoint.replaceAll(RegExp(r'^\/+|\/+$'), '');
    
    // Doğru URI oluştur
    final uri = Uri.parse('$baseUrl/$cleanEndpoint');
    
    if (queryParams != null && queryParams.isNotEmpty) {
      // Sorgu parametreleri varsa, onları ekleyerek yeni bir URI oluştur
      return Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.port,
        path: uri.path,
        queryParameters: queryParams,
      );
    }
    
    return uri;
  }
} 