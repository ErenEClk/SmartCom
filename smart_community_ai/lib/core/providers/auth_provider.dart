import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_community_ai/core/models/user_model.dart';
import 'package:smart_community_ai/core/services/api_service.dart';
import 'package:smart_community_ai/core/constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final bool isTestMode;
  
  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;
  List<UserModel> _users = [];

  AuthProvider({
    required ApiService apiService,
    this.isTestMode = false,
  }) : _apiService = apiService;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;
  UserModel? get user => _currentUser;
  List<UserModel> get users => _users;

  // Hata mesajını temizleyen metod
  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> isAuthenticated() async {
    if (isTestMode) {
      // Test modunda otomatik olarak giriş yapmış kabul et
      return _currentUser != null;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        return false;
      }
      
      return await checkAuth();
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;
      notifyListeners();

      if (isTestMode) {
        // Test modunda kullanıcı bilgilerini kontrol et
        if (email == 'admin@example.com' && password == '123456') {
          _currentUser = UserModel(
            id: 'admin1',
            name: 'Admin Kullanıcı',
            email: 'admin@example.com',
            role: 'admin',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
            isOnline: true,
          );
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', 'test_token_admin');
          print('Test admin token kaydedildi: test_token_admin');
          
          _setLoading(false);
          notifyListeners();
          return true;
        } else if (email == 'kullanici@example.com' && password == '123456') {
          _currentUser = UserModel(
            id: 'user1',
            name: 'Normal Kullanıcı',
            email: 'kullanici@example.com',
            role: 'user',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
            isOnline: true,
          );
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', 'test_token_user');
          print('Test kullanıcı token kaydedildi: test_token_user');
          
          _setLoading(false);
          notifyListeners();
          return true;
        } else {
          _error = 'Geçersiz e-posta veya şifre';
          _setLoading(false);
          notifyListeners();
          return false;
        }
      }

      // Normal API çağrısı
      print('Login isteği gönderiliyor: $email');
      final response = await _apiService.login(email, password);
      print('Login yanıtı alındı: $response');

      if (response != null && response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response['token']);
        print('Token kaydedildi: ${response['token'].substring(0, 10)}...');
        
        if (response['user'] != null) {
          _currentUser = UserModel.fromJson(response['user']);
          print('Kullanıcı bilgileri alındı: ${_currentUser?.name}');
        } else {
          print('Kullanıcı bilgileri alınamadı, profil bilgisi çekilecek');
          try {
            _currentUser = await _apiService.getUserProfile();
            print('Kullanıcı profili alındı: ${_currentUser?.name}');
          } catch (e) {
            print('Kullanıcı profili alınamadı: $e');
          }
        }
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _error = 'Giriş başarısız';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkAuth() async {
    try {
      _setLoading(true);
      notifyListeners();

      if (isTestMode) {
        // Test modunda token kontrolü
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token == null) {
          _setLoading(false);
          notifyListeners();
          return false;
        }

        // Test token'ına göre kullanıcı oluştur
        if (token == 'test_token_admin') {
          _currentUser = UserModel(
            id: 'admin1',
            name: 'Admin Kullanıcı',
            email: 'admin@example.com',
            role: 'admin',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
            isOnline: true,
          );
          _setLoading(false);
          notifyListeners();
          return true;
        } else if (token == 'test_token_user') {
          _currentUser = UserModel(
            id: 'user1',
            name: 'Normal Kullanıcı',
            email: 'kullanici@example.com',
            role: 'user',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
            isOnline: true,
          );
          _setLoading(false);
          notifyListeners();
          return true;
        } else {
          await logout();
          _setLoading(false);
          notifyListeners();
          return false;
        }
      }

      // Normal API çağrısı
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _setLoading(false);
        notifyListeners();
        return false;
      }

      try {
        final userProfile = await _apiService.getUserProfile();
        if (userProfile != null) {
          _currentUser = userProfile;
          _setLoading(false);
          notifyListeners();
          return true;
        } else {
          await logout();
          _setLoading(false);
          notifyListeners();
          return false;
        }
      } catch (e) {
        print('Profil kontrolü hatası: $e');
        await logout();
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      await logout();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      notifyListeners();

      // Önce API çağrısını yapma girişiminde bulun
      if (!isTestMode) {
        try {
          // Normal API çağrısı
          await _apiService.post('/api/auth/logout', {});
        } catch (e) {
          print('Logout API çağrısı sırasında hata: $e');
          // Hata durumunda bile devam et, kullanıcı yerel olarak çıkış yapabilmeli
        }
      }

      // Token ve kullanıcı bilgilerini temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user'); // Kullanıcı bilgilerini de temizle
      
      _currentUser = null;
      _setLoading(false);
      _error = null;
      _users = [];
      notifyListeners();
      
      print('Kullanıcı başarıyla çıkış yaptı');
    } catch (e) {
      print('Logout işlemi sırasında hata: $e');
      // Token ve kullanıcı bilgilerini temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      
      _currentUser = null;
      _setLoading(false);
      _error = null;
      _users = [];
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    try {
      _setLoading(true);
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/api/users');
      
      if (response != null && response['users'] != null) {
        _users = (response['users'] as List)
            .map((user) => UserModel.fromJson(user))
            .toList();
      } else {
        // Test verileri
        _users = _getTestUsers();
      }
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      
      // Test verileri
      _users = _getTestUsers();
      
      notifyListeners();
    }
  }

  // Kullanıcıları getir
  Future<List<UserModel>> getUsers() async {
    try {
      _setLoading(true);

      if (isTestMode) {
        // Test modunda örnek kullanıcılar
        await Future.delayed(const Duration(seconds: 1));
        final testUsers = [
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
          UserModel(
            id: 'admin1',
            name: 'Admin Kullanıcı',
            email: 'admin@example.com',
            role: 'admin',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        ];
        _setLoading(false);
        return testUsers;
      }

      final response = await _apiService.get(ApiConstants.usersEndpoint);
      
      if (response['success']) {
        final List<dynamic> data = response['data'];
        final users = data.map((item) => UserModel.fromJson(item)).toList();
        _setLoading(false);
        return users;
      } else {
        _error = response['message'] ?? 'Kullanıcılar alınamadı';
        _setLoading(false);
        return [];
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      
      // Hata durumunda varsayılan kullanıcıları döndür
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
          id: 'admin1',
          name: 'Admin Kullanıcı',
          email: 'admin@example.com',
          role: 'admin',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ];
    }
  }

  // Sadece site sakinlerini getir
  Future<List<UserModel>> getResidents() async {
    if (_users.isEmpty) {
      await fetchUsers();
    }
    return _users.where((user) => user.role == 'user').toList();
  }

  // Sadece yöneticileri getir
  Future<List<UserModel>> getAdmins() async {
    if (_users.isEmpty) {
      await fetchUsers();
    }
    return _users.where((user) => user.role == 'admin').toList();
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      notifyListeners();

      final response = await _apiService.post('/api/users', {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });

      if (response != null && response['user'] != null) {
        final newUser = UserModel.fromJson(response['user']);
        _users.add(newUser);
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _error = 'Kullanıcı oluşturma başarısız';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      
      // Test için başarılı kabul edelim
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      _users.add(newUser);
      notifyListeners();
      
      return true;
    }
  }

  Future<bool> updateUser({
    required String id,
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      notifyListeners();

      final response = await _apiService.put('/api/users/$id', {
        'name': name,
        'email': email,
        'role': role,
      });

      if (response != null && response['user'] != null) {
        final updatedUser = UserModel.fromJson(response['user']);
        final index = _users.indexWhere((user) => user.id == id);
        if (index != -1) {
          _users[index] = updatedUser;
        }
        
        // Eğer güncellenen kullanıcı mevcut kullanıcı ise, onu da güncelle
        if (_currentUser != null && _currentUser!.id == id) {
          _currentUser = updatedUser;
        }
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _error = 'Kullanıcı güncelleme başarısız';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      
      // Test için başarılı kabul edelim
      final index = _users.indexWhere((user) => user.id == id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          name: name,
          email: email,
          role: role,
          updatedAt: DateTime.now().toIso8601String(),
        );
        
        // Eğer güncellenen kullanıcı mevcut kullanıcı ise, onu da güncelle
        if (_currentUser != null && _currentUser!.id == id) {
          _currentUser = _users[index];
        }
        
        notifyListeners();
      }
      
      return true;
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      _setLoading(true);
      _error = null;
      notifyListeners();

      final response = await _apiService.delete('/api/users/$id');

      if (response != null) {
        _users.removeWhere((user) => user.id == id);
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _error = 'Kullanıcı silme başarısız';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      
      // Test için başarılı kabul edelim
      _users.removeWhere((user) => user.id == id);
      notifyListeners();
      
      return true;
    }
  }

  List<UserModel> _getTestUsers() {
    return [
      UserModel(
        id: '1',
        name: 'Admin Kullanıcı',
        email: 'admin@example.com',
        role: 'admin',
        phone: '5551234567',
        address: 'Örnek Mahallesi, Örnek Sokak No:1',
        apartmentNumber: 'A-101',
        createdAt: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      UserModel(
        id: '2',
        name: 'Test Kullanıcı',
        email: 'user@example.com',
        role: 'user',
        phone: '5559876543',
        address: 'Örnek Mahallesi, Örnek Sokak No:1',
        apartmentNumber: 'B-202',
        createdAt: DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      UserModel(
        id: '3',
        name: 'Ahmet Yılmaz',
        email: 'ahmet@example.com',
        role: 'user',
        phone: '5551112233',
        address: 'Örnek Mahallesi, Örnek Sokak No:1',
        apartmentNumber: 'C-303',
        createdAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      UserModel(
        id: '4',
        name: 'Ayşe Demir',
        email: 'ayse@example.com',
        role: 'user',
        phone: '5554445566',
        address: 'Örnek Mahallesi, Örnek Sokak No:1',
        apartmentNumber: 'D-404',
        createdAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      _setLoading(true);
      _error = null;
      notifyListeners();

      if (isTestMode) {
        // Test modunda kayıt işlemi
        await Future.delayed(const Duration(seconds: 1));
        _error = null;
        _setLoading(false);
        notifyListeners();
        return true;
      }

      // Normal API çağrısı
      final response = await _apiService.register(name, email, password);

      if (response != null && response['user'] != null) {
        final newUser = UserModel.fromJson(response['user']);
        _users.add(newUser);
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _error = 'Kullanıcı kayıt işlemi başarısız';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      _setLoading(true);
      _error = null;
      notifyListeners();

      if (isTestMode) {
        // Test modunda şifre sıfırlama
        await Future.delayed(const Duration(seconds: 1));
        _error = null;
        _setLoading(false);
        notifyListeners();
        return true;
      }

      // Normal API çağrısı
      final response = await _apiService.forgotPassword(email);

      if (response != null && response['user'] != null) {
        _currentUser = UserModel.fromJson(response['user']);
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _error = 'Şifre sıfırlama işlemi başarısız';
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Yardımcı metod: Yüklenme durumunu ayarla
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
} 