import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_community_ai/core/models/payment_model.dart';
import 'package:crypto/crypto.dart';

class PaymentService {
  final String _apiKey;
  final String _secretKey;
  final String _baseUrl;
  final bool _isTestMode;

  PaymentService({
    String? apiKey,
    String? secretKey,
    String? baseUrl,
    bool isTestMode = true,
  }) : 
    _apiKey = apiKey ?? _getEnvOrDefault('IYZICO_API_KEY', 'sandbox-yElAsB1MwMSp4q3R1aTmVxa2dgbSza0C'),
    _secretKey = secretKey ?? _getEnvOrDefault('IYZICO_SECRET_KEY', 'sandbox-OfLB37nYAKeGTj2Rjc2MCCMXjYDRdilH'),
    _baseUrl = baseUrl ?? _getEnvOrDefault('IYZICO_BASE_URL', 'https://sandbox-api.iyzipay.com'),
    _isTestMode = isTestMode;

  // Güvenli bir şekilde .env değerlerini almak için yardımcı metod
  static String _getEnvOrDefault(String key, String defaultValue) {
    try {
      return dotenv.env[key] ?? defaultValue;
    } catch (e) {
      debugPrint('Dotenv hatası: $e');
      return defaultValue;
    }
  }

  // İyzico için gerekli olan random string oluşturma
  String _generateRandomString() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // İyzico için gerekli olan hash oluşturma
  String _generateAuthorizationHeader(Map<String, dynamic> request) {
    try {
      final randomString = _generateRandomString();
      final requestString = jsonEncode(request);
      
      final hashStr = _apiKey + randomString + _secretKey + requestString;
      final bytes = utf8.encode(hashStr);
      final digest = base64.encode(sha1.convert(bytes).bytes);
      
      return 'IYZWS $_apiKey:$digest';
    } catch (e) {
      debugPrint('Hash oluşturma hatası: $e');
      return '';
    }
  }

  // Test kartı bilgilerini döndüren metod
  Map<String, String> getTestCardInfo() {
    return {
      'cardHolderName': 'John Doe',
      'cardNumber': '5528790000000008',
      'expireMonth': '12',
      'expireYear': '2030',
      'cvc': '123',
    };
  }

  // Ödeme başlatma
  Future<Map<String, dynamic>> createPayment({
    required String userId,
    required String userName,
    required String userEmail,
    required double amount,
    required String description,
    required Map<String, dynamic> cardInfo,
  }) async {
    try {
      // Kullanıcı adını parçalara ayır
      List<String> nameParts = userName.split(' ');
      String firstName = nameParts.isNotEmpty ? nameParts.first : 'John';
      String lastName = nameParts.length > 1 ? nameParts.last : 'Doe';
      
      // Benzersiz bir conversationId oluştur
      final conversationId = 'site_aidat_${DateTime.now().millisecondsSinceEpoch}';
      
      // İyzico'nun istediği formatta veri hazırlama
      final request = {
        'locale': 'tr',
        'conversationId': conversationId,
        'price': amount.toString(),
        'paidPrice': amount.toString(),
        'currency': 'TRY',
        'installment': '1',
        'basketId': 'aidat_${DateTime.now().millisecondsSinceEpoch}',
        'paymentChannel': 'WEB',
        'paymentGroup': 'PRODUCT',
        'callbackUrl': 'https://www.site-yonetimi.com/odeme-sonuc',
        'paymentCard': {
          'cardHolderName': cardInfo['cardHolderName'],
          'cardNumber': cardInfo['cardNumber'].toString().replaceAll(' ', ''),
          'expireMonth': cardInfo['expireMonth'],
          'expireYear': cardInfo['expireYear'],
          'cvc': cardInfo['cvc'],
          'registerCard': '0'
        },
        'buyer': {
          'id': userId,
          'name': firstName,
          'surname': lastName,
          'gsmNumber': '+905350000000',
          'email': userEmail,
          'identityNumber': '74300864791',
          'lastLoginDate': DateTime.now().toIso8601String(),
          'registrationDate': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          'registrationAddress': 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
          'ip': '85.34.78.112',
          'city': 'Istanbul',
          'country': 'Turkey',
          'zipCode': '34732'
        },
        'shippingAddress': {
          'contactName': '$firstName $lastName',
          'city': 'Istanbul',
          'country': 'Turkey',
          'address': 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
          'zipCode': '34732'
        },
        'billingAddress': {
          'contactName': '$firstName $lastName',
          'city': 'Istanbul',
          'country': 'Turkey',
          'address': 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
          'zipCode': '34732'
        },
        'basketItems': [
          {
            'id': 'aidat_item',
            'name': description,
            'category1': 'Site Aidatı',
            'itemType': 'VIRTUAL',
            'price': amount.toString()
          }
        ]
      };

      // İyzico API'sine istek gönder
      return await _makeRequest('/payment/auth/3dsecure/initialize', request);
    } catch (e) {
      debugPrint('Ödeme işlemi sırasında hata: $e');
      return {'status': 'error', 'errorMessage': e.toString()};
    }
  }

