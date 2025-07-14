import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_message.dart';
import 'chat_history_page.dart';

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
  late String userUid;
  late String currentSessionId;

  @override
  void initState() {
    super.initState();
    userUid = FirebaseAuth.instance.currentUser!.uid;
    _initSession();
  }

  Future<void> _initSession() async {
    final prefs = await SharedPreferences.getInstance();
    currentSessionId = prefs.getString('currentSessionId') ?? '';

    if (currentSessionId.isEmpty) {
      final response = await http.post(
        Uri.parse('http://192.168.1.3:8080/api/chat/session'),
        headers: {'X-USER-UID': userUid},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        currentSessionId = json['sessionId'];
        await prefs.setString('currentSessionId', currentSessionId);
      }
    }

    _loadChatHistory();
  }

  void _loadChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.3:8080/api/chat/history/$currentSessionId'),
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
            'timestamp': DateTime.tryParse(msg['timestamp'] ?? '') ??
                DateTime.now(),
          }));
        });
        _scrollToBottom();
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

    _getBotResponse(userText.trim());
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
        body: jsonEncode({
          'message': input,
          'sessionId': currentSessionId,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final botReply =
            json['response'] ?? 'Sorry, I didn\'t understand that.';

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
            'text': 'Server error: \${response.statusCode}',
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
    Future.delayed(const Duration(milliseconds: 200), () {
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
  void dispose() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('currentSessionId');
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("SafeHer Assistant"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: Row(
                      children: const [
                        CircleAvatar(radius: 12, backgroundColor: Colors.grey),
                        SizedBox(width: 8),
                        Text("Typing...",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final msg = _messages[index];
                return ChatMessage(
                  text: msg['text'] ?? '',
                  isUser: msg['isUser'] == true,
                  timestamp: msg['timestamp'] ?? DateTime.now(),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00C9A7).withOpacity(0.3), Colors.white12],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.tealAccent.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.tealAccent,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: const InputDecoration(
                        hintText:
                        "Ask about SOS, Safe Routes, or Call features...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.tealAccent),
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