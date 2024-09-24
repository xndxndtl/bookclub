import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isEditingNickname = false;
  bool _isEditingLocation = false;
  bool _isEditingBio = false;
  String? _nickname;
  String? _location;
  String? _bio;
  DateTime? _joinedDate;
  File? _profileImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // 현재 로그인된 사용자의 프로필 정보를 불러오는 함수
  Future<void> _loadProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _nickname = userDoc['nickname'];
          _location = userDoc['location'];
          _bio = userDoc['bio'];
          _profileImageUrl = userDoc['profileImageUrl']; // Firestore에서 저장된 이미지 URL 불러오기
          _joinedDate = (userDoc['joinedDate'] as Timestamp).toDate();
          _nicknameController.text = _nickname!;
          _locationController.text = _location ?? '';
          _bioController.text = _bio ?? '';
        });
      }
    }
  }

  // 프로필 정보 업데이트 함수
  Future<void> _updateProfileField(String field, String value) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        field: value,
      });
      setState(() {
        switch (field) {
          case 'nickname':
            _nickname = value;
            _isEditingNickname = false;
            break;
          case 'location':
            _location = value;
            _isEditingLocation = false;
            break;
          case 'bio':
            _bio = value;
            _isEditingBio = false;
            break;
        }
      });
    }
  }

  // 프로필 이미지 선택 및 업로드 함수
  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      await _uploadProfileImage();
    }
  }

  // 프로필 이미지를 Firebase Storage에 업로드하고, URL을 Firestore에 저장하는 함수
  Future<void> _uploadProfileImage() async {
    User? user = _auth.currentUser;
    if (user != null && _profileImage != null) {
      try {
        // Firebase Storage에 이미지 업로드
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(_profileImage!);
        final downloadUrl = await storageRef.getDownloadURL();

        // Firestore에 다운로드 URL 저장
        await _firestore.collection('users').doc(user.uid).update({
          'profileImageUrl': downloadUrl,
        });

        setState(() {
          _profileImageUrl = downloadUrl;
        });
      } catch (e) {
        print('Error uploading profile image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Profile', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 가입일 표시
            if (_joinedDate != null)
              Center(
                child: Text(
                  'Joined on: ${DateFormat('yyyy-MM-dd').format(_joinedDate!)}',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            SizedBox(height: 24),
            // 프로필 이미지 표시
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!) as ImageProvider
                        : AssetImage('assets/images/default_profile.png'),
                    backgroundColor: Colors.grey[800],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.camera_alt, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // 닉네임 수정 필드
            _buildEditableField(
              controller: _nicknameController,
              label: 'Nickname',
              isEditing: _isEditingNickname,
              onSave: () => _updateProfileField('nickname', _nicknameController.text),
              onEdit: () {
                setState(() {
                  _isEditingNickname = true;
                });
              },
              onCancel: () {
                setState(() {
                  _isEditingNickname = false;
                });
                _nicknameController.text = _nickname ?? '';
              },
            ),
            SizedBox(height: 16),
            // 지역 수정 필드
            _buildEditableField(
              controller: _locationController,
              label: 'Location',
              isEditing: _isEditingLocation,
              onSave: () => _updateProfileField('location', _locationController.text),
              onEdit: () {
                setState(() {
                  _isEditingLocation = true;
                });
              },
              onCancel: () {
                setState(() {
                  _isEditingLocation = false;
                });
                _locationController.text = _location ?? '';
              },
            ),
            SizedBox(height: 16),
            // 소개글 수정 필드
            _buildEditableField(
              controller: _bioController,
              label: 'Bio',
              isEditing: _isEditingBio,
              maxLines: 4,
              onSave: () => _updateProfileField('bio', _bioController.text),
              onEdit: () {
                setState(() {
                  _isEditingBio = true;
                });
              },
              onCancel: () {
                setState(() {
                  _isEditingBio = false;
                });
                _bioController.text = _bio ?? '';
              },
            ),
          ],
        ),
      ),
    );
  }

  // 수정 가능한 필드 빌더 함수
  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required bool isEditing,
    required VoidCallback onSave,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        if (isEditing)
          Column(
            children: [
              TextField(
                controller: controller,
                maxLines: maxLines,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  labelStyle: TextStyle(color: Colors.green),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onCancel,
                    child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: onSave,
                    child: Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  controller.text.isEmpty ? 'No $label added' : controller.text,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit, color: Colors.green),
              ),
            ],
          ),
      ],
    );
  }
}
