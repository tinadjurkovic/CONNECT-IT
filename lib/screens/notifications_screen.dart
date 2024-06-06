import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_it/screens/chat_screen.dart';
import 'package:connect_it/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connect_it/resources/firestore_methods.dart';

class NotificationsScreen extends StatelessWidget {
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: backroundColor,
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: FireStoreMethods().streamNotifications(currentUserUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FireStoreMethods()
                    .getUserDetails(notification['senderUid']),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading...',
                          style: TextStyle(color: backroundColor)),
                    );
                  }
                  if (userSnapshot.hasError ||
                      !userSnapshot.hasData ||
                      userSnapshot.data!.data() == null) {
                    return const ListTile(
                      title: Text('Error fetching user details',
                          style: TextStyle(color: backroundColor)),
                    );
                  }
                  final user =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final username = user['username'] ?? 'Unknown';
                  return buildNotificationTile(context, notification, username);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget buildNotificationTile(
      BuildContext context, DocumentSnapshot notification, String username) {
    var data = notification.data() as Map<String, dynamic>?;

    if (data == null) {
      return const ListTile(
        title: Text('Error: Notification data is null',
            style: TextStyle(color: backroundColor)),
      );
    }

    String type = data['type'] ?? 'Unknown';
    String postId = data['postId'] ?? '';
    String comment = data['comment'] ?? '';
    String senderUid = data['senderUid'] ?? '';
    String notificationText = '';

    switch (type) {
      case 'follow':
        notificationText = '$username made a connection with you';
        break;
      case 'like':
        notificationText = '$username reacted on your post';
        break;
      case 'comment':
        notificationText = '$username commented on your post: $comment';
        break;
      case 'message':
        notificationText = 'New message from $username';
        break;
      default:
        notificationText = 'Unknown notification type';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(96, 255, 255, 255),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          title: Text(notificationText,
              style: const TextStyle(color: backroundColor)),
          onTap: () {
            if (type == 'message') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(
                  currentUserUid: FirebaseAuth.instance.currentUser!.uid,
                  recipientUid: senderUid,
                ),
              ));
            } else if (type != 'follow') {
              _showPostDialog(context, postId);
            }
          },
        ),
      ),
    );
  }

  void _showPostDialog(BuildContext context, String postId) async {
    DocumentSnapshot postSnapshot =
        await FireStoreMethods().getPostDetails(postId);
    var post = postSnapshot.data() as Map<String, dynamic>?;

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Post Details',
            style: TextStyle(
                color: backroundColor,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          content: post != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post['postUrl'] != null && post['postUrl'].isNotEmpty)
                      Image.network(post['postUrl']),
                    const SizedBox(height: 8),
                    Text('Description: ${post['description']}',
                        style: const TextStyle(color: backroundColor)),
                    const SizedBox(height: 8),
                  ],
                )
              : const Text('No details available',
                  style: TextStyle(color: backroundColor)),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Close', style: TextStyle(color: backroundColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
