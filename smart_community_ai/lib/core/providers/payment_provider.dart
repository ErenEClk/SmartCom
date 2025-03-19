import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:smart_community_ai/core/models/payment_model.dart';
import 'package:smart_community_ai/core/services/api_service.dart';

class PaymentProvider extends ChangeNotifier {
  final ApiService _apiService;
  final bool isTestMode;
  
  bool _isLoading = false;
  String? _error;
  List<PaymentModel> _payments = [];
  Map<String, dynamic>? _totalPayments;

  PaymentProvider({
    required ApiService apiService,
    this.isTestMode = false, // Test modunu varsayılan olarak devre dışı bırak
  }) : _apiService = apiService;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PaymentModel> get payments => _payments;
  Map<String, dynamic>? get totalPayments => _totalPayments;
  
  List<PaymentModel> get pendingPayments => _payments.where((payment) => !payment.isPaid).toList();
  List<PaymentModel> get paidPayments => _payments.where((payment) => payment.isPaid).toList();
  
  double get totalPendingAmount => pendingPayments.fold(0, (sum, payment) => sum + payment.amount);
  double get totalPaidAmount => paidPayments.fold(0, (sum, payment) => sum + payment.amount);

  Future<List<PaymentModel>> fetchPayments() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (isTestMode) {
        // Önce yerel depolamadan yüklemeyi dene
        final localPayments = await _loadPaymentsFromLocal();
        if (localPayments.isNotEmpty) {
          _payments = localPayments;
          _isLoading = false;
          notifyListeners();
          return _payments;
        }
        
        // Yerel depolamada veri yoksa test verilerini yükle
        await Future.delayed(const Duration(seconds: 1));
        _payments = _getTestPayments();
        
        // Test verilerini yerel depolamaya kaydet
        await _savePaymentsToLocal(_payments);
        
        _isLoading = false;
        notifyListeners();
        return _payments;
      }

      // Normal API çağrısı
      final response = await _apiService.get('/api/payments');
      
      if (response['success']) {
        final List<dynamic> data = response['data'];
        _payments = data.map((item) => PaymentModel.fromJson(item)).toList();
      } else {
        _error = response['message'] ?? 'Ödemeler alınamadı';
        _payments = [];
      }
      
      // Ödemeleri SharedPreferences'a kaydet
      await _savePaymentsToLocal(_payments);
      
      _isLoading = false;
      notifyListeners();
      return _payments;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      
      // Yerel depolamadan ödemeleri yüklemeyi dene
      final localPayments = await _loadPaymentsFromLocal();
      if (localPayments.isNotEmpty) {
        _payments = localPayments;
      } else {
        _payments = [];
      }
      
