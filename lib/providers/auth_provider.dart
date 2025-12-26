import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  static const String userBoxName = 'users';
  static const String sessionKey = 'current_username';
  
  Box<UserModel>? _userBox;
  Box? _settingsBox;
  
  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _userBox = await Hive.openBox<UserModel>(userBoxName);
    _settingsBox = await Hive.openBox('settings');
    
    await _checkLoginStatus();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _checkLoginStatus() async {
    final username = _settingsBox?.get(sessionKey);
    if (username != null) {
      try {
        // Tìm user trong box
        final user = _userBox?.values.firstWhere(
          (u) => u.username == username,
        );
        _currentUser = user;
      } catch (e) {
        // User không tồn tại hoặc lỗi
        await logout();
      }
    }
  }

  Future<bool> login(String username, String password) async {
    if (_userBox == null) return false;

    try {
      final user = _userBox!.values.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      
      _currentUser = user;
      await _settingsBox?.put(sessionKey, username);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String fullName, String username, String password) async {
    if (_userBox == null) return false;

    // Kiểm tra username đã tồn tại chưa
    final exists = _userBox!.values.any((u) => u.username == username);
    if (exists) return false;

    final newUser = UserModel(
      fullName: fullName,
      username: username,
      password: password,
    );

    await _userBox!.add(newUser);
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _settingsBox?.delete(sessionKey);
    notifyListeners();
  }
}
