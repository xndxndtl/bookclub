// lib/screens/club_creation_success_screen.dart

import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class ClubCreationSuccessScreen extends StatelessWidget {
  final String clubName;
  final String inviteLink;

  ClubCreationSuccessScreen({required this.clubName, required this.inviteLink});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create new club"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Icon(Icons.check_circle_outline, color: Colors.black, size: 100),
            SizedBox(height: 20),
            Text(
              "CREATED A NEW CLUB SUCCESSFULLY!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: "My Club: ",
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(
                    text: clubName,
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            CommonWidgets.buildSectionTitle("Send email invitation"),
            TextField(
              decoration: InputDecoration(
                hintText: "Add email(s) addresses",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // 이메일 초대 로직
              },
              child: Text("Send"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // 비활성화된 색상
              ),
            ),
            SizedBox(height: 30),
            CommonWidgets.buildSectionTitle("Send text invitation"),
            ElevatedButton(
              onPressed: () {
                // 문자 초대 로직
              },
              child: Text("Send"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
            SizedBox(height: 30),
            CommonWidgets.buildSectionTitle("Invite link"),
            GestureDetector(
              onTap: () {
                // 초대 링크 복사 로직
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(inviteLink)),
                    Icon(Icons.copy, color: Colors.orange),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Copy/paste to send friends this link to invite them to your club",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            CommonWidgets.buildSectionTitle("Pending invitations"),
            Text(
              "No pending invitation yet",
              style: TextStyle(color: Colors.grey),
            ),
            Spacer(),
            OutlinedButton(
              onPressed: () {
                // 클럽 설정 완료 후 진행할 로직
              },
              child: Text("Continue setting up my club"),
            ),
          ],
        ),
      ),
    );
  }
}
