import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookclub.app/screens/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage 패키지 추가

class NicknameScreen extends StatefulWidget {
  @override
  _NicknameScreenState createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isSaving = false;
  File? _profileImage; // 선택된 프로필 이미지 파일

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path); // 이미지 파일 저장
      });
    }
  }

  // 프로필 이미지 업로드 함수
  Future<String?> _uploadProfileImage(String userId) async {
    if (_profileImage != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(_profileImage!);
        final downloadUrl = await storageRef.getDownloadURL();
        return downloadUrl; // 업로드한 이미지의 URL 반환
      } catch (e) {
        print('Error uploading profile image: $e');
        return null; // 오류 발생 시 null 반환
      }
    }
    return null; // 이미지가 없으면 null 반환
  }

  // 닉네임, 위치, 프로필 이미지 URL, 가입 날짜를 Firestore에 저장하는 함수
  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    String nickname = _nicknameController.text.trim();
    String location = _locationController.text.trim();
    String userId = FirebaseAuth.instance.currentUser!.uid;

    if (nickname.isNotEmpty && location.isNotEmpty) {
      // 이미지 업로드 후 URL 저장
      String? profileImageUrl = await _uploadProfileImage(userId);

      // 현재 시간으로 가입 날짜 설정
      DateTime joinDate = DateTime.now();

      // Firestore에 닉네임, 위치, 프로필 이미지 URL, 가입 날짜 저장
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'nickname': nickname,
        'location': location,
        'profileImageUrl': profileImageUrl, // 업로드된 이미지 URL 저장
        'joinedDate': joinDate, // 가입 날짜 저장
      });

      // 저장 후 메인 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'BookClub',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 프로필 이미지 영역
            CircleAvatar(
              radius: 60,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : const AssetImage('assets/images/default_profile.png')
              as ImageProvider, // 기본 이미지 사용
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 30),
            // 닉네임 입력 필드
            TextField(
              controller: _nicknameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nickname',
                labelStyle: const TextStyle(color: Colors.white),
                hintText: 'Enter your nickname',
                hintStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.green),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 주소 입력 필드
            TextField(
              controller: _locationController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Location',
                labelStyle: const TextStyle(color: Colors.white),
                hintText: 'Enter your location',
                hintStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.green),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // 저장 버튼
            _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Save Profile',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
