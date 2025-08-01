import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final Uuid _uuid = const Uuid();

  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _currentUser != null;
  String get currentUserId => _currentUser?.id ?? 'anonymous';

  /// Initialisierung - prüfe ob User bereits eingeloggt
  Future<void> initialize() async {
    _setStatus(AuthStatus.loading);
    try {
      await _loadStoredUser();
      if (_currentUser != null) {
        _setStatus(AuthStatus.authenticated);
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _setError('Fehler beim Laden der Benutzerdaten: $e');
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  /// Benutzer registrieren
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setStatus(AuthStatus.loading);
    _clearError();

    try {
      // Validierung
      if (!_isValidEmail(email)) {
        _setError('Ungültige E-Mail-Adresse');
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }

      if (password.length < 6) {
        _setError('Passwort muss mindestens 6 Zeichen lang sein');
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }

      if (displayName.trim().isEmpty) {
        _setError('Anzeigename darf nicht leer sein');
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }

      // Prüfe ob E-Mail bereits existiert
      if (await _emailExists(email)) {
        _setError('E-Mail-Adresse bereits registriert');
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }

      // Erstelle neuen User
      final user = User(
        id: _uuid.v4(),
        email: email.trim().toLowerCase(),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Speichere User und Passwort
      await _saveUser(user, password);
      _currentUser = user;
      _setStatus(AuthStatus.authenticated);

      return true;
    } catch (e) {
      _setError('Registrierung fehlgeschlagen: $e');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  /// Benutzer anmelden
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setStatus(AuthStatus.loading);
    _clearError();

    try {
      // Validierung
      if (!_isValidEmail(email)) {
        _setError('Ungültige E-Mail-Adresse');
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }

      // Lade gespeicherte Credentials
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '{}';
      final users = Map<String, dynamic>.from(json.decode(usersJson));
      final normalizedEmail = email.trim().toLowerCase();

      if (!users.containsKey(normalizedEmail)) {
        _setError('E-Mail-Adresse nicht gefunden');
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }

      final userData = users[normalizedEmail];
      final storedPassword = userData['password'];

      // Einfache Passwort-Prüfung (in Production: gehashed!)
      if (storedPassword != password) {
        _setError('Falsches Passwort');
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }

      // Erstelle User-Objekt und aktualisiere Login-Zeit
      final user = User.fromJson(userData['user']).copyWith(
        lastLoginAt: DateTime.now(),
      );

      // Speichere aktualisierte Login-Zeit
      userData['user'] = user.toJson();
      users[normalizedEmail] = userData;
      await prefs.setString('users', json.encode(users));
      await prefs.setString('currentUser', json.encode(user.toJson()));

      _currentUser = user;
      _setStatus(AuthStatus.authenticated);

      return true;
    } catch (e) {
      _setError('Anmeldung fehlgeschlagen: $e');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  /// Benutzer abmelden
  Future<void> logout() async {
    _setStatus(AuthStatus.loading);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUser');
      _currentUser = null;
      _clearError();
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      _setError('Fehler beim Abmelden: $e');
    }
  }

  /// Profil aktualisieren
  Future<bool> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return false;

    try {
      final updatedUser = _currentUser!.copyWith(
        displayName: displayName ?? _currentUser!.displayName,
        avatarUrl: avatarUrl,
      );

      // Speichere in users-Map
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '{}';
      final users = Map<String, dynamic>.from(json.decode(usersJson));

      if (users.containsKey(_currentUser!.email)) {
        users[_currentUser!.email]['user'] = updatedUser.toJson();
        await prefs.setString('users', json.encode(users));
      }

      // Speichere als aktueller User
      await prefs.setString('currentUser', json.encode(updatedUser.toJson()));

      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Profil-Update fehlgeschlagen: $e');
      return false;
    }
  }

  // Private Helper-Methoden
  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<bool> _emailExists(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '{}';
      final users = Map<String, dynamic>.from(json.decode(usersJson));
      return users.containsKey(email.trim().toLowerCase());
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveUser(User user, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Lade existierende Users
    final usersJson = prefs.getString('users') ?? '{}';
    final users = Map<String, dynamic>.from(json.decode(usersJson));

    // Füge neuen User hinzu
    users[user.email] = {
      'user': user.toJson(),
      'password': password, // In Production: gehashed!
    };

    // Speichere Users-Map und aktuellen User
    await prefs.setString('users', json.encode(users));
    await prefs.setString('currentUser', json.encode(user.toJson()));
  }

  Future<void> _loadStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');

    if (userJson != null) {
      _currentUser = User.fromJson(json.decode(userJson));
    }
  }
}