  // Ödeme sonucunu kontrol etme
  Future<Map<String, dynamic>> checkPaymentResult(String token) async {
    try {
      final request = {
        'locale': 'tr',
        'conversationId': 'site_aidat_check_${DateTime.now().millisecondsSinceEpoch}',
        'paymentId': token,
      };

      return await _makeRequest('/payment/3dsecure/auth', request);
    } catch (e) {
      return {'status': 'error', 'errorMessage': e.toString()};
    }
  }

  // İyzico API'sine istek gönderme
  Future<Map<String, dynamic>> _makeRequest(String endpoint, Map<String, dynamic> request) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      
      // API isteği için gerekli başlıklar
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': _generateAuthorizationHeader(request),
      };

      final requestBody = jsonEncode(request);
      
      debugPrint('İyzico isteği: $requestBody');
      debugPrint('İyzico başlıkları: $headers');

      final response = await http.post(
        url,
        headers: headers,
        body: requestBody,
      );

      debugPrint('İyzico yanıt kodu: ${response.statusCode}');
      debugPrint('İyzico yanıt içeriği: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'errorCode': response.statusCode.toString(),
          'errorMessage': 'API isteği başarısız: ${response.body}',
        };
      }
    } catch (e) {
      debugPrint('API isteği sırasında hata: $e');
      return {'status': 'error', 'errorMessage': e.toString()};
    }
  }

  // Test için ödeme simülasyonu
  Future<Map<String, dynamic>> simulatePayment({
    required String userId,
    required String userName,
    required String userEmail,
    required double amount,
    required String description,
    required Map<String, dynamic> cardInfo,
  }) async {
    // Test ortamında başarılı bir ödeme simülasyonu
    await Future.delayed(const Duration(milliseconds: 800)); // Gerçekçi bir gecikme ekle
    
    return {
      'status': 'success',
      'locale': 'tr',
      'systemTime': DateTime.now().millisecondsSinceEpoch,
      'conversationId': 'site_aidat_${DateTime.now().millisecondsSinceEpoch}',
      'price': amount,
      'paidPrice': amount,
      'currency': 'TRY',
      'installment': 1,
      'paymentId': 'test_payment_${DateTime.now().millisecondsSinceEpoch}',
      'fraudStatus': 1,
      'merchantCommissionRate': 0,
      'merchantCommissionRateAmount': 0,
      'threeDSHtmlContent': '<html><body>3D Secure Simulation</body></html>',
    };
  }

  // Kullanıcının ödemelerini getirme (Test verisi)
  Future<List<PaymentModel>> getUserPayments(String userId) async {
    // Gerçek uygulamada, bu verileri İyzico API'sinden veya kendi veritabanınızdan alabilirsiniz
    await Future.delayed(const Duration(milliseconds: 500)); // Simüle edilmiş gecikme
    
    return [
      PaymentModel(
        id: '1',
        title: 'Ocak Ayı Aidatı',
        description: 'Ocak 2023 ayı site aidatı',
        amount: 500.0,
        userId: userId,
        dueDate: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        paidAt: DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
        createdAt: DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
      ),
      PaymentModel(
        id: '2',
        title: 'Şubat Ayı Aidatı',
        description: 'Şubat 2023 ayı site aidatı',
        amount: 500.0,
        userId: userId,
        dueDate: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];
  }

  // Tüm ödemeleri getirme (Yönetici için)
  Future<List<PaymentModel>> getAllPayments() async {
    // Gerçek uygulamada, bu verileri İyzico API'sinden veya kendi veritabanınızdan alabilirsiniz
    await Future.delayed(const Duration(milliseconds: 500)); // Simüle edilmiş gecikme
    
    return [
      PaymentModel(
        id: '1',
        title: 'Ocak Ayı Aidatı',
        description: 'Ocak 2023 ayı site aidatı',
        amount: 500.0,
        userId: 'user1',
        dueDate: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        paidAt: DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
        createdAt: DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
      ),
      PaymentModel(
        id: '2',
        title: 'Şubat Ayı Aidatı',
        description: 'Şubat 2023 ayı site aidatı',
        amount: 500.0,
        userId: 'user1',
        dueDate: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      PaymentModel(
        id: '3',
        title: 'Ocak Ayı Aidatı',
        description: 'Ocak 2023 ayı site aidatı',
        amount: 500.0,
        userId: 'user2',
        dueDate: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        paidAt: DateTime.now().subtract(const Duration(days: 28)).toIso8601String(),
        createdAt: DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 28)).toIso8601String(),
      ),
    ];
  }
} 