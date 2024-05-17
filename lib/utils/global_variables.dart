import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_it/screens/chat_screen.dart';
import 'package:connect_it/screens/feed_screen.dart';
import 'package:connect_it/screens/notifications_screen.dart';
import 'package:connect_it/screens/profile_screen.dart';
import 'package:connect_it/screens/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const NotificationsScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser?.uid ?? '', // Provide a fallback
  ),
  FutureBuilder<String>(
    future: _getRecipientUid(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(child: Text('No recent chat available')); // Better error handling
      } else {
        return ChatScreen(
          currentUserUid: FirebaseAuth.instance.currentUser?.uid ?? '', // Provide a fallback
          recipientUid: snapshot.data!,
        );
      }
    },
  ),
];

Future<String> _getRecipientUid() async {
  String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  if (currentUserUid.isEmpty) {
    return '';
  }
  
  String recipientUid = ''; 
  try {
    QuerySnapshot recipientSnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('senderUid', isEqualTo: currentUserUid)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (recipientSnapshot.docs.isNotEmpty) {
      recipientUid = recipientSnapshot.docs.first['recipientUid'];
    }
  } catch (error) {
    // ignore: avoid_print
    print('Error fetching recipient UID: $error');
  }
  return recipientUid;
}
