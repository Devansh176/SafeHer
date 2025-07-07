import 'package:flutter/material.dart';
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

    await Future.delayed(const Duration(milliseconds: 1500)); // Simulate API call

    final botReply = "This is a smart response to: \"$input\" (Imagine it came from Spring Boot + OpenAI)";

    setState(() {
      _messages.add({
        'text': botReply,
        'isUser': false,
        'timestamp': DateTime.now(),
      });
      _isBotTyping = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
                      children: [
                        const CircleAvatar(radius: 12, backgroundColor: Colors.grey),
                        const SizedBox(width: 8),
                        const Text("Typing...", style: TextStyle(color: Colors.grey)),
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
                boxShadow: [
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
                        hintText: "Ask about safe routes or features...",
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
