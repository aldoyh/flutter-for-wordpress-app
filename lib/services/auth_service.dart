import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:flutter_wordpress_app/models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(Constants.tokenKey);
    if (_token != null) {
      await _validateToken();
    }
  }

  Future<bool> _validateToken() async {
    try {
      final response = await http.post(
        Uri.parse(Constants.validateTokenEndpoint),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        await _loadUserData();
        return true;
      } else {
        await _clearAuth();
        return false;
      }
    } catch (e) {
      await _clearAuth();
      return false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiEndpoint}/users/me'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _currentUser = User.fromJson({
          ...userData,
          'token': _token,
        });
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> login(String username, String password) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(Constants.loginEndpoint),
        body: {
          'username': username,
          'password': password,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        _token = data['token'];
        
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenKey, _token!);

        // Load user data
        await _loadUserData();
      } else {
        throw data['message'] ?? Constants.invalidCredentials;
      }
    } catch (e) {
      throw e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(Constants.registerEndpoint),
        body: {
          'username': username,
          'email': email,
          'password': password,
          if (displayName != null) 'name': displayName,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        // After successful registration, login the user
        await login(username, password);
      } else {
        final error = data['message'] ?? Constants.registrationError;
        if (error.contains('username')) {
          throw Constants.usernameTaken;
        } else if (error.contains('email')) {
          throw Constants.emailTaken;
        } else if (error.contains('password')) {
          throw Constants.weakPassword;
        } else {
          throw error;
        }
      }
    } catch (e) {
      throw e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _clearAuth();
    notifyListeners();
  }

  Future<void> _clearAuth() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Helper method to get auth headers
  Map<String, String> get authHeaders {
    return {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };
  }
}