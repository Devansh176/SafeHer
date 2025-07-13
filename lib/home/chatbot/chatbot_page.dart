import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safer/home/chatbot/chat_history_page.dart';
import 'chat_message.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  bool _isBotTyping = false;

  late final String userUid;

  @override
  void initState() {
    super.initState();
    userUid = FirebaseAuth.instance.currentUser!.uid;
    _loadChatHistory();
  }

  void _loadChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.3:8080/api/chat/history'),
        headers: {
          'Content-Type': 'application/json',
          'X-USER-UID': userUid,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> chatList = jsonDecode(response.body);
        setState(() {
          _messages.clear();
          _messages.addAll(chatList.map((msg) => {
            'text': msg['text'],
            'isUser': msg['isUser'] == true,
            'timestamp': DateTime.tryParse(msg['timestamp'] ?? '') ?? DateTime.now(),
          }));
        });
      }
    } catch (e) {
      print("Failed to load history: $e");
    }
  }

  void _sendMessage(String userText) {
    if (userText.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': userText.trim(),
        'isUser': true,
        'timestamp': DateTime.now(),
      });
    });
    _controller.clear();
    _scrollToBottom();

    _getBotResponse(userText);
  }

  void _getBotResponse(String input) async {
    setState(() => _isBotTyping = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.3:8080/api/chat'),
        headers: {
          'Content-Type': 'application/json',
          'X-USER-UID': userUid,
        },
        body: jsonEncode({'message': input}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final botReply = json['response'] ?? 'Sorry, I didn\'t understand that.';

        setState(() {
          _messages.add({
            'text': botReply,
            'isUser': false,
            'timestamp': DateTime.now(),
          });
          _isBotTyping = false;
        });
      } else {
        setState(() {
          _messages.add({
            'text': 'Server error: ${response.statusCode}',
            'isUser': false,
            'timestamp': DateTime.now(),
          });
          _isBotTyping = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'text': 'Failed to connect to backend.',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isBotTyping = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text("SafeHer Assistant"),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length + (_isBotTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isBotTyping && index == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: const [
                        CircleAvatar(radius: 12, backgroundColor: Colors.grey),
                        SizedBox(width: 8),
                        Text("Typing...", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final msg = _messages[index];
                return ChatMessage(
                  text: msg['text'],
                  isUser: msg['isUser'],
                  timestamp: msg['timestamp'],
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: const InputDecoration(
                        hintText: "Ask about SOS, Safe Routes, or Call features...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: () => _sendMessage(_controller.text),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
