import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_session_detail.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});
  @override State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}
class _ChatHistoryPageState extends State<ChatHistoryPage> {
  List sessions=[];
  bool loading=true;
  late String uid;

  @override
  void initState(){
    super.initState();
    uid=FirebaseAuth.instance.currentUser!.uid;
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    final res = await http.get(
        Uri.parse("http://192.168.1.3:8080/api/chat/history/sessions"),
        headers: {'X-USER-UID':uid}
    );
    final data=jsonDecode(res.body) as List;
    setState((){ sessions=data; loading=false; });
  }

  @override
  Widget build(BuildContext ctx){
    if(loading) return Center(child:CircularProgressIndicator());
    return Scaffold(
      appBar:AppBar(title:Text("History")),
      body: ListView.builder(
        itemCount: sessions.length,
        itemBuilder:(c,i){
          final s=sessions[i];
          return ListTile(
            title:Text(s['title']),
            subtitle:Text(s['createdAt']),
            onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder:(_) =>ChatSessionDetail(session:s),),
              ),

          );
        }
      )
    );
  }
}
