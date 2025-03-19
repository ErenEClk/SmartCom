import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_community_ai/core/constants/api_constants.dart';
import 'package:smart_community_ai/core/models/user_model.dart';

class AuthService {
  final String _tokenKey = 'auth_token';
  final String _userKey = 'user_data';
  
  // Token alma
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Token kaydetme
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  // Token silme
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
  
  // Kullanıcı bilgilerini alma
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    
    if (userData != null) {
      return UserModel.fromJson(json.decode(userData));
    }
    
    return null;
  }
  
  // Kullanıcı bilgilerini kaydetme
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }
  
  // Kullanıcı bilgilerini silme
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
  
  // Giriş yapma
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        final token = data['token'];
        final user = UserModel.fromJson(data['user']);
        
        await saveToken(token);
        await saveUser(user);
        
        return {
          'success': true,
          'user': user,
          'token': token,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Giriş başarısız',
        };
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return {
        'success': false,
        'message': 'Bir hata oluştu: $e',
      };
    }
  }
  
  // Çıkış yapma
  Future<void> logout() async {
    try {
      // Tüm oturum bilgilerini temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      
      // Diğer olası oturum verileri
      await prefs.remove('token');
      await prefs.remove('user');
      
      debugPrint('AuthService: Kullanıcı çıkış yaptı, tüm oturum bilgileri temizlendi');
    } catch (e) {
      debugPrint('Logout error: $e');
      // Hata olsa bile devam etmeye çalış
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    }
  }
  
  // Token kontrolü
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
} 