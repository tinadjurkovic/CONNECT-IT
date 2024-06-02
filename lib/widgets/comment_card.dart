import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatelessWidget {
  final DocumentSnapshot snap;
  final VoidCallback onDelete;
  
  const CommentCard({Key? key, required this.snap, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = snap.data() as Map<String, dynamic>?;

    final String name = data?['name'] ?? 'Anonymous';
    final String text = data?['text'] ?? '';
    final Timestamp datePublished = data?['datePublished'] ?? Timestamp.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: ' $text',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          DateFormat.yMMMd().format(datePublished.toDate()),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 3, color: Color.fromARGB(255, 4, 2, 49), thickness: 0.5,),
      ],
    );
  }
}
