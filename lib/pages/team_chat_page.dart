import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/colors.dart';
import '../providers/setting_provider.dart';

class TeamChatDemo extends StatelessWidget {
  const TeamChatDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ChatTopBar(title: 'SABANCISPOR', isDark: isDark, settings: settings),
            const SizedBox(height: 8),
            const Expanded(child: _ChatMessagesList()),
            const _MessageInputBar(),
          ],
        ),
      ),
    );
  }
}

class _ChatTopBar extends StatelessWidget {
  const _ChatTopBar({
    required this.title,
    required this.isDark,
    required this.settings,
  });

  final String title;
  final bool isDark;
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      color: kAppGreen,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.black,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: settings.toggleTheme,
              child: SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: isDark ? Colors.black : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  _ChatMessage({
    required this.text,
    required this.isMe,
    required this.sender,
    this.showAvatar = false,
  });

  final String text;
  final bool isMe;
  final String sender;
  final bool showAvatar;
}

final List<_ChatMessage> _dummyMessages = [
  _ChatMessage(text: 'Ben bugün yokum abi', isMe: false, sender: 'Said Kaya'),
  _ChatMessage(
      text: 'okeyim', isMe: false, sender: 'Berk Yağız Topçu', showAvatar: true),
  _ChatMessage(text: 'Tamam bana uyar gelirim', isMe: false, sender: 'Bora İlian'),
  _ChatMessage(
      text: 'Arkadaşlar çok güzel antrenmandı', isMe: true, sender: 'Admin'),
  _ChatMessage(
      text: 'Bugün 9–10 Ataşehirde antrenman yapalım', isMe: true, sender: 'Admin'),
];

class _ChatMessagesList extends StatelessWidget {
  const _ChatMessagesList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        for (final msg in _dummyMessages) _ChatBubble(message: msg),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final bubbleColor = isMe ? kAppGreen : Colors.grey.shade300;
    final textColor = isMe ? Colors.white : Colors.black87;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMe ? 18 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 18),
    );

    Widget bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(color: bubbleColor, borderRadius: radius),
      child: Text(message.text, style: TextStyle(color: textColor)),
    );

    if (!isMe) {
      bubble = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor:
            message.showAvatar ? Colors.white : Colors.grey.shade700,
            child: message.showAvatar
                ? Text(message.sender.characters.first,
                style: const TextStyle(color: Colors.black))
                : const Icon(Icons.person, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.sender,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
              bubble,
            ],
          ),
        ],
      );
    }

    return Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, child: bubble);
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF222426),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Message...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration:
            const BoxDecoration(color: kAppGreen, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}
