import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_it/models/post.dart';
import 'package:connect_it/resources/storage_methods.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot> getUserDetails(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<DocumentSnapshot> getPostDetails(String postId) async {
    return await _firestore.collection('posts').doc(postId).get();
  }

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
      DocumentSnapshot postSnap =
          await _firestore.collection('posts').doc(postId).get();
      String postOwnerUid = postSnap['uid'];

      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
        await sendLikeNotification(uid, postOwnerUid, postId);
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> postComment(
      String postId, String text, String uid, String name) async {
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

        DocumentSnapshot postSnap =
            await _firestore.collection('posts').doc(postId).get();
        String postOwnerUid = postSnap['uid'];

        await sendCommentNotification(uid, postOwnerUid, postId, text);

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

        await sendFollowNotification(uid, followId);
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
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

  String getChatRoomId(String user1Uid, String user2Uid) {
    List<String> userIds = [user1Uid, user2Uid]..sort();
    return '${userIds[0]}_${userIds[1]}';
  }

  Future<void> sendFollowNotification(
      String senderUid, String receiverUid) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(receiverUid)
          .collection('userNotifications')
          .add({
        'type': 'follow',
        'senderUid': senderUid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error sending follow notification: $e");
    }
  }

  Future<void> sendLikeNotification(
      String senderUid, String receiverUid, String postId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(receiverUid)
          .collection('userNotifications')
          .add({
        'type': 'like',
        'senderUid': senderUid,
        'postId': postId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error sending like notification: $e");
    }
  }

  Future<void> sendCommentNotification(String senderUid, String receiverUid,
      String postId, String comment) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(receiverUid)
          .collection('userNotifications')
          .add({
        'type': 'comment',
        'senderUid': senderUid,
        'postId': postId,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error sending comment notification: $e");
    }
  }

  Stream<List<DocumentSnapshot>> streamNotifications(String uid) {
    return _firestore
        .collection('notifications')
        .doc(uid)
        .collection('userNotifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      return query.docs;
    });
  }

  Future<void> sendMessageNotification(
      String senderUid, String receiverUid) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(receiverUid)
          .collection('userNotifications')
          .add({
        'type': 'message',
        'senderUid': senderUid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error sending message notification: $e");
    }
  }
}
