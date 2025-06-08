import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n; // Lokalisierung

    final List<Map<String, dynamic>> messages = [
      {
        'sender': 'Liam',
        'message': l10n.locale.languageCode == 'de'
            ? 'Hey alle zusammen, wollte nur mal nachfragen wie es euch so geht.'
            : 'Hey everyone, just wanted to check in and see how everyone\'s doing.',
        'isMe': false
      },
      {
        'sender': 'Ethan',
        'message': l10n.locale.languageCode == 'de'
            ? 'Hey Liam! Mir geht\'s super, danke der Nachfrage.'
            : 'Hey Liam! I\'m doing great, thanks for asking.',
        'isMe': true
      },
      {
        'sender': 'Olivia',
        'message': l10n.locale.languageCode == 'de'
            ? 'Oh, das Kunstmuseum klingt spaßig, Ethan!'
            : 'Oh, the art museum sounds fun, Ethan!',
        'isMe': false
      },
      {
        'sender': 'Noah',
        'message': l10n.locale.languageCode == 'de'
            ? 'Ich bin auch dabei! Ich habe Gutes über die Ausstellung gehört.'
            : 'I\'m in too! I\'ve heard good things about the exhibit.',
        'isMe': false
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.locale.languageCode == 'de' 
          ? 'Stammtisch Chat' 
          : 'Group Chat')),
      body: Column(
        children: [
          // Demo Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.locale.languageCode == 'de'
                        ? '💬 Demo-Chat: In einer späteren Version wird hier ein echter Gruppenchat verfügbar sein.'
                        : '💬 Demo Chat: A real group chat will be available in a future version.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg['isMe']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: msg['isMe']
                          ? Colors.teal.withOpacity(0.7)
                          : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: msg['isMe'] 
                          ? CrossAxisAlignment.end 
                          : CrossAxisAlignment.start,
                      children: [
                        if (!msg['isMe'])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              msg['sender'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        Text(
                          msg['message'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.locale.languageCode == 'de' ? 'Gerade eben' : 'Just now',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
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
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.locale.languageCode == 'de'
                                  ? 'Emoji-Auswahl kommt in einer späteren Version'
                                  : 'Emoji picker coming in a future version'),
                            ),
                          );
                        },
                      ),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.locale.languageCode == 'de'
                                ? 'Demo-Modus: Nachricht "$text" würde gesendet werden'
                                : 'Demo mode: Message "$text" would be sent'),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                
                // Send Button
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.locale.languageCode == 'de'
                              ? 'Demo-Modus: Nachrichten-Funktion kommt bald'
                              : 'Demo mode: Messaging feature coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}