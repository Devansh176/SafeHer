import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_message.dart';

class ChatSessionDetail extends StatefulWidget {
  final Map session;
  ChatSessionDetail({required this.session});
  @override State<ChatSessionDetail> createState() => _ChatSessionDetailState();
}

class _ChatSessionDetailState extends State<ChatSessionDetail> {
  List messages=[];
  bool loading=true;
  late String uid;

  @override
  void initState(){
    super.initState();
    uid=FirebaseAuth.instance.currentUser!.uid;
    loadSession();
  }

  Future<void> loadSession() async {
    final res = await http.get(
        Uri.parse("http://192.168.1.3:8080/api/chat/history/${widget.session['sessionId']}"),
        headers:{'X-USER-UID':uid});
    messages=jsonDecode(res.body);
    setState((){ loading=false; });
  }

  @override
  Widget build(BuildContext ctx){
    if(loading) return Center(child:CircularProgressIndicator());
    return Scaffold(
        appBar:AppBar(title:Text(widget.session['title'])),
        body: ListView.builder(
            itemCount:messages.length,
            itemBuilder:(c,i){
              final m=messages[i];
              return Align(
                  alignment: m['isUser']==true?Alignment.centerRight:Alignment.centerLeft,
                  child: ChatMessage(
                      text:m['text'],
                      isUser:m['isUser']==true,
                      timestamp: DateTime.parse(m['timestamp'])
                  )
              );
            }
        )
    );
  }
}
