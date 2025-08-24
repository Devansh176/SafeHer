import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBotPage extends StatefulWidget {
  final String uid;
  const ChatBotPage({super.key, required this.uid});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Gemini API config
  static const String geminiApiKey = "AIzaSyCCczbKw7gsqFB1G-TYqRd9R88zOmRKm_8";
  static const String geminiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 80));
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _onSubmit(String text) async {
    final message = text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": message});
      _isLoading = true;
    });
    _controller.clear();
    await _scrollToBottom();

    late String reply;
    try {
      reply = await _geminiAnswer();
    } catch (e) {
      reply = "Something went wrong: $e";
    }

    setState(() {
      _messages.add({"role": "model", "text": reply});
      _isLoading = false;
    });
    await _scrollToBottom();
  }

  List<Map<String, dynamic>> _buildGeminiHistory({int keepLast = 14}) {
    final start =
    _messages.length > keepLast ? _messages.length - keepLast : 0;
    final recent = _messages.sublist(start);
    return recent
        .map((m) => {
      "role": m["role"] == "user" ? "user" : "model",
      "parts": [
        {"text": m["text"] ?? ""}
      ]
    })
        .toList();
  }

  Future<String> _geminiAnswer() async {
    final contents = _buildGeminiHistory();
    final body = {
      "systemInstruction": {
        "parts": [
          {
            "text":
            "You are SafeHer's helpful AI assistant. Always give useful, clear, and positive answers. If asked about distances or routes, provide real numbers or the best possible guidance."
          }
        ]
      },
      "contents": contents,
      "generationConfig": {
        "temperature": 0.6,
        "topP": 0.9,
        "maxOutputTokens": 512,
      },
    };

    final uri = Uri.parse("$geminiUrl?key=$geminiApiKey");
    final res = await http
        .post(uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      return "AI error ${res.statusCode}: ${res.body}";
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final text =
    (data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] as String?)
        ?.trim();
    return (text == null || text.isEmpty)
        ? "I’m not sure, but here’s my best guess!"
        : text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("SafeHer ChatBot",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.pink),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isUser = msg["role"] == "user";
                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 620),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.pink : const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUser
                            ? Colors.pinkAccent.withOpacity(0.6)
                            : Colors.white12,
                        width: 1,
                      ),
                    ),
                    child: SelectableText(
                      msg["text"] ?? "",
                      style: TextStyle(
                        color: isUser
                            ? Colors.white
                            : Colors.white.withOpacity(0.92),
                        fontSize: 15.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: CircularProgressIndicator(color: Colors.pink),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _onSubmit,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Ask anything…",
                        hintStyle: const TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        final v = _controller.text;
                        if (v.trim().isNotEmpty) _onSubmit(v);
                      },
                    ),
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
