import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'club_creation_success_screen.dart';

class MyClubsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getUserClubs() {
    return _firestore.collection('clubs')
        .where('createdBy', isEqualTo: _auth.currentUser?.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Clubs"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUserClubs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("You aren't a member of any clubs"));
          }
          final clubs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(clubs[index]['name']),
                subtitle: Text(clubs[index]['description']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _createNewClub(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _createNewClub(BuildContext context) async {
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
                  });

                  Navigator.pop(context);

                  // 클럽 생성 후 성공 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClubCreationSuccessScreen(
                        clubName: clubNameController.text,
                        inviteLink: "https://bookclubs.com/clubs/6049649/join/363631/",
                      ),
                    ),
                  );
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
