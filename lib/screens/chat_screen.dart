import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_it/resources/firestore_methods.dart';
import 'package:connect_it/utils/colors.dart';
import 'package:connect_it/widgets/searchable_user_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  final String currentUserUid;
  String recipientUid;

  ChatScreen({
    Key? key,
    required this.currentUserUid,
    required this.recipientUid,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String recipientUsername = '';
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchRecipientUsername();
  }

  Future<void> fetchRecipientUsername() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.recipientUid)
        .get();
    if (doc.exists && doc.data()!.containsKey('username')) {
      setState(() {
        recipientUsername = doc['username'];
      });
    } else {
      setState(() {
        recipientUsername = 'Chat';
      });
    }
  }

  void sendMessage(String messageText) {
    if (messageText.trim().isNotEmpty) {
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      String chatRoomId =
          FireStoreMethods().getChatRoomId(currentUserUid, widget.recipientUid);
      _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'senderUid': currentUserUid,
        'recipientUid': widget.recipientUid,
        'content': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((value) {
        FireStoreMethods().sendMessageNotification(
            currentUserUid, widget.recipientUid); // Send notification
        print('Message sent successfully!');
      }).catchError((error) {
        print('Error sending message: $error');
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipientUsername.isEmpty ? 'Chat' : recipientUsername),
        backgroundColor: backroundColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatRooms')
                  .doc(_getChatRoomId(
                      widget.currentUserUid, widget.recipientUid))
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No messages yet.'),
                  );
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final messageContent = message['content'];
                    final isCurrentUser =
                        message['senderUid'] == widget.currentUserUid;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            messageContent,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '  Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getChatRoomId(String user1Uid, String user2Uid) {
    List<String> userIds = [user1Uid, user2Uid]..sort();
    return '${userIds[0]}_${userIds[1]}';
  }

  void _navigateToAddRecipientScreen() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recipient'),
          backgroundColor: backroundColor,
        ),
        body: SearchableUserList(
          onRecipientSelected: (recipientUid) {
            setState(() {
              widget.recipientUid = recipientUid;
            });
            fetchRecipientUsername();
            Navigator.of(context).pop();
          },
        ),
      );
    }));
  }
}
