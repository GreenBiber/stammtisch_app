import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> messages = [
      {
        'sender': 'Liam',
        'message': 'Hey everyone, just wanted to check in and see how everyone’s doing.',
        'isMe': false
      },
      {
        'sender': 'Ethan',
        'message': 'Hey Liam! I’m doing great, thanks for asking.',
        'isMe': true
      },
      {
        'sender': 'Olivia',
        'message': 'Oh, the art museum sounds fun, Ethan!',
        'isMe': false
      },
      {
        'sender': 'Noah',
        'message': 'I’m in too! I’ve heard good things about the exhibit.',
        'isMe': false
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Stammtisch Chat')),
      body: Column(
        children: [
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
                    decoration: BoxDecoration(
                      color: msg['isMe']
                          ? Colors.teal.withOpacity(0.7)
                          : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['message'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Nachricht schreiben...',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    // Dummy: keine echte Logik
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
