import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MembersScreen extends StatelessWidget {
  final String clubId;

  MembersScreen({required this.clubId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Members"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('members').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No members found."));
          }
          final members = snapshot.data!.docs;
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(member['name']),
                  subtitle: Text(member['email']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
