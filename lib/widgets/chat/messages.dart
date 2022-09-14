import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_complete_guide/widgets/chat/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

      return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final chatDocs = chatSnapshot.data.docs;
        Future<User> data() async {
          return FirebaseAuth.instance.currentUser;
        }

        return   ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) =>
              MessageBubble(chatDocs[index]['text'],
                chatDocs[index]['userId'] == FirebaseAuth.instance.currentUser.uid,
                chatDocs[index]['username'],
                chatDocs[index]['userImage'],
                key: ValueKey(chatDocs[index].id),
              ),
        );

      },
    );
  }
}
