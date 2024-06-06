import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_it/screens/profile_screen.dart';
import 'package:connect_it/utils/colors.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backroundColor,
      appBar: AppBar(
        backgroundColor: backroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search for an IT enthusiast...',
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          onFieldSubmitted: (String _) {
            setState(() {
              isShowUsers = true;
            });
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            Expanded(
              child: isShowUsers ? _buildUserList() : _buildPostGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .where(
            'username',
            isGreaterThanOrEqualTo: searchController.text,
          )
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: (snapshot.data! as QuerySnapshot).docs.length,
          itemBuilder: (context, index) {
            var userDoc = (snapshot.data! as QuerySnapshot).docs[index];
            var userData = userDoc.data() as Map<String, dynamic>?;
            var photoUrl = userData?.containsKey('photoUrl') ?? false
                ? userData!['photoUrl']
                : 'https://via.placeholder.com/150'; // placeholder image URL
            return InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(uid: userDoc['uid']),
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(photoUrl),
                  radius: 16,
                ),
                title: Text(
                  userDoc['username'],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostGrid() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('posts')
          .where('postUrl', isNotEqualTo: '')
          .orderBy('postUrl')
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.0,
          ),
          itemCount: (snapshot.data! as QuerySnapshot).docs.length,
          itemBuilder: (context, index) {
            final imageUrl =
                (snapshot.data! as QuerySnapshot).docs[index]['postUrl'];
            return GestureDetector(
              onTap: () {},
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      },
    );
  }
}
