import 'package:connect_it/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connect_it/resources/firestore_methods.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<String>> _fetchNotifications() async {
    final currentUserUid = _auth.currentUser!.uid;
    print("Fetching notifications for user: $currentUserUid");
    return await FireStoreMethods().fetchNotifications(currentUserUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: backroundColor,
      ),
      body: FutureBuilder<List<String>>(
        future: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          final notifications = snapshot.data!;
          print("Displaying ${notifications.length} notifications");
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification),
              );
            },
          );
        },
      ),
    );
  }
}
