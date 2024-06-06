import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchableUserList extends StatefulWidget {
  final Function(String) onRecipientSelected;

  const SearchableUserList({Key? key, required this.onRecipientSelected})
      : super(key: key);

  @override
  _SearchableUserListState createState() => _SearchableUserListState();
}

class _SearchableUserListState extends State<SearchableUserList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search for an IT enthusiast...',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: _buildUserList(),
        ),
      ],
    );
  }

  Widget _buildUserList() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .where(
            'username',
            isGreaterThanOrEqualTo: _searchController.text,
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
            return ListTile(
              title: Text(
                userDoc['username'],
              ),
              onTap: () {
                final recipientUid = userDoc['uid'] ?? 0;
                widget.onRecipientSelected(recipientUid);
              },
            );
          },
        );
      },
    );
  }
}
