import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'add_discussion_question_screen.dart'; // 발제문 추가 화면 import


class MessagesTab extends StatelessWidget {
  final String clubId;

  MessagesTab({required this.clubId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clubs')
            .doc(clubId)
            .collection('discussionQuestions')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message, size: 100, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    "Your club doesn't have any discussion questions.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "Create one now!",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          final discussionQuestions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: discussionQuestions.length,
            itemBuilder: (context, index) {
              final discussionQuestion = discussionQuestions[index];

              // Firestore에서 데이터를 가져와 Map<String, dynamic>으로 캐스팅
              final data = discussionQuestion.data() as Map<String, dynamic>;

              final bookTitle = data['bookTitle'];
              final createdAt = (data['createdAt'] as Timestamp).toDate();
              final createdBy = data['createdBy'];

              // hasDiscussed 필드가 없는 경우 기본값 false 사용
              final hasDiscussed = data.containsKey('hasDiscussed') ? data['hasDiscussed'] : false;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(createdBy).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text(
                        bookTitle,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Loading...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final nickname = userSnapshot.data!['nickname'] ?? 'Anonymous';

                  return Card(
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: ListTile(
                      title: Text(
                        bookTitle,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Created by: $nickname\n${DateFormat('yyyy-MM-dd – kk:mm').format(createdAt)}',
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: Checkbox(
                        value: hasDiscussed,
                        onChanged: (bool? value) {
                          FirebaseFirestore.instance
                              .collection('clubs')
                              .doc(clubId)
                              .collection('discussionQuestions')
                              .doc(discussionQuestion.id)
                              .update({'hasDiscussed': value});
                        },
                        activeColor: Colors.green,
                        checkColor: Colors.black,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiscussionDetailScreen(
                              bookTitle: bookTitle,
                              author: data['author'],
                              discussionQuestions: data['discussionQuestions'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDiscussionQuestionScreen(clubId: clubId),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class DiscussionDetailScreen extends StatelessWidget {
  final String bookTitle;
  final String author;
  final List<dynamic> discussionQuestions;

  DiscussionDetailScreen({
    required this.bookTitle,
    required this.author,
    required this.discussionQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Discussion Details', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 책 제목
              Text(
                bookTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              // 작가 이름
              Text(
                'Author: $author',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Divider(color: Colors.greenAccent),
              // 토론 질문지
              ...discussionQuestions.map((question) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    question,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
