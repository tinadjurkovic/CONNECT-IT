import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final String senderId;
  final String content;
  final String currentUserUid;

  const MessageWidget({
    Key? key,
    required this.senderId,
    required this.content,
    required this.currentUserUid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = senderId == currentUserUid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.2,
            ),
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue[100] : Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(5),
            child: Text(
              content,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
