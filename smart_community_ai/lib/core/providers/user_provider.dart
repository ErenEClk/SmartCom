import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_community_ai/core/constants/api_constants.dart';
import 'package:smart_community_ai/core/models/user_model.dart';
import 'package:smart_community_ai/core/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService;
  
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;
  bool _testMode = true; // Test modu

  UserProvider({
    required AuthService authService,
  }) : _authService = authService;

  // Getters
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Tüm kullanıcıları getir
  Future<List<UserModel>> getAllUsers() async {
    _setLoading(true);
    _error = null;

    try {
      if (_testMode) {
        // Test verileri
        await Future.delayed(const Duration(seconds: 1));
        _users = _getTestUsers();
        return _users;
      } else {
        final token = await _authService.getToken();
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/users'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body)['data'];
          _users = data
              .map((item) => UserModel.fromJson(item))
              .toList();
          return _users;
        } else {
          _handleError('Kullanıcılar yüklenirken hata oluştu: ${response.statusCode}');
          return [];
        }
      }
    } catch (e) {
      _handleError('Kullanıcılar yüklenirken hata oluştu: $e');
      return _getTestUsers(); // Hata durumunda test verilerini kullan
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı detaylarını getir
  Future<UserModel?> getUserById(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      if (_testMode) {
        // Test verileri
        await Future.delayed(const Duration(milliseconds: 500));
        final users = _getTestUsers();
        final user = users.firstWhere(
          (user) => user.id == userId,
          orElse: () => UserModel(
            id: userId,
            name: 'Test Kullanıcı',
            email: 'test@example.com',
            role: 'user',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );
        return user;
      } else {
        final token = await _authService.getToken();
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/users/$userId'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data'];
          return UserModel.fromJson(data);
        } else {
          _handleError('Kullanıcı bilgileri yüklenirken hata oluştu: ${response.statusCode}');
          return null;
        }
      }
    } catch (e) {
      _handleError('Kullanıcı bilgileri yüklenirken hata oluştu: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Yükleme durumunu güncelle
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Hata durumunu güncelle
  void _handleError(String errorMessage) {
    _error = errorMessage;
    debugPrint('UserProvider Error: $errorMessage');
    notifyListeners();
  }

  // Test kullanıcıları
  List<UserModel> _getTestUsers() {
    return [
      UserModel(
        id: 'user1',
        name: 'Ahmet Yılmaz',
        email: 'ahmet@example.com',
        role: 'user',
        createdAt: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      ),
      UserModel(
        id: 'user2',
        name: 'Ayşe Demir',
        email: 'ayse@example.com',
        role: 'user',
        createdAt: DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      ),
      UserModel(
        id: 'user3',
        name: 'Mehmet Kaya',
        email: 'mehmet@example.com',
        role: 'user',
        createdAt: DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      ),
      UserModel(
        id: 'admin1',
        name: 'Site Yönetimi',
        email: 'admin@example.com',
        role: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 100)).toIso8601String(),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      ),
    ];
  }
} 