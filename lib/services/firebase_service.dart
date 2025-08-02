import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart' as app;
import '../models/group.dart';
import '../models/event.dart';
import '../models/points.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Getter für aktuellen User
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  // Auth Stream
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // User Authentication
  Future<app.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        return await getUser(credential.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Login fehlgeschlagen: $e');
    }
  }

  Future<app.User?> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final userModel = app.User(
          id: credential.user!.uid,
          email: email,
          displayName: displayName,
          avatarUrl: null,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await saveUser(userModel);
        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Registrierung fehlgeschlagen: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // User Management
  Future<void> saveUser(app.User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Benutzer konnte nicht gespeichert werden: $e');
    }
  }

  Future<app.User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return app.User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Benutzer konnte nicht geladen werden: $e');
    }
  }

  // Group Management
  Future<void> saveGroup(Group group) async {
    try {
      await _firestore.collection('groups').doc(group.id).set(group.toJson());
    } catch (e) {
      throw Exception('Gruppe konnte nicht gespeichert werden: $e');
    }
  }

  Future<Group?> getGroup(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (doc.exists) {
        return Group.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Gruppe konnte nicht geladen werden: $e');
    }
  }

  Future<List<Group>> getUserGroups(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('groups')
          .where('memberIds', arrayContains: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => Group.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Gruppen konnten nicht geladen werden: $e');
    }
  }

  // Event Management
  Future<void> saveEvent(Event event, {String? eventId}) async {
    try {
      final docRef = eventId != null 
          ? _firestore.collection('events').doc(eventId)
          : _firestore.collection('events').doc();
      await docRef.set(event.toJson());
    } catch (e) {
      throw Exception('Event konnte nicht gespeichert werden: $e');
    }
  }

  Future<Event?> getEvent(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return Event.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Event konnte nicht geladen werden: $e');
    }
  }

  Future<List<Event>> getGroupEvents(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('events')
          .where('groupId', isEqualTo: groupId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Event.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Events konnten nicht geladen werden: $e');
    }
  }

  // Points Management
  Future<void> saveUserPoints(UserPoints userPoints) async {
    try {
      final docId = '${userPoints.userId}_${userPoints.groupId}';
      await _firestore.collection('points').doc(docId).set(userPoints.toJson());
    } catch (e) {
      throw Exception('Punkte konnten nicht gespeichert werden: $e');
    }
  }

  Future<UserPoints?> getUserPoints(String userId, String groupId) async {
    try {
      final docId = '${userId}_$groupId';
      final doc = await _firestore.collection('points').doc(docId).get();
      if (doc.exists) {
        return UserPoints.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Punkte konnten nicht geladen werden: $e');
    }
  }

  Future<List<UserPoints>> getGroupLeaderboard(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('points')
          .where('groupId', isEqualTo: groupId)
          .orderBy('totalXP', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserPoints.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Leaderboard konnte nicht geladen werden: $e');
    }
  }

  // Real-time Chat Messages
  Stream<QuerySnapshot> getChatMessages(String groupId) {
    return _firestore
        .collection('chats')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();
  }

  Future<void> sendChatMessage({
    required String groupId,
    required String message,
    required String senderId,
    required String senderName,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(groupId)
          .collection('messages')
          .add({
        'message': message,
        'senderId': senderId,
        'senderName': senderName,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
      });
    } catch (e) {
      throw Exception('Nachricht konnte nicht gesendet werden: $e');
    }
  }

  // Utility Methods
  Future<void> addUserToGroup(String userId, String groupId) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      throw Exception('Benutzer konnte nicht zur Gruppe hinzugefügt werden: $e');
    }
  }

  // Initialization
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;
      
      // Firebase wird bereits in main.dart initialisiert
      // Hier nur Firestore-spezifische Einstellungen
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      _isInitialized = true;
      print('🔥 Firebase Service successfully initialized');
    } catch (e) {
      print('❌ Firebase Service initialization failed: $e');
      throw Exception('Firebase konnte nicht initialisiert werden: $e');
    }
  }
}