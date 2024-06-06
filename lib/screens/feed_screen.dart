// ignore_for_file: unnecessary_const

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_it/providers/user_provider.dart';
import 'package:connect_it/resources/firestore_methods.dart';
import 'package:connect_it/screens/chat_screen.dart';
import 'package:connect_it/utils/colors.dart';
import 'package:connect_it/utils/utils.dart';
import 'package:connect_it/widgets/post_card.dart';
import 'package:connect_it/widgets/searchable_user_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:connect_it/models/user.dart' as model;

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return _buildFeedScreen(userProvider.getUser);
  }

  Widget _buildFeedScreen(model.User? user) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backroundColor,
        centerTitle: true,
        title: Image.asset(
          'assets/logo.png',
          height: 100,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

              String? recipientUid = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Recipient'),
                      backgroundColor: backroundColor,
                    ),
                    body: SearchableUserList(
                      onRecipientSelected: (recipientUid) {
                        Navigator.of(context).pop(recipientUid);
                      },
                    ),
                  ),
                ),
              );

              if (recipientUid != null) {
                // ignore: use_build_context_synchronously
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      currentUserUid: currentUserUid,
                      recipientUid: recipientUid,
                    ),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.messenger_rounded,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isLoading
              ? const LinearProgressIndicator()
              : const SizedBox(height: 0),
          const Divider(),
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(user!.photoUrl),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ),
              ),
              if (_file != null)
                Image.memory(
                  _file!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              IconButton(
                onPressed: () async {
                  Uint8List? file = await _selectImage(context);
                  setState(() {
                    _file = file;
                  });
                },
                icon: const Icon(Icons.camera_alt),
              ),
            ],
          ),
          const Divider(),
          Container(
            width: 1,
            child: ElevatedButton(
              onPressed: () => post(
                user.uid,
                user.username,
                user.photoUrl,
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Post',
                style: TextStyle(
                  color: backroundColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('datePublished', descending: true)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final posts = snapshot.data!.docs.map((doc) {
                final postData = doc.data();

                return PostCard(
                  snap: postData,
                );
              }).toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (ctx, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 0,
                    ),
                    child: posts[index],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _selectImage(BuildContext parentContext) async {
    Uint8List? file = await showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Choose from Gallery'),
              onPressed: () async {
                Navigator.pop(context);
                Uint8List? selectedFile = await pickImage(ImageSource.gallery);
                setState(() {
                  _file = selectedFile;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );

    return file;
  }

  Future<void> post(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (username.isEmpty || profImage.isEmpty) {
        throw Exception("Username or profile image is empty");
      }

      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        _file,
        uid,
        username,
        profImage,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
          _descriptionController.clear();
          _file = null;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Posted!'),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res),
          ),
        );
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString()),
        ),
      );
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }
}
