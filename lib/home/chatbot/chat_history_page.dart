import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_message.dart';
import 'model/ChatMessageModel.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  List<ChatMessageModel> history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final res = await http.get(
        Uri.parse("http://192.168.1.3:8080/api/chat/history"),
        headers: {
          'Content-Type': 'application/json',
          'X-USER-UID': user.uid,
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          history = data.map((item) => ChatMessageModel.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Failed to fetch chat history: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text("Chat History"),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
          ? const Center(child: Text("No chat history found."))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final msg = history[index];
          return ChatMessage(
            text: msg.text,
            isUser: msg.isUser,
            timestamp: msg.timestamp,
          );
        },
      ),
    );
  }
}