      notifyListeners();
      return _payments;
    }
  }

  // Ödemeleri yerel depolamaya kaydet
  Future<void> _savePaymentsToLocal(List<PaymentModel> payments) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paymentsJson = payments.map((p) => p.toJson()).toList();
      await prefs.setString('payments', jsonEncode(paymentsJson));
      debugPrint('Ödemeler yerel depolamaya kaydedildi: ${payments.length} adet');
    } catch (e) {
      debugPrint('Ödemeler yerel depolamaya kaydedilirken hata: $e');
    }
  }
  
  // Ödemeleri yerel depolamadan yükle
  Future<List<PaymentModel>> _loadPaymentsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paymentsJson = prefs.getString('payments');
      
      if (paymentsJson != null) {
        final List<dynamic> decodedList = jsonDecode(paymentsJson);
        final payments = decodedList.map((json) => PaymentModel.fromJson(json)).toList();
        debugPrint('Ödemeler yerel depolamadan yüklendi: ${payments.length} adet');
        return payments;
      }
    } catch (e) {
      debugPrint('Ödemeler yerel depolamadan yüklenirken hata: $e');
    }
    
    return [];
  }

  Future<PaymentModel?> getPaymentById(String id) async {
    try {
      // Önce yerel listede ara
      final localPayment = _payments.firstWhere(
        (payment) => payment.id == id,
        orElse: () => PaymentModel(
          id: '',
          title: '',
          description: '',
          amount: 0,
          userId: '',
          dueDate: '',
          createdAt: '',
          updatedAt: '',
        ),
      );
      
      if (localPayment.id.isNotEmpty) {
        return localPayment;
      }
      
      _isLoading = true;
      _error = null;
      notifyListeners();

      // API'den ödeme detayını al
      final response = await _apiService.get('/api/payments/$id');
      
      if (response['success']) {
        final payment = PaymentModel.fromJson(response['data']);
        _isLoading = false;
        notifyListeners();
        return payment;
      } else {
        _error = response['message'] ?? 'Ödeme detayı alınamadı';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> makePayment(String paymentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (isTestMode) {
        // Test modunda ödeme simülasyonu
        await Future.delayed(const Duration(seconds: 2));
        
        // Ödemeyi bul ve durumunu güncelle
        final index = _payments.indexWhere((payment) => payment.id == paymentId);
        if (index != -1) {
          _payments[index] = _payments[index].copyWith(
            paidAt: DateTime.now().toIso8601String(),
          );
          
          // Ödeme başarılı mesajı
          debugPrint('Test modunda ödeme başarıyla tamamlandı: $paymentId');
          
          // Yerel depolamaya kaydet
          await _savePaymentsToLocal(_payments);
          
          _isLoading = false;
          notifyListeners();
          return true;
        }
        
        _error = 'Ödeme bulunamadı';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Normal API çağrısı
      // Ödeme bilgisini kontrol et
      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index == -1) {
        _error = 'Ödeme bulunamadı';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // API'ye ödeme isteği gönder
      final response = await _apiService.post('/api/payments/$paymentId/pay', {});
      
      if (response['success']) {
        // Ödeme başarılıysa, ödemeleri yeniden yükle
        await fetchPayments();
        return true;
      } else {
        _error = response['message'] ?? 'Ödeme işlemi başarısız';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Ödeme işlemi hatası: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Ödeme oluştur
  Future<bool> createPayment({
    required String title,
    required String description,
    required double amount,
    required String userId,
    required String dueDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // API'ye gönderilecek veriyi hazırla
      final data = {
        'title': title,
        'description': description,
        'amount': amount,
        'userId': userId,
        'dueDate': dueDate,
      };
      
      debugPrint('Ödeme oluşturma isteği gönderiliyor: $data');
      
      if (isTestMode) {
        // Test modunda ise, yeni bir ödeme oluştur ve yerel listeye ekle
        debugPrint('Test modunda ödeme oluşturuluyor...');
        await Future.delayed(const Duration(seconds: 1)); // Simüle edilmiş gecikme
        
        final newPayment = PaymentModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          description: description,
          amount: amount,
          userId: userId,
          dueDate: dueDate,
          paidAt: null,
          status: 'Ödenmedi',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        
        _payments.add(newPayment);
        await _savePaymentsToLocal(_payments);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      // Normal API çağrısı
      try {
        final response = await _apiService.post('/api/payments', data);
        
        debugPrint('Ödeme oluşturma yanıtı: $response');
        
        if (response != null && response['success'] == true) {
          // Ödeme başarılıysa, ödemeleri yeniden yükle
          await fetchPayments();
          return true;
        } else {
          _error = response != null && response['message'] != null 
              ? response['message'] 
              : 'Ödeme oluşturma işlemi başarısız';
          debugPrint('Ödeme oluşturma hatası: $_error');
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } catch (apiError) {
        debugPrint('API isteği hatası: $apiError');
        _error = 'API isteği hatası: $apiError';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Ödeme oluşturma hatası: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Ödeme güncelle (admin)
  Future<bool> updatePaymentWithData(String id, Map<String, dynamic> paymentData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      if (isTestMode) {
        // Test modunda ödeme güncelle
        debugPrint('Test modunda ödeme güncelleniyor: $id, $paymentData');
        await Future.delayed(const Duration(seconds: 1));
        
        // Ödemeyi bul
        final index = _payments.indexWhere((payment) => payment.id == id);
        if (index != -1) {
          // Mevcut ödeme verilerini al
          final existingPayment = _payments[index];
          
          // Güncellenmiş ödeme oluştur
          final updatedPayment = PaymentModel(
            id: existingPayment.id,
            title: paymentData['title'] ?? existingPayment.title,
            description: paymentData['description'] ?? existingPayment.description,
            amount: paymentData['amount'] is double ? paymentData['amount'] : 
                  double.tryParse(paymentData['amount'].toString()) ?? existingPayment.amount,
            dueDate: paymentData['dueDate'] ?? existingPayment.dueDate,
            status: paymentData['status'] ?? existingPayment.status,
            paymentDate: existingPayment.paymentDate,
            category: paymentData['category'] ?? existingPayment.category,
            userId: existingPayment.userId,
            createdAt: existingPayment.createdAt,
            updatedAt: DateTime.now().toIso8601String(),
          );
          
          // Ödemeyi güncelle
          _payments[index] = updatedPayment;
          
          // Yerel depolamayı güncelle
          await _savePaymentsToLocal(_payments);
          
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = 'Güncellenecek ödeme bulunamadı';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
      
      // Normal API çağrısı
      final response = await _apiService.put('/api/payments/$id', paymentData);
      
      if (response['success']) {
        // Güncelleme başarılıysa, ödemeleri yeniden yükle
        await fetchPayments();
        return true;
      } else {
        _error = response['message'] ?? 'Ödeme güncellenemedi';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Ödeme güncelleme hatası: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Ödeme sil
  Future<bool> deletePayment(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      if (isTestMode) {
        // Test modunda, ödemeyi yerel listede sil
        debugPrint('Test modunda ödeme siliniyor: $id');
        await Future.delayed(const Duration(seconds: 1));
        
        // Ödemeyi listeden filtrele
        final index = _payments.indexWhere((payment) => payment.id == id);
        if (index != -1) {
          _payments.removeAt(index);
          
          // Yerel depolamayı güncelle
          await _savePaymentsToLocal(_payments);
          
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = 'Silinecek ödeme bulunamadı';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
      
      // Normal API çağrısı
      final response = await _apiService.delete('/api/payments/$id');
      
      if (response['success']) {
        // Silme başarılıysa, ödemeleri yeniden yükle
        // NOT: Burada doğrudan liste güncellemesi yaparak ekstra API çağrısını önleyebiliriz
        final index = _payments.indexWhere((payment) => payment.id == id);
        if (index != -1) {
          _payments.removeAt(index);
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Ödeme silme işlemi başarısız';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Ödeme silme hatası: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Toplam ödemeleri getir (sadece admin)
  Future<void> fetchTotalPayments() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // API'den toplam ödemeleri al
      final response = await _apiService.get('/api/payments/total');
      
      if (response['success']) {
        _totalPayments = response['data'];
      } else {
        _error = response['message'] ?? 'Toplam ödemeler alınamadı';
        _totalPayments = null;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _totalPayments = null;
      notifyListeners();
    }
  }

  // Test için örnek ödeme verileri
  List<PaymentModel> _getTestPayments() {
    return [
      PaymentModel(
        id: '1',
        title: 'Ocak 2025 Aidat',
        amount: 500.0,
        userId: 'user1',
        dueDate: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        status: 'Ödenmedi',
        description: 'Ocak ayı site aidat ödemesi',
        category: 'Aidat',
        createdAt: DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
      ),
      PaymentModel(
        id: '2',
        title: 'Şubat 2025 Aidat',
        amount: 500.0,
        userId: 'user1',
        dueDate: DateTime.now().add(const Duration(days: 15)).toIso8601String(),
        status: 'Ödenmedi',
        description: 'Şubat ayı site aidat ödemesi',
        category: 'Aidat',
        createdAt: DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      ),
      PaymentModel(
        id: '3',
        title: 'Havuz Bakım Ücreti',
        amount: 200.0,
        userId: 'user1',
        dueDate: DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        status: 'Ödenmedi',
        description: 'Yıllık havuz bakım ücreti',
        category: 'Bakım',
        createdAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      ),
      PaymentModel(
        id: '4',
        title: 'Aralık 2024 Aidat',
        amount: 500.0,
        userId: 'user1',
        dueDate: DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        status: 'Ödendi',
        paymentDate: DateTime.now().subtract(const Duration(days: 55)).toIso8601String(),
        description: 'Aralık ayı site aidat ödemesi',
        category: 'Aidat',
        createdAt: DateTime.now().subtract(const Duration(days: 75)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 55)).toIso8601String(),
      ),
    ];
  }

  // Yeni ödeme ekle (admin)
  Future<bool> addPayment(Map<String, dynamic> paymentData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      if (isTestMode) {
        // Test modunda yeni ödeme oluştur
        debugPrint('Test modunda ödeme oluşturuluyor: $paymentData');
        await Future.delayed(const Duration(seconds: 1));
        
        // Tarih alanlarını kontrol et ve düzelt
        String currentDate = DateTime.now().toIso8601String();
        
        final newPayment = PaymentModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: paymentData['title'] ?? '',
          description: paymentData['description'] ?? '',
          amount: paymentData['amount'] is double ? paymentData['amount'] : double.tryParse(paymentData['amount'].toString()) ?? 0.0,
          dueDate: paymentData['dueDate'] ?? currentDate,
          status: 'Ödenmedi',
          category: paymentData['category'] ?? 'Diğer',
          userId: paymentData['userId'] ?? 'all',
          createdAt: currentDate,
          updatedAt: currentDate,
        );
        
        // Ödemeyi listeye ekle
        _payments.insert(0, newPayment);
        
        // Yerel depolamayı güncelle
        await _savePaymentsToLocal(_payments);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      // Normal API çağrısı
      final response = await _apiService.post('/api/payments', paymentData);
      
      if (response['success']) {
        // Ödeme başarıyla oluşturulmuşsa, ödemeleri yeniden yükle
        await fetchPayments();
        return true;
      } else {
        _error = response['message'] ?? 'Ödeme oluşturulamadı';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Ödeme oluşturma hatası: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}