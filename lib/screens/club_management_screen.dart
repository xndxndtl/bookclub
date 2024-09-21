import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'club_management_screen_about.dart'; // About Tab import
import 'club_management_screen_books.dart'; // Books Tab import
import 'club_management_screen_meeting.dart'; // Meetings Tab import
import 'club_management_screen_talk.dart'; // Messages Tab import
import 'club_management_screen_polls.dart'; // Polls Tab import

class ClubManagementScreen extends StatefulWidget {
  final String clubId;
  final String clubName;
  final String clubDescription;
  final int memberCount;

  ClubManagementScreen({
    required this.clubId,
    required this.clubName,
    required this.clubDescription,
    required this.memberCount,
  });

  @override
  _ClubManagementScreenState createState() => _ClubManagementScreenState();
}

class _ClubManagementScreenState extends State<ClubManagementScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _uploadedImageUrl;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Firebase Storage에 이미지 업로드
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('club_images/${widget.clubId}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        // Firestore에 이미지 URL 저장
        await FirebaseFirestore.instance
            .collection('clubs')
            .doc(widget.clubId)
            .update({'backgroundImage': imageUrl});

        setState(() {
          _uploadedImageUrl = imageUrl;
        });
      } catch (e) {
        print('Image upload failed: $e');
      }
    }
  }

  String? currentUserRole;

  @override
  void initState() {
    super.initState();
    _getCurrentUserRole();
  }

  // 현재 사용자의 역할 가져오기
  void _getCurrentUserRole() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot clubSnapshot = await FirebaseFirestore.instance
        .collection('clubs')
        .doc(widget.clubId)
        .get();

    Map<String, dynamic> members = clubSnapshot['members'];
    setState(() {
      currentUserRole = members[userId]['role']; // 역할 저장
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // 탭 개수
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            widget.clubName,
            style: TextStyle(color: Colors.white),
          ),
          bottom: TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.green,
            tabs: [
              Tab(text: 'About'),
              Tab(text: 'Books'),
              Tab(text: 'Meet'),
              Tab(text: 'Talk'),
              Tab(text: 'Polls'),
            ],
          ),
        ),
        backgroundColor: Colors.black, // 화면 배경색 설정
        body: TabBarView(
          children: [
            AboutTab(
              clubId: widget.clubId,
              clubName: widget.clubName,
              clubDescription: widget.clubDescription,
              memberCount: widget.memberCount,
              pickImage: _pickImage,
              uploadedImageUrl: _uploadedImageUrl,
            ),
            BooksTab(clubId: widget.clubId),
            MeetingsTab(clubId: widget.clubId),
            MessagesTab(clubId: widget.clubId),
            PollsTab(clubId: widget.clubId),
          ],
        ),
      ),
    );
  }
}
