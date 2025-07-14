import 'package:flutter/material.dart';


class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp
  });


  @override Widget build(BuildContext context){
    return Container(
      margin:EdgeInsets.symmetric(
        vertical:5,
        horizontal:10,
      ),
      alignment: isUser? Alignment.centerRight:Alignment.centerLeft,
      child: Column(
          crossAxisAlignment: isUser? CrossAxisAlignment.end:CrossAxisAlignment.start,
          children:[
            Container(
                padding:EdgeInsets.all(10),
                constraints: BoxConstraints(maxWidth:200),
                decoration: BoxDecoration(
                    color: isUser? Colors.green[100]:Colors.grey[300],
                    borderRadius: BorderRadius.circular(8)),
                child: Text(text)
            ),
            SizedBox(height:4),
            Text(
                "${timestamp.hour}:${timestamp.minute.toString().padLeft(2,'0')}",
                style: TextStyle(fontSize:10, color:Colors.grey)),
          ]
      )
    );
  }
}
