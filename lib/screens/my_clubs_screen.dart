import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'club_management_screen.dart';

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
            padding: EdgeInsets.all(16.0),
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];

              // DocumentSnapshot의 데이터를 Map으로 캐스팅
              final Map<String, dynamic>? clubData = club.data() as Map<String, dynamic>?;

              // members 필드가 존재하는지 확인
              final List<dynamic> members = clubData != null && clubData.containsKey('members')
                  ? (clubData['members'] as List<dynamic>)
                  : [];

              return Card(
                margin: EdgeInsets.only(bottom: 16.0),
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  leading: Icon(Icons.groups, size: 48, color: Colors.orange),
                  title: Text(
                    clubData?['name'] ?? 'Unnamed Club',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(Icons.person, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "${members.length} Member${members.length > 1 ? 's' : ''}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  onTap: () {
                    // 클럽 관리 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClubManagementScreen(
                          clubId: club.id,
                          clubName: clubData?['name'] ?? 'Unnamed Club',
                          clubDescription: clubData?['description'] ?? '',
                          memberCount: members.length,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () async {
            await _createNewClub(context);
          },
          icon: Icon(Icons.add),
          label: Text("Create a new club"),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            backgroundColor: Colors.orange,  // primary 대신 backgroundColor 사용
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
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
                  // 클럽 생성 시 members 필드를 함께 추가
                  await FirebaseFirestore.instance.collection('clubs').add({
                    'name': clubNameController.text,
                    'description': clubDescriptionController.text,
                    'createdBy': FirebaseAuth.instance.currentUser?.uid,
                    'createdAt': FieldValue.serverTimestamp(),
                    'members': [FirebaseAuth.instance.currentUser?.uid], // members 필드 추가
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
