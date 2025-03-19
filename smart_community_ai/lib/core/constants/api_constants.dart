import 'dart:io' as io;

class ApiConstants {
  // Ana URL
  static const String baseUrl = 'http://localhost:5000';
  
  // Yedek URL'ler
  static const String backupUrl1 = 'http://127.0.0.1:5000';
  static const String backupUrl2 = 'http://localhost:3000';
  
  // Test (geliştirme) modu veya üretim modu
  static const bool isTestMode = true;
  
  // API zaman aşımı süresi (saniye)
  static const int timeoutDuration = 60;
  
  // Messaging endpoint'leri
  static const String messagingEndpoint = 'api/messaging';
  static const String conversationsEndpoint = 'api/messaging/conversations';
  static const String messagesEndpoint = 'api/messaging/messages';
  
  // Auth endpoint'leri
  static const String authEndpoint = 'api/auth';
  static const String loginEndpoint = 'api/auth/login';
  static const String registerEndpoint = 'api/auth/register';
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