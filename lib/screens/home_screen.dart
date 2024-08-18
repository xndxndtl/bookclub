// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_clubs_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreenContent(),
    MyClubsScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // 알림 기능 추가
            },
          ),
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              // 메시지 기능 추가
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,  // 모든 아이템이 항상 표시되도록 설정
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'My Clubs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upcoming events section
          Text(
            "Upcoming events",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // 일정 예약 기능 추가
            },
            child: Text("Schedule your next meeting"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.grey),
            ),
          ),
          SizedBox(height: 24),

          // Browse and Create Club section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.search,
                  label: "Browse public clubs",
                  onTap: () {
                    // 클럽 검색 기능 추가
                  },
                ),
              ),
              SizedBox(width: 16),  // 간격 추가
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.add,
                  label: "Create a new club",
                  onTap: () {
                    _createNewClub(context);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 36, color: Colors.orange),
              SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 16, color: Colors.orange)),
            ],
          ),
        ),
      ),
    );
  }

  // 클럽 생성 로직
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
                  // 클럽 생성 후 성공 화면으로 이동
                  await FirebaseFirestore.instance.collection('clubs').add({
                    'name': clubNameController.text,
                    'description': clubDescriptionController.text,
                    'createdBy': FirebaseAuth.instance.currentUser?.uid,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyClubsScreen()),
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
