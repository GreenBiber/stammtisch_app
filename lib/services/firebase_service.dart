import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as app;
import '../models/group.dart';
import '../models/event.dart';
import '../models/points.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool get isInitialized => _auth.currentUser != null;

  // Collections
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get groupsCollection => _firestore.collection('groups');
  CollectionReference get eventsCollection => _firestore.collection('events');
  CollectionReference get pointsCollection => _firestore.collection('points');

  // User Authentication
  Future<app.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        return await _getUserById(credential.user!.uid);
      }
    } catch (e) {
      print('❌ Firebase Auth Error: $e');
      rethrow;
    }
    return null;
  }

  Future<app.User?> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String displayName
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        final user = app.User(
          id: credential.user!.uid,
          email: email,
          displayName: displayName,
          avatarUrl: null,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        await _saveUser(user);
        return user;
      }
    } catch (e) {
      print('❌ Firebase Registration Error: $e');
      rethrow;
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // User Data Management
  Future<void> _saveUser(app.User user) async {
    await usersCollection.doc(user.id).set({
      'email': user.email,
      'displayName': user.displayName,
      'avatarUrl': user.avatarUrl,
      'createdAt': user.createdAt.toIso8601String(),
      'lastLoginAt': user.lastLoginAt.toIso8601String(),
    });
  }

  Future<app.User?> _getUserById(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return app.User(
          id: doc.id,
          email: data['email'],
          displayName: data['displayName'],
          avatarUrl: data['avatarUrl'],
          createdAt: DateTime.parse(data['createdAt']),
          lastLoginAt: DateTime.parse(data['lastLoginAt']),
        );
      }
    } catch (e) {
      print('❌ Firebase Get User Error: $e');
    }
    return null;
  }

  // Group Management
  Future<String> createGroup(Group group) async {
    try {
      final docRef = await groupsCollection.add({
        'name': group.name,
        'avatarUrl': group.avatarUrl,
        'members': group.members,
        'admins': group.admins,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return docRef.id;
    } catch (e) {
      print('❌ Firebase Create Group Error: $e');
      rethrow;
    }
  }

  Future<List<Group>> getUserGroups(String userId) async {
    try {
      final querySnapshot = await groupsCollection
          .where('members', arrayContains: userId)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Group(
          id: doc.id,
          name: data['name'],
          avatarUrl: data['avatarUrl'],
          members: List<String>.from(data['members'] ?? []),
          admins: List<String>.from(data['admins'] ?? []),
        );
      }).toList();
    } catch (e) {
      print('❌ Firebase Get User Groups Error: $e');
      return [];
    }
  }

  Future<void> updateGroup(Group group) async {
    try {
      await groupsCollection.doc(group.id).update({
        'name': group.name,
        'avatarUrl': group.avatarUrl,
        'members': group.members,
        'admins': group.admins,
      });
    } catch (e) {
      print('❌ Firebase Update Group Error: $e');
      rethrow;
    }
  }

  // Event Management
  Future<void> saveEvent(Event event) async {
    try {
      await eventsCollection.doc('${event.groupId}_${event.date.toIso8601String().substring(0, 10)}').set({
        'groupId': event.groupId,
        'date': event.date.toIso8601String(),
        'participants': event.participants,
      });
    } catch (e) {
      print('❌ Firebase Save Event Error: $e');
      rethrow;
    }
  }

  Future<List<Event>> getGroupEvents(String groupId) async {
    try {
      final querySnapshot = await eventsCollection
          .where('groupId', isEqualTo: groupId)
          .orderBy('date')
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Event(
          groupId: data['groupId'],
          date: DateTime.parse(data['date']),
          participants: Map<String, String>.from(data['participants'] ?? {}),
        );
      }).toList();
    } catch (e) {
      print('❌ Firebase Get Group Events Error: $e');
      return [];
    }
  }

  // Points Management
  Future<void> saveUserPoints(String userId, String groupId, UserPoints points) async {
    try {
      await pointsCollection.doc('${userId}_$groupId').set({
        'userId': userId,
        'groupId': groupId,
        'totalXP': points.totalXP,
        'level': points.level,
        'currentStreak': points.currentStreak,
        'longestStreak': points.longestStreak,
        'achievements': points.achievements.map((a) => a.name).toList(),
        'lastActivity': points.lastActivity?.toIso8601String(),
        'monthlyStats': points.monthlyStats,
      });
    } catch (e) {
      print('❌ Firebase Save Points Error: $e');
      rethrow;
    }
  }

  Future<UserPoints?> getUserPoints(String userId, String groupId) async {
    try {
      final doc = await pointsCollection.doc('${userId}_$groupId').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserPoints(
          userId: data['userId'],
          groupId: data['groupId'],
          totalXP: data['totalXP'],
          level: data['level'],
          currentStreak: data['currentStreak'],
          longestStreak: data['longestStreak'],
          achievements: (data['achievements'] as List)
              .map((name) => Achievement.values.firstWhere((a) => a.name == name))
              .toSet(),
          lastActivity: data['lastActivity'] != null 
              ? DateTime.parse(data['lastActivity']) 
              : null,
          monthlyStats: Map<String, int>.from(data['monthlyStats'] ?? {}),
        );
      }
    } catch (e) {
      print('❌ Firebase Get Points Error: $e');
    }
    return null;
  }

  // Sync Methods (for migration from local storage)
  Future<void> syncLocalDataToFirebase({
    required List<app.User> users,
    required List<Group> groups,
    required List<Event> events,
    required Map<String, UserPoints> pointsData,
  }) async {
    print('🔄 Starting Firebase sync...');
    
    try {
      // Sync Users
      for (final user in users) {
        await _saveUser(user);
      }
      
      // Sync Groups
      for (final group in groups) {
        if (group.id.isNotEmpty) {
          await groupsCollection.doc(group.id).set({
            'name': group.name,
            'avatarUrl': group.avatarUrl,
            'members': group.members,
            'admins': group.admins,
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
      }
      
      // Sync Events
      for (final event in events) {
        await saveEvent(event);
      }
      
      // Sync Points
      for (final entry in pointsData.entries) {
        final parts = entry.key.split('_');
        if (parts.length == 2) {
          await saveUserPoints(parts[0], parts[1], entry.value);
        }
      }
      
      print('✅ Firebase sync completed');
    } catch (e) {
      print('❌ Firebase sync error: $e');
      rethrow;
    }
  }
}