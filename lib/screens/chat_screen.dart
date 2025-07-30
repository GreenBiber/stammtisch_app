import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final activeGroup = groupProvider.getActiveGroup(context);
    
    if (activeGroup != null) {
      await chatProvider.initializeDemoMessages(activeGroup.id);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer3<ChatProvider, AuthProvider, GroupProvider>(
      builder: (context, chatProvider, authProvider, groupProvider, child) {
        final activeGroup = groupProvider.getActiveGroup(context);
        final currentUserId = authProvider.currentUserId;
        final currentUser = authProvider.currentUser;
        
        if (activeGroup == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.chat)),
            body: const Center(child: Text('Keine aktive Gruppe ausgewählt')),
          );
        }

        final messages = chatProvider.getGroupMessages(activeGroup.id);

        return Scaffold(
          appBar: AppBar(
            title: Text('${activeGroup.name} • ${l10n.chat}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showChatInfo(activeGroup.name, messages.length),
              ),
            ],
          ),
          body: Column(
            children: [
              // Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.locale.languageCode == 'de'
                            ? '💬 Live-Chat: Nachrichten werden lokal gespeichert'
                            : '💬 Live Chat: Messages are stored locally',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Messages List
              Expanded(
                child: chatProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.locale.languageCode == 'de'
                                      ? 'Noch keine Nachrichten'
                                      : 'No messages yet',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.locale.languageCode == 'de'
                                      ? 'Sei der erste, der eine Nachricht schreibt!'
                                      : 'Be the first to send a message!',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe = message.senderId == currentUserId;
                              
                              return _buildMessageBubble(message, isMe, l10n);
                            },
                          ),
              ),
              
              const Divider(height: 1),
              
              // Message Input
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: l10n.locale.languageCode == 'de'
                              ? 'Nachricht schreiben...'
                              : 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.1),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (text) => _sendMessage(
                          chatProvider,
                          activeGroup.id,
                          currentUserId,
                          currentUser?.displayName ?? 'Unknown',
                          text,
                        ),
                        textInputAction: TextInputAction.send,
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => _sendMessage(
                          chatProvider,
                          activeGroup.id,
                          currentUserId,
                          currentUser?.displayName ?? 'Unknown',
                          _messageController.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe, dynamic l10n) {
    Color bubbleColor;
    Color textColor = Colors.white;
    
    switch (message.type) {
      case MessageType.system:
        bubbleColor = Colors.orange.withOpacity(0.8);
        break;
      case MessageType.eventUpdate:
        bubbleColor = Colors.blue.withOpacity(0.8);
        break;
      default:
        bubbleColor = isMe ? Colors.teal.withOpacity(0.8) : Colors.grey.shade700;
    }

    // System messages are centered
    if (message.isSystemMessage) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              message.type == MessageType.eventUpdate ? Icons.event : Icons.info,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.content,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    // Regular messages
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Text(
                message.senderName,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message.content,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              message.displayTime,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(
    ChatProvider chatProvider,
    String groupId,
    String senderId,
    String senderName,
    String content,
  ) {
    if (content.trim().isEmpty) return;

    chatProvider.sendMessage(
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      content: content,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _showChatInfo(String groupName, int messageCount) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.locale.languageCode == 'de' ? 'Chat-Info' : 'Chat Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.locale.languageCode == 'de' ? 'Gruppe' : 'Group'}: $groupName'),
            const SizedBox(height: 8),
            Text('${l10n.locale.languageCode == 'de' ? 'Nachrichten' : 'Messages'}: $messageCount'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}