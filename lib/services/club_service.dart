// lib/services/club_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClubService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createNewClub(BuildContext context) async {
    TextEditingController clubNameController = TextEditingController();
    TextEditingController clubDescriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create a New Club"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: clubNameController,
                decoration: InputDecoration(labelText: "Club Name"),
              ),
              TextField(
                controller: clubDescriptionController,
                decoration: InputDecoration(labelText: "Club Description"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (clubNameController.text.isNotEmpty &&
                    clubDescriptionController.text.isNotEmpty) {
                  await _firestore.collection('clubs').add({
                    'name': clubNameController.text,
                    'description': clubDescriptionController.text,
                    'createdBy': _auth.currentUser?.uid,
                    'createdAt': FieldValue.serverTimestamp(),
                    'members': [_auth.currentUser?.uid], // members 필드 추가
                  });

                  Navigator.pop(context);
                }
              },
              child: Text("Create"),
            ),
          ],
        );
      },
    );
  }
}
