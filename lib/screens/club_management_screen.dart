// lib/screens/club_management_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_member_screen.dart';
import 'club_events_screen.dart';

class ClubManagementScreen extends StatelessWidget {
  final String clubId;
  final String clubName;
  final String clubDescription;

  ClubManagementScreen({
    required this.clubId,
    required this.clubName,
    required this.clubDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage $clubName'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // 클럽 정보 섹션
          ListTile(
            title: Text("Club Information"),
            subtitle: Text("Edit club name and description"),
            leading: Icon(Icons.info),
            onTap: () {
              // 클럽 정보 수정 기능 추가
            },
          ),
          Divider(),

          // 멤버 관리 섹션
          ListTile(
            title: Text("Members"),
            subtitle: Text("View and manage club members"),
            leading: Icon(Icons.group),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMemberScreen(clubId: clubId),
                ),
              );
            },
          ),
          Divider(),

          // 이벤트 관리 섹션
          ListTile(
            title: Text("Events"),
            subtitle: Text("Manage club events"),
            leading: Icon(Icons.event),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClubEventsScreen(clubId: clubId),
                ),
              );
            },
          ),
          Divider(),

          // 공지사항 섹션
          ListTile(
            title: Text("Announcements"),
            subtitle: Text("Post and view announcements"),
            leading: Icon(Icons.announcement),
            onTap: () {
              // 공지사항 기능 추가
            },
          ),
          Divider(),

          // 클럽 탈퇴/해산 섹션
          ListTile(
            title: Text("Leave or Disband Club"),
            subtitle: Text("Leave or delete the club"),
            leading: Icon(Icons.exit_to_app),
            onTap: () {
              // 클럽 탈퇴 또는 해산 기능 추가
            },
          ),
        ],
      ),
    );
  }
}
