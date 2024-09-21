import 'package:flutter/material.dart';
import 'my_clubs_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../services/upcoming_events_screen.dart'; // UpcomingEventsScreen 임포트
import 'current_reading_books_screen.dart'; // CurrentlyReadingBooksScreen 임포트
import 'topic_search_screen.dart'; // TopicSearchScreen 임포트

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreenContent(),
    MyClubsScreen(),
    TopicSearchScreen(), // '발제문' 메뉴에서 호출될 화면
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
        backgroundColor: Colors.black,
        title: Text(
          "BookClub",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            // backgroundImage: AssetImage('assets/images/profile_image.png'), // 프로필 이미지 경로 설정
            radius: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // 알림 기능 추가
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: '북클럽',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '발제문',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내 정보',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
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
          // Upcoming Events Section
          const Text(
            'Upcoming Events',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          UpcomingEventsScreen(), // 별도 파일로 분리된 UpcomingEventsScreen 사용

          const SizedBox(height: 32),
          // Currently Reading Books Section
          const Text(
            '현재 읽고 있는 책',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CurrentlyReadingBooksScreen(), // 별도 파일로 분리된 CurrentlyReadingBooksScreen 사용
        ],
      ),
    );
  }
}
