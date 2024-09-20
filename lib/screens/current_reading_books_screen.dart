import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CurrentlyReadingBooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildReadingBooksSection();
  }

  // 읽고 있는 책 정보 섹션
  Widget _buildReadingBooksSection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          // 사용자가 읽고 있는 책 정보가 있을 경우
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final currentBook = userData['currentBook'] ?? '읽고 있는 책이 없습니다.';
          final author = userData['author'] ?? '';

          return Card(
            color: Colors.grey[850],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    /*child: Image.asset(
                      'assets/images/book_image.png', // 책 이미지 로컬 경로
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),*/
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentBook,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          author,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: Text(
              '현재 읽고 있는 책이 없습니다.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
      },
    );
  }
}
