import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_it/models/post.dart';
import 'package:connect_it/resources/storage_methods.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String description, Uint8List? file, String uid,
      String username, String profImage) async {
    String res = "Some error occurred";
    try {
      String? imageUrl;
      if (file != null) {
        imageUrl =
            await StorageMethods().uploadImageToStorage('posts', file, true);
      }
      String postId = const Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: imageUrl ?? '',
        profImage: profImage,
      );
      await _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> postComment(String postId, String text, String uid,
      String name) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });

        await _firestore.collection('notifications').add({
          'type': 'follow',
          'senderUid': uid,
          'receiverUid': followId,
          'timestamp': Timestamp.now(),
        }).then((value) => print("Follow notification added"))
        .catchError((e) => print("Error adding follow notification: $e"));
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }

  Future<void> likePostWithNotification(String currentUserUid, String postId, String postOwnerUid) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([currentUserUid])
      });

      await _firestore.collection('notifications').add({
        'type': 'like',
        'senderUid': currentUserUid,
        'receiverUid': postOwnerUid,
        'postId': postId,
        'timestamp': Timestamp.now(),
      }).then((value) => print("Like notification added"))
      .catchError((e) => print("Error adding like notification: $e"));
    } catch (e) {
      print("Error liking post: $e");
    }
  }

  Future<void> commentOnPostWithNotification(String currentUserUid, String postId, String postOwnerUid, String comment) async {
    try {
      await _firestore.collection('posts').doc(postId).collection('comments').add({
        'uid': currentUserUid,
        'comment': comment,
        'timestamp': Timestamp.now(),
      });

      await _firestore.collection('notifications').add({
        'type': 'comment',
        'senderUid': currentUserUid,
        'receiverUid': postOwnerUid,
        'postId': postId,
        'timestamp': Timestamp.now(),
      }).then((value) => print("Comment notification added"))
      .catchError((e) => print("Error adding comment notification: $e"));
    } catch (e) {
      print("Error commenting on post: $e");
    }
  }

  Future<List<String>> fetchNotifications(String uid) async {
    List<String> notifications = [];

    try {
      QuerySnapshot notificationsSnapshot = await _firestore
          .collection('notifications')
          .where('receiverUid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .get();

      print("Fetched ${notificationsSnapshot.docs.length} notifications");

      for (var doc in notificationsSnapshot.docs) {
        String type = doc['type'];
        String senderUid = doc['senderUid'];

        DocumentSnapshot senderSnapshot = await _firestore.collection('users').doc(senderUid).get();
        String senderUsername = senderSnapshot.exists ? senderSnapshot['username'] : 'Unknown user';

        String message = '';
        switch (type) {
          case 'follow':
            message = '$senderUsername made a connection with you';
            break;
          case 'like':
            message = '$senderUsername liked your post';
            break;
          case 'comment':
            message = '$senderUsername commented on your post';
            break;
          default:
            message = 'Unknown notification type';
        }

        notifications.add(message);
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }

    return notifications;
  }

  Future<String> deleteComment(String postId, String commentId) async {
  String res = "Some error occurred";
  try {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
    res = 'success';
  } catch (err) {
    res = err.toString();
  }
  return res;
}

}
