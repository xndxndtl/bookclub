// lib/screens/my_clubs_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'club_management_screen.dart';
import '../services/club_service.dart';  // 추가된 import

class MyClubsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ClubService _clubService = ClubService();  // ClubService 인스턴스 생성

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

              final Map<String, dynamic>? clubData = club.data() as Map<String, dynamic>?;

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
            await _clubService.createNewClub(context);  // ClubService 사용
          },
          icon: Icon(Icons.add),
          label: Text("Create a new club"),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
