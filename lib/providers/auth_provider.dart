import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/sync_service.dart';
import '../services/firebase_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final Uuid _uuid = const Uuid();
  final Map<String, int> _failedLoginAttempts = {};
  final Map<String, DateTime> _lockoutUntil = {};
  final SyncService _syncService = SyncService();
  final FirebaseService _firebaseService = FirebaseService();

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
      // Initialize SyncService first
      await _syncService.initialize();
      
      // Check for Firebase user first (priority)
      if (_firebaseService.currentFirebaseUser != null) {
        final firebaseUser = await _syncService.getUser(_firebaseService.currentUserId!);
        if (firebaseUser != null) {
          _currentUser = firebaseUser;
          _setStatus(AuthStatus.authenticated);
          return;
        }
      }
      
      // Fallback to local stored user
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

      if (!_isStrongPassword(password)) {
        _setError(
            'Passwort muss mindestens 8 Zeichen haben und Buchstaben, Zahlen und Sonderzeichen enthalten');
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }

      if (displayName.trim().isEmpty) {
        _setError('Anzeigename darf nicht leer sein');
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }

      // Try Firebase registration first if available
      if (_syncService.status == SyncStatus.online) {
        try {
          final firebaseUser = await _firebaseService.createUserWithEmailAndPassword(
            email.trim().toLowerCase(),
            password,
            displayName.trim(),
          );
          if (firebaseUser != null) {
            _currentUser = firebaseUser;
            await _saveUserLocally(_currentUser!, password); // Cache locally
            _setStatus(AuthStatus.authenticated);
            return true;
          }
        } catch (e) {
          print('Firebase registration failed, falling back to local: $e');
        }
      }

      // Fallback to local registration
      // Prüfe ob E-Mail bereits existiert (lokal)
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

      // Speichere User hybrid (lokal + queue für Cloud)
      await _syncService.saveUser(user);
      await _saveUserLocally(user, password);
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
      // Validierung und Ratenbegrenzung
      if (!_isValidEmail(email)) {
        _setError('Ungültige E-Mail-Adresse');
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }

      final normalizedEmail = email.trim().toLowerCase();
      if (_isLockedOut(normalizedEmail)) {
        _setError(
            'Zu viele fehlgeschlagene Anmeldeversuche. Bitte warten Sie.');
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }

      // Try Firebase login first if available
      if (_syncService.status == SyncStatus.online) {
        try {
          final firebaseUser = await _firebaseService.signInWithEmailAndPassword(
            normalizedEmail,
            password,
          );
          if (firebaseUser != null) {
            _currentUser = firebaseUser.copyWith(lastLoginAt: DateTime.now());
            await _syncService.saveUser(_currentUser!); // Update last login
            await _saveCurrentUserLocally(); // Cache locally
            _clearFailedLogins(normalizedEmail);
            _setStatus(AuthStatus.authenticated);
            return true;
          }
        } catch (e) {
          print('Firebase login failed, trying local: $e');
        }
      }

      // Fallback to local login
      // Lade gespeicherte Credentials
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '{}';
      final users = Map<String, dynamic>.from(json.decode(usersJson));

      if (!users.containsKey(normalizedEmail)) {
        _recordFailedLogin(normalizedEmail);
        _setError('E-Mail-Adresse nicht gefunden');
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }

      final userData = users[normalizedEmail];
      final storedPasswordHash = userData['passwordHash'];
      final salt = userData['salt'];

      // Sicherer Passwort-Vergleich mit Hash
      if (!_verifyPassword(password, storedPasswordHash, salt)) {
        _recordFailedLogin(normalizedEmail);
        _setError('Falsches Passwort');
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }

      // Reset failed attempts on successful login
      _clearFailedLogins(normalizedEmail);

      // Erstelle User-Objekt und aktualisiere Login-Zeit
      final user = User.fromJson(userData['user']).copyWith(
        lastLoginAt: DateTime.now(),
      );

      // Speichere aktualisierte Login-Zeit hybrid
      await _syncService.saveUser(user);
      await _saveUserLocally(user, password);
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
      // Sign out from Firebase if available
      if (_syncService.status == SyncStatus.online) {
        try {
          await _firebaseService.signOut();
        } catch (e) {
          print('Firebase signout failed: $e');
        }
      }
      
      // Clear local session
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

  // Hybrid Storage Helper Methods
  Future<void> _saveUserLocally(User user, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = _generateSalt();
    final passwordHash = _hashPassword(password, salt);

    final usersJson = prefs.getString('users') ?? '{}';
    final users = Map<String, dynamic>.from(json.decode(usersJson));

    users[user.email] = {
      'user': user.toJson(),
      'passwordHash': passwordHash,
      'salt': salt,
    };

    await prefs.setString('users', json.encode(users));
  }

  Future<void> _saveCurrentUserLocally() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
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

  bool _isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Za-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?\":{}|<>]'))) return false;
    return true;
  }

  String _generateSalt() {
    final bytes = List<int>.generate(
        32, (i) => DateTime.now().millisecondsSinceEpoch.hashCode + i);
    return base64.encode(bytes);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool _verifyPassword(String password, String hash, String salt) {
    return _hashPassword(password, salt) == hash;
  }

  bool _isLockedOut(String email) {
    if (!_lockoutUntil.containsKey(email)) return false;
    return DateTime.now().isBefore(_lockoutUntil[email]!);
  }

  void _recordFailedLogin(String email) {
    _failedLoginAttempts[email] = (_failedLoginAttempts[email] ?? 0) + 1;
    if (_failedLoginAttempts[email]! >= 5) {
      _lockoutUntil[email] = DateTime.now().add(const Duration(minutes: 15));
    }
  }

  void _clearFailedLogins(String email) {
    _failedLoginAttempts.remove(email);
    _lockoutUntil.remove(email);
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

    // Generiere Salt und Hash für sicheres Passwort
    final salt = _generateSalt();
    final passwordHash = _hashPassword(password, salt);

    // Füge neuen User hinzu
    users[user.email] = {
      'user': user.toJson(),
      'passwordHash': passwordHash,
      'salt': salt,
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
