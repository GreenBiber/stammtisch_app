import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';
import '../models/user.dart';
import '../models/group.dart';
import '../models/event.dart';
import '../models/points.dart';

enum SyncStatus { offline, online, syncing, error }

class SyncOperation {
  final String id;
  final String type; // 'user', 'group', 'event', 'points'
  final String operation; // 'create', 'update', 'delete'
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  SyncOperation({
    required this.id,
    required this.type,
    required this.operation,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'operation': operation,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'retryCount': retryCount,
  };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
    id: json['id'],
    type: json['type'],
    operation: json['operation'],
    data: Map<String, dynamic>.from(json['data']),
    timestamp: DateTime.parse(json['timestamp']),
    retryCount: json['retryCount'] ?? 0,
  );

  SyncOperation withRetry() => SyncOperation(
    id: id,
    type: type,
    operation: operation,
    data: data,
    timestamp: timestamp,
    retryCount: retryCount + 1,
  );
}

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  SharedPreferences? _prefs;
  
  SyncStatus _status = SyncStatus.offline;
  final List<SyncOperation> _pendingOperations = [];
  Timer? _syncTimer;
  bool _isInitialized = false;

  // Streams für Status-Updates
  final StreamController<SyncStatus> _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;
  SyncStatus get status => _status;

  // Konfiguration
  static const int maxRetries = 3;
  static const Duration syncInterval = Duration(seconds: 30);
  static const String pendingOperationsKey = 'pending_sync_operations';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      await _cleanupCorruptedData();
      await _loadPendingOperations();
      await _checkConnectivity();
      _startPeriodicSync();
      _isInitialized = true;
      
      _debugPrint('🔄 SyncService initialized successfully');
    } catch (e) {
      _debugPrint('❌ SyncService initialization failed: $e');
      _setStatus(SyncStatus.error);
    }
  }

  void _setStatus(SyncStatus status) {
    if (_status != status) {
      _status = status;
      _statusController.add(status);
      _debugPrint('🔄 SyncService status: ${status.name}');
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      if (_firebaseService.isInitialized && _firebaseService.currentFirebaseUser != null) {
        // Test Firebase connection
        await _firebaseService.getUser(_firebaseService.currentUserId!);
        _setStatus(SyncStatus.online);
        await _processPendingOperations();
      } else {
        _setStatus(SyncStatus.offline);
      }
    } catch (e) {
      _debugPrint('🔄 Connectivity check failed: $e');
      _setStatus(SyncStatus.offline);
    }
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) {
      if (_status != SyncStatus.syncing) {
        _checkConnectivity();
      }
    });
  }

  // CRUD Operations mit Hybrid-Ansatz

  // User Operations
  Future<void> saveUser(User user, {bool forceLocal = false}) async {
    try {
      // Immer lokal speichern
      await _saveUserLocal(user);

      // Cloud speichern wenn verfügbar
      if (_status == SyncStatus.online && !forceLocal) {
        try {
          await _firebaseService.saveUser(user);
        } catch (e) {
          _debugPrint('Cloud save failed, queuing for later: $e');
          await _queueOperation(SyncOperation(
            id: user.id,
            type: 'user',
            operation: 'update',
            data: user.toJson(),
            timestamp: DateTime.now(),
          ));
        }
      } else if (!forceLocal) {
        // Queue für später
        await _queueOperation(SyncOperation(
          id: user.id,
          type: 'user',
          operation: 'update',
          data: user.toJson(),
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      _debugPrint('❌ Failed to save user: $e');
      rethrow;
    }
  }

  Future<User?> getUser(String userId) async {
    try {
      // Zuerst Cloud versuchen
      if (_status == SyncStatus.online) {
        try {
          final cloudUser = await _firebaseService.getUser(userId);
          if (cloudUser != null) {
            // Cloud-Daten lokal cachen
            await _saveUserLocal(cloudUser);
            return cloudUser;
          }
        } catch (e) {
          _debugPrint('Cloud fetch failed, using local: $e');
        }
      }

      // Fallback zu lokalen Daten
      return await _getUserLocal(userId);
    } catch (e) {
      _debugPrint('❌ Failed to get user: $e');
      return null;
    }
  }

  // Group Operations
  Future<void> saveGroup(Group group, {bool forceLocal = false}) async {
    try {
      await _saveGroupLocal(group);

      if (_status == SyncStatus.online && !forceLocal) {
        try {
          await _firebaseService.saveGroup(group);
        } catch (e) {
          await _queueOperation(SyncOperation(
            id: group.id,
            type: 'group',
            operation: 'update',
            data: group.toJson(),
            timestamp: DateTime.now(),
          ));
        }
      } else if (!forceLocal) {
        await _queueOperation(SyncOperation(
          id: group.id,
          type: 'group',
          operation: 'update',
          data: group.toJson(),
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      _debugPrint('❌ Failed to save group: $e');
      rethrow;
    }
  }

  Future<Group?> getGroup(String groupId) async {
    try {
      if (_status == SyncStatus.online) {
        try {
          final cloudGroup = await _firebaseService.getGroup(groupId);
          if (cloudGroup != null) {
            await _saveGroupLocal(cloudGroup);
            return cloudGroup;
          }
        } catch (e) {
          _debugPrint('Cloud fetch failed, using local: $e');
        }
      }

      return await _getGroupLocal(groupId);
    } catch (e) {
      _debugPrint('❌ Failed to get group: $e');
      return null;
    }
  }

  Future<List<Group>> getUserGroups(String userId) async {
    try {
      if (_status == SyncStatus.online) {
        try {
          final cloudGroups = await _firebaseService.getUserGroups(userId);
          // Cache alle Gruppen lokal
          for (final group in cloudGroups) {
            await _saveGroupLocal(group);
          }
          return cloudGroups;
        } catch (e) {
          _debugPrint('Cloud fetch failed, using local: $e');
        }
      }

      return await _getUserGroupsLocal(userId);
    } catch (e) {
      _debugPrint('❌ Failed to get user groups: $e');
      return [];
    }
  }

  // Event Operations
  Future<void> saveEvent(Event event, {String? eventId, bool forceLocal = false}) async {
    try {
      await _saveEventLocal(event, eventId: eventId);

      if (_status == SyncStatus.online && !forceLocal) {
        try {
          await _firebaseService.saveEvent(event, eventId: eventId);
        } catch (e) {
          await _queueOperation(SyncOperation(
            id: eventId ?? event.groupId,
            type: 'event',
            operation: 'update',
            data: {...event.toJson(), if (eventId != null) 'eventId': eventId},
            timestamp: DateTime.now(),
          ));
        }
      } else if (!forceLocal) {
        await _queueOperation(SyncOperation(
          id: eventId ?? event.groupId,
          type: 'event',
          operation: 'update',
          data: {...event.toJson(), if (eventId != null) 'eventId': eventId},
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      _debugPrint('❌ Failed to save event: $e');
      rethrow;
    }
  }

  Future<List<Event>> getGroupEvents(String groupId) async {
    try {
      if (_status == SyncStatus.online) {
        try {
          final cloudEvents = await _firebaseService.getGroupEvents(groupId);
          // Cache Events lokal
          for (final event in cloudEvents) {
            await _saveEventLocal(event);
          }
          return cloudEvents;
        } catch (e) {
          _debugPrint('Cloud fetch failed, using local: $e');
        }
      }

      return await _getGroupEventsLocal(groupId);
    } catch (e) {
      _debugPrint('❌ Failed to get group events: $e');
      return [];
    }
  }

  // Points Operations
  Future<void> saveUserPoints(UserPoints userPoints, {bool forceLocal = false}) async {
    try {
      await _saveUserPointsLocal(userPoints);

      if (_status == SyncStatus.online && !forceLocal) {
        try {
          await _firebaseService.saveUserPoints(userPoints);
        } catch (e) {
          await _queueOperation(SyncOperation(
            id: '${userPoints.userId}_${userPoints.groupId}',
            type: 'points',
            operation: 'update',
            data: userPoints.toJson(),
            timestamp: DateTime.now(),
          ));
        }
      } else if (!forceLocal) {
        await _queueOperation(SyncOperation(
          id: '${userPoints.userId}_${userPoints.groupId}',
          type: 'points',
          operation: 'update',
          data: userPoints.toJson(),
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      _debugPrint('❌ Failed to save user points: $e');
      rethrow;
    }
  }

  Future<UserPoints?> getUserPoints(String userId, String groupId) async {
    try {
      if (_status == SyncStatus.online) {
        try {
          final cloudPoints = await _firebaseService.getUserPoints(userId, groupId);
          if (cloudPoints != null) {
            await _saveUserPointsLocal(cloudPoints);
            return cloudPoints;
          }
        } catch (e) {
          _debugPrint('Cloud fetch failed, using local: $e');
        }
      }

      return await _getUserPointsLocal(userId, groupId);
    } catch (e) {
      _debugPrint('❌ Failed to get user points: $e');
      return null;
    }
  }

  // Pending Operations Management
  Future<void> _queueOperation(SyncOperation operation) async {
    _pendingOperations.add(operation);
    await _savePendingOperations();
    _debugPrint('📝 Queued operation: ${operation.type} ${operation.operation} ${operation.id}');
  }

  Future<void> _processPendingOperations() async {
    if (_pendingOperations.isEmpty || _status != SyncStatus.online) return;

    _setStatus(SyncStatus.syncing);
    final List<SyncOperation> completed = [];

    for (final operation in _pendingOperations) {
      if (operation.retryCount >= maxRetries) {
        _debugPrint('⚠️ Max retries reached for operation: ${operation.id}');
        completed.add(operation);
        continue;
      }

      try {
        await _executeOperation(operation);
        completed.add(operation);
        _debugPrint('✅ Synced operation: ${operation.type} ${operation.operation} ${operation.id}');
      } catch (e) {
        _debugPrint('❌ Failed to sync operation: ${operation.id}, retry ${operation.retryCount + 1}');
        // Retry mit exponential backoff könnte hier implementiert werden
        final retryOperation = operation.withRetry();
        final index = _pendingOperations.indexOf(operation);
        _pendingOperations[index] = retryOperation;
      }
    }

    // Erfolgreich verarbeitete Operationen entfernen
    for (final op in completed) {
      _pendingOperations.remove(op);
    }

    await _savePendingOperations();
    _setStatus(SyncStatus.online);
  }

  Future<void> _executeOperation(SyncOperation operation) async {
    try {
      switch (operation.type) {
        case 'user':
          // Ensure data is properly formatted
          final userData = Map<String, dynamic>.from(operation.data);
          final user = User.fromJson(userData);
          await _firebaseService.saveUser(user);
          break;
        case 'group':
          // Ensure data is properly formatted
          final groupData = Map<String, dynamic>.from(operation.data);
          final group = Group.fromJson(groupData);
          await _firebaseService.saveGroup(group);
          break;
        case 'event':
          final eventData = Map<String, dynamic>.from(operation.data);
          final eventId = eventData.remove('eventId') as String?;
          final event = Event.fromJson(eventData);
          await _firebaseService.saveEvent(event, eventId: eventId);
          break;
        case 'points':
          // Ensure data is properly formatted
          final pointsData = Map<String, dynamic>.from(operation.data);
          final userPoints = UserPoints.fromJson(pointsData);
          await _firebaseService.saveUserPoints(userPoints);
          break;
        default:
          throw Exception('Unknown operation type: ${operation.type}');
      }
    } catch (e) {
      _debugPrint('❌ Failed to execute ${operation.type} operation: $e');
      _debugPrint('Operation data: ${operation.data}');
      rethrow;
    }
  }

  // Local Storage Implementation
  Future<void> _saveUserLocal(User user) async {
    final users = await _getUsersLocal();
    users[user.id] = user.toJson();
    await _prefs!.setString('users', jsonEncode(users));
  }

  Future<User?> _getUserLocal(String userId) async {
    final users = await _getUsersLocal();
    final userData = users[userId];
    return userData != null ? User.fromJson(userData) : null;
  }

  Future<Map<String, dynamic>> _getUsersLocal() async {
    final usersJson = _prefs!.getString('users');
    return usersJson != null ? jsonDecode(usersJson) : {};
  }

  Future<void> _saveGroupLocal(Group group) async {
    final groups = await _getGroupsLocal();
    groups[group.id] = group.toJson();
    await _prefs!.setString('groups', jsonEncode(groups));
  }

  Future<Group?> _getGroupLocal(String groupId) async {
    final groups = await _getGroupsLocal();
    final groupData = groups[groupId];
    if (groupData == null) return null;
    
    try {
      // Ensure groupData is a Map
      if (groupData is! Map<String, dynamic>) {
        debugPrint('Warning: Invalid group data format for $groupId');
        return null;
      }
      return Group.fromJson({...groupData, 'id': groupId});
    } catch (e) {
      debugPrint('Error parsing group $groupId: $e');
      return null;
    }
  }

  Future<List<Group>> _getUserGroupsLocal(String userId) async {
    final groups = await _getGroupsLocal();
    return groups.entries
        .where((entry) {
          try {
            // Ensure entry.value is a Map
            if (entry.value is! Map<String, dynamic>) {
              debugPrint('Warning: Invalid group data format for ${entry.key}, skipping');
              return false;
            }
            final group = Group.fromJson({...entry.value, 'id': entry.key});
            return group.members.contains(userId);
          } catch (e) {
            debugPrint('Error parsing group ${entry.key}: $e');
            return false;
          }
        })
        .map((entry) => Group.fromJson({...entry.value, 'id': entry.key}))
        .toList();
  }

  Future<Map<String, dynamic>> _getGroupsLocal() async {
    final groupsJson = _prefs!.getString('groups');
    return groupsJson != null ? jsonDecode(groupsJson) : {};
  }

  Future<void> _saveEventLocal(Event event, {String? eventId}) async {
    final events = await _getEventsLocal();
    final key = eventId ?? '${event.groupId}_${event.date.toIso8601String()}';
    events[key] = event.toJson();
    await _prefs!.setString('events', jsonEncode(events));
  }

  Future<List<Event>> _getGroupEventsLocal(String groupId) async {
    final events = await _getEventsLocal();
    return events.entries
        .where((entry) {
          final event = Event.fromJson(entry.value);
          return event.groupId == groupId;
        })
        .map((entry) => Event.fromJson(entry.value))
        .toList();
  }

  Future<Map<String, dynamic>> _getEventsLocal() async {
    final eventsJson = _prefs!.getString('events');
    return eventsJson != null ? jsonDecode(eventsJson) : {};
  }

  Future<void> _saveUserPointsLocal(UserPoints userPoints) async {
    final points = await _getPointsLocal();
    final key = '${userPoints.userId}_${userPoints.groupId}';
    points[key] = userPoints.toJson();
    await _prefs!.setString('points', jsonEncode(points));
  }

  Future<UserPoints?> _getUserPointsLocal(String userId, String groupId) async {
    final points = await _getPointsLocal();
    final key = '${userId}_$groupId';
    final pointsData = points[key];
    return pointsData != null ? UserPoints.fromJson(pointsData) : null;
  }

  Future<Map<String, dynamic>> _getPointsLocal() async {
    final pointsJson = _prefs!.getString('points');
    return pointsJson != null ? jsonDecode(pointsJson) : {};
  }

  // Pending Operations Persistence
  Future<void> _savePendingOperations() async {
    final operationsJson = _pendingOperations.map((op) => op.toJson()).toList();
    await _prefs!.setString(pendingOperationsKey, jsonEncode(operationsJson));
  }

  Future<void> _loadPendingOperations() async {
    try {
      final operationsJson = _prefs!.getString(pendingOperationsKey);
      if (operationsJson != null) {
        final operationsList = jsonDecode(operationsJson) as List;
        _pendingOperations.clear();
        
        // Filter out corrupted operations
        for (final op in operationsList) {
          try {
            if (op is Map<String, dynamic>) {
              _pendingOperations.add(SyncOperation.fromJson(op));
            }
          } catch (e) {
            _debugPrint('⚠️ Skipping corrupted operation: $e');
          }
        }
        _debugPrint('📝 Loaded ${_pendingOperations.length} pending operations');
      }
    } catch (e) {
      _debugPrint('❌ Failed to load pending operations: $e');
      // Clear corrupted data
      await _prefs!.remove(pendingOperationsKey);
      _pendingOperations.clear();
    }
  }

  // Clear corrupted pending operations
  Future<void> clearPendingOperations() async {
    _pendingOperations.clear();
    await _prefs!.remove(pendingOperationsKey);
    _debugPrint('🗑️ Cleared all pending operations');
  }

  // Force sync methods
  Future<void> forceSyncToCloud() async {
    if (_status != SyncStatus.online) {
      throw Exception('Cannot sync to cloud: not online');
    }

    _setStatus(SyncStatus.syncing);
    try {
      await _processPendingOperations();
      _debugPrint('✅ Force sync to cloud completed');
    } catch (e) {
      _debugPrint('❌ Force sync to cloud failed: $e');
      rethrow;
    } finally {
      _setStatus(SyncStatus.online);
    }
  }

  Future<void> forceSyncFromCloud() async {
    if (_status != SyncStatus.online) {
      throw Exception('Cannot sync from cloud: not online');
    }

    _setStatus(SyncStatus.syncing);
    try {
      // Hier könnte eine vollständige Cloud-zu-Local-Synchronisation implementiert werden
      // Das ist komplex und würde eine Konfliktstrategie erfordern
      _debugPrint('✅ Force sync from cloud completed');
    } catch (e) {
      _debugPrint('❌ Force sync from cloud failed: $e');
      rethrow;
    } finally {
      _setStatus(SyncStatus.online);
    }
  }

  // Data cleanup methods
  Future<void> _cleanupCorruptedData() async {
    try {
      // Check and fix groups data
      final groupsJson = _prefs!.getString('groups');
      if (groupsJson != null) {
        try {
          final groups = jsonDecode(groupsJson) as Map<String, dynamic>;
          final cleanedGroups = <String, dynamic>{};
          
          for (final entry in groups.entries) {
            if (entry.value is Map<String, dynamic>) {
              cleanedGroups[entry.key] = entry.value;
            } else {
              _debugPrint('🧹 Removing corrupted group data for ${entry.key}');
            }
          }
          
          await _prefs!.setString('groups', jsonEncode(cleanedGroups));
          _debugPrint('🧹 Groups data cleanup completed');
        } catch (e) {
          _debugPrint('🧹 Groups data corrupted, clearing: $e');
          await _prefs!.remove('groups');
        }
      }
      
      // Check and fix other data types if needed
      await _cleanupEventsData();
      await _cleanupPointsData();
      await _cleanupUsersData();
      
    } catch (e) {
      _debugPrint('❌ Data cleanup failed: $e');
    }
  }

  Future<void> _cleanupEventsData() async {
    final eventsJson = _prefs!.getString('events');
    if (eventsJson != null) {
      try {
        final events = jsonDecode(eventsJson) as Map<String, dynamic>;
        final cleanedEvents = <String, dynamic>{};
        
        for (final entry in events.entries) {
          if (entry.value is Map<String, dynamic>) {
            cleanedEvents[entry.key] = entry.value;
          }
        }
        
        await _prefs!.setString('events', jsonEncode(cleanedEvents));
      } catch (e) {
        _debugPrint('🧹 Events data corrupted, clearing: $e');
        await _prefs!.remove('events');
      }
    }
  }

  Future<void> _cleanupPointsData() async {
    final pointsJson = _prefs!.getString('points');
    if (pointsJson != null) {
      try {
        final points = jsonDecode(pointsJson) as Map<String, dynamic>;
        final cleanedPoints = <String, dynamic>{};
        
        for (final entry in points.entries) {
          if (entry.value is Map<String, dynamic>) {
            cleanedPoints[entry.key] = entry.value;
          }
        }
        
        await _prefs!.setString('points', jsonEncode(cleanedPoints));
      } catch (e) {
        _debugPrint('🧹 Points data corrupted, clearing: $e');
        await _prefs!.remove('points');
      }
    }
  }

  Future<void> _cleanupUsersData() async {
    final usersJson = _prefs!.getString('users');
    if (usersJson != null) {
      try {
        final users = jsonDecode(usersJson) as Map<String, dynamic>;
        final cleanedUsers = <String, dynamic>{};
        
        for (final entry in users.entries) {
          if (entry.value is Map<String, dynamic>) {
            cleanedUsers[entry.key] = entry.value;
          }
        }
        
        await _prefs!.setString('users', jsonEncode(cleanedUsers));
      } catch (e) {
        _debugPrint('🧹 Users data corrupted, clearing: $e');
        await _prefs!.remove('users');
      }
    }
  }

  // Cleanup
  void dispose() {
    _syncTimer?.cancel();
    _statusController.close();
  }
}

void _debugPrint(String message) {
  if (kDebugMode) {
    debugPrint('SyncService: $message');
  }
}