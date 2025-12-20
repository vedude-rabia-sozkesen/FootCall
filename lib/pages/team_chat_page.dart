import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../utils/colors.dart';
import '../providers/setting_provider.dart';
import '../services/chat_service.dart';

class TeamChatPage extends StatefulWidget {
  final String teamId;
  final String teamName;

  const TeamChatPage({super.key, required this.teamId, required this.teamName});

  @override
  State<TeamChatPage> createState() => _TeamChatPageState();
}

class _TeamChatPageState extends State<TeamChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final playerSnap = await FirebaseFirestore.instance.collection('players').doc(user.uid).get();
    final senderName = playerSnap.data()?['name'] ?? 'Unknown';

    final chatService = Provider.of<ChatService>(context, listen: false);
    _messageController.clear();

    await chatService.sendMessage(
      teamId: widget.teamId,
      senderId: user.uid,
      senderName: senderName,
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;
    final chatService = Provider.of<ChatService>(context, listen: false);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ChatTopBar(title: widget.teamName, isDark: isDark, settings: settings),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: chatService.getMessages(widget.teamId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No messages yet", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)));
                  }

                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final data = messages[index].data() as Map<String, dynamic>;
                      final isMe = data['senderId'] == FirebaseAuth.instance.currentUser?.uid;
                      final Timestamp? timestamp = data['timestamp'];
                      final String time = timestamp != null 
                          ? DateFormat('HH:mm').format(timestamp.toDate()) 
                          : '';

                      return _ChatBubble(
                        text: data['text'] ?? '',
                        sender: data['senderName'] ?? 'Unknown',
                        isMe: isMe,
                        time: time,
                      );
                    },
                  );
                },
              ),
            ),
            _MessageInputBar(controller: _messageController, onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}

class _ChatTopBar extends StatelessWidget {
  const _ChatTopBar({required this.title, required this.isDark, required this.settings});
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
          IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
          Expanded(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
          IconButton(
            onPressed: settings.toggleTheme,
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: isDark ? Colors.black : Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;
  final String time;

  const _ChatBubble({required this.text, required this.sender, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? kAppGreen : Colors.grey.shade300;
    final textColor = isMe ? Colors.white : Colors.black87;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMe ? 18 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 18),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe) Padding(padding: const EdgeInsets.only(left: 4, bottom: 2), child: Text(sender, style: const TextStyle(color: Colors.grey, fontSize: 11))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(color: bubbleColor, borderRadius: radius),
            child: Text(text, style: TextStyle(color: textColor)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
            child: Text(time, style: const TextStyle(color: Colors.grey, fontSize: 9)),
          ),
        ],
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _MessageInputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2)))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(hintText: 'Message...', border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(backgroundColor: kAppGreen, child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: onSend))
        ],
      ),
    );
  }
}
