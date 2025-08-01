import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';

class ChatProvider with ChangeNotifier {
  static const String _storageKey = 'chat_messages';
  final Map<String, List<ChatMessage>> _groupMessages = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Get messages for a specific group
  List<ChatMessage> getGroupMessages(String groupId) {
    return _groupMessages[groupId] ?? [];
  }

  // Load messages from storage
  Future<void> loadMessages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_storageKey);

      if (messagesJson != null) {
        final Map<String, dynamic> allMessages = json.decode(messagesJson);

        _groupMessages.clear();
        for (final entry in allMessages.entries) {
          final groupId = entry.key;
          final messageList = entry.value as List;

          _groupMessages[groupId] = messageList
              .map((msg) => ChatMessage.fromJson(msg))
              .toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        }
      }

      print('📱 Loaded ${_groupMessages.length} chat groups');
    } catch (e) {
      print('❌ Error loading chat messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save messages to storage
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final Map<String, dynamic> allMessages = {};
      for (final entry in _groupMessages.entries) {
        allMessages[entry.key] =
            entry.value.map((msg) => msg.toJson()).toList();
      }

      await prefs.setString(_storageKey, json.encode(allMessages));
      print('💾 Chat messages saved');
    } catch (e) {
      print('❌ Error saving chat messages: $e');
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    if (content.trim().isEmpty) return;

    final message = ChatMessage(
      id: const Uuid().v4(),
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      content: content.trim(),
      timestamp: DateTime.now(),
      type: type,
    );

    // Add to group messages
    if (!_groupMessages.containsKey(groupId)) {
      _groupMessages[groupId] = [];
    }

    _groupMessages[groupId]!.add(message);

    // Keep only last 100 messages per group to prevent storage issues
    if (_groupMessages[groupId]!.length > 100) {
      _groupMessages[groupId]!.removeAt(0);
    }

    await _saveMessages();
    notifyListeners();

    print(
        '💬 Message sent: ${content.substring(0, content.length.clamp(0, 30))}...');
  }

  // Send system message
  Future<void> sendSystemMessage({
    required String groupId,
    required String content,
    MessageType type = MessageType.system,
  }) async {
    await sendMessage(
      groupId: groupId,
      senderId: 'system',
      senderName: type == MessageType.eventUpdate ? 'Stammtisch Bot' : 'System',
      content: content,
      type: type,
    );
  }

  // Clear messages for a group
  Future<void> clearGroupMessages(String groupId) async {
    _groupMessages[groupId]?.clear();
    await _saveMessages();
    notifyListeners();
  }

  // Get message count for a group
  int getMessageCount(String groupId) {
    return _groupMessages[groupId]?.length ?? 0;
  }

  // Get last message for a group (for preview)
  ChatMessage? getLastMessage(String groupId) {
    final messages = _groupMessages[groupId];
    return messages?.isNotEmpty == true ? messages!.last : null;
  }

  // Initialize demo messages for a group
  Future<void> initializeDemoMessages(String groupId) async {
    if (_groupMessages.containsKey(groupId) &&
        _groupMessages[groupId]!.isNotEmpty) {
      return; // Already has messages
    }

    final demoMessages = [
      ChatMessage(
        id: const Uuid().v4(),
        groupId: groupId,
        senderId: 'demo_user_1',
        senderName: 'Liam',
        content:
            'Hey alle zusammen, wollte nur mal nachfragen wie es euch so geht.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: MessageType.text,
      ),
      ChatMessage(
        id: const Uuid().v4(),
        groupId: groupId,
        senderId: 'demo_user_2',
        senderName: 'Ethan',
        content: 'Hey Liam! Mir geht\'s super, danke der Nachfrage.',
        timestamp:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        type: MessageType.text,
      ),
      ChatMessage(
        id: const Uuid().v4(),
        groupId: groupId,
        senderId: 'system',
        senderName: 'Stammtisch Bot',
        content: '🍺 Nächster Stammtisch: Dienstag, 4. Februar um 19:00 Uhr',
        timestamp:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        type: MessageType.eventUpdate,
      ),
      ChatMessage(
        id: const Uuid().v4(),
        groupId: groupId,
        senderId: 'demo_user_3',
        senderName: 'Olivia',
        content: 'Ich bin dabei! Wo treffen wir uns denn?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        type: MessageType.text,
      ),
      ChatMessage(
        id: const Uuid().v4(),
        groupId: groupId,
        senderId: 'demo_user_4',
        senderName: 'Noah',
        content: 'Ich bin auch dabei! Freue mich schon darauf 🍻',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        type: MessageType.text,
      ),
    ];

    _groupMessages[groupId] = demoMessages;
    await _saveMessages();
    notifyListeners();

    print('🎭 Demo messages initialized for group $groupId');
  }

  // Delete a message (admin feature)
  Future<void> deleteMessage(String groupId, String messageId) async {
    final messages = _groupMessages[groupId];
    if (messages != null) {
      messages.removeWhere((msg) => msg.id == messageId);
      await _saveMessages();
      notifyListeners();
    }
  }

  // Search messages in a group
  List<ChatMessage> searchMessages(String groupId, String query) {
    final messages = _groupMessages[groupId] ?? [];
    if (query.trim().isEmpty) return messages;

    return messages
        .where((msg) =>
            msg.content.toLowerCase().contains(query.toLowerCase()) ||
            msg.senderName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
