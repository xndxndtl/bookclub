import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'members_screen.dart';
import 'event_calendar_screen.dart';  // 캘린더 화면 import 추가

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
          title: Text(widget.clubName),
          bottom: TabBar(
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(text: 'About'),
              Tab(text: 'Books'),
              Tab(text: 'Meetings'),
              Tab(text: 'Messages'),
              Tab(text: 'Polls'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAboutTab(context),
            _buildBooksTab(context),
            _buildMeetingsTab(context),
            _buildMessagesTab(context),
            _buildPollsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 클럽 대표 이미지 및 업로드 버튼
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    image: _uploadedImageUrl != null
                        ? DecorationImage(
                      image: NetworkImage(_uploadedImageUrl!),
                      fit: BoxFit.cover,
                    )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.groups, size: 40, color: Colors.orange),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.camera_alt, color: Colors.black),
                        ),
                        SizedBox(width: 8),
                        Text('Upload', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 클럽 이름 및 멤버 수
            Text(
              widget.clubName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 8),
            Text('${widget.memberCount} member${widget.memberCount > 1 ? 's' : ''}', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            // 프리미엄 업그레이드 및 편집 버튼
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // 클럽 정보 수정 기능
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Edit club'),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    // 설정 화면으로 이동
                  },
                  icon: Icon(Icons.settings),
                ),
              ],
            ),
            Divider(),
            // 멤버, 사진, 문서 관리 섹션
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Members'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MembersScreen(clubId: widget.clubId),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Photos'),
              trailing: Text('Premium feature', style: TextStyle(color: Colors.grey)),
              onTap: () {
                // 프리미엄 기능 안내
              },
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text('Documents'),
              trailing: Text('Premium feature', style: TextStyle(color: Colors.grey)),
              onTap: () {
                // 프리미엄 기능 안내
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Currently reading", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          Text("Your club is not currently reading any books", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Add a book 기능
              },
              child: Text("Add a book"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ),
          Divider(height: 32),
          Text("Books we've read", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          Text("Your club hasn’t read any books", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Add a book 기능
              },
              child: Text("Add a book"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ),
          Divider(height: 32),
          Text("Books we want to read", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          Text("Your club doesn't have any Books We Want to Read", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Add a book 기능
              },
              child: Text("Add a book"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingsTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm, size: 100, color: Colors.brown),
          SizedBox(height: 16),
          Text("Your club doesn't have any upcoming meetings", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // 캘린더 화면으로 이동하도록 수정
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventCalendarScreen(clubId: widget.clubId),
                ),
              );
            },
            child: Text("VIEW CALENDAR"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message, size: 100, color: Colors.brown),
          SizedBox(height: 16),
          Text("Your club doesn't have any messages.", style: TextStyle(color: Colors.grey)),
          Text("Create one now!", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Post a new message 기능
            },
            child: Text("POST A NEW MESSAGE"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollsTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.poll, size: 100, color: Colors.brown),
          SizedBox(height: 16),
          Text("Your club doesn't have upcoming polls", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Create a new poll 기능
            },
            child: Text("CREATE A NEW POLL"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// 멤버 목록 화면
class MembersScreen extends StatelessWidget {
  final String clubId;

  MembersScreen({required this.clubId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('clubs').doc(clubId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('No members found'));
          }
          List<dynamic> members = snapshot.data!['members'];
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(members[index]),
                  trailing: Icon(Icons.more_vert),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
