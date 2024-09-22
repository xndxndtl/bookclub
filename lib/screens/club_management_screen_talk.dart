import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
              builder: (context) => DiscussionQuestionForm(clubId: clubId),
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

class DiscussionQuestionForm extends StatefulWidget {
  final String clubId;

  DiscussionQuestionForm({required this.clubId});

  @override
  _DiscussionQuestionFormState createState() => _DiscussionQuestionFormState();
}

class _DiscussionQuestionFormState extends State<DiscussionQuestionForm> {
  final _formKey = GlobalKey<FormState>();
  String bookTitle = '';
  String author = '';
  List<String> discussionQuestions = [''];
  bool _isSaving = false; // 저장 중 상태 확인을 위한 변수

  // 질문지 문단 추가
  void _addParagraph() {
    setState(() {
      discussionQuestions.add('');
    });
  }

  // 질문지 문단 삭제
  void _removeParagraph(int index) {
    setState(() {
      if (discussionQuestions.length > 1) {
        discussionQuestions.removeAt(index);
      }
    });
  }

  // 토론 질문지 저장
  Future<void> _saveDiscussionQuestion() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSaving = true;
      });

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final nickname = userDoc['nickname'] ?? 'Anonymous';

      try {
        // Firestore에 저장
        await FirebaseFirestore.instance
            .collection('clubs')
            .doc(widget.clubId)
            .collection('discussionQuestions')
            .add({
          'bookTitle': bookTitle,
          'author': author,
          'discussionQuestions': discussionQuestions,
          'createdAt': Timestamp.now(),
          'createdBy': userId,
          'createdByNickname': nickname,
          'hasDiscussed': false, // 초기값으로 토론 여부를 false로 설정
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Discussion question saved!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save discussion question.')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Add Discussion Question', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 책 제목 입력
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Book Title',
                  labelStyle: TextStyle(color: Colors.green),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the book title';
                  }
                  return null;
                },
                onSaved: (value) {
                  bookTitle = value ?? '';
                },
              ),
              SizedBox(height: 16),
              // 작가 입력
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Author',
                  labelStyle: TextStyle(color: Colors.green),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the author';
                  }
                  return null;
                },
                onSaved: (value) {
                  author = value ?? '';
                },
              ),
              SizedBox(height: 16),
              // 토론 질문지 입력
              Text(
                'Discussion Questions:',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: discussionQuestions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: discussionQuestions[index],
                            maxLines: null,
                            decoration: InputDecoration(
                              labelText: 'Paragraph ${index + 1}',
                              labelStyle: TextStyle(color: Colors.green),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            onChanged: (value) {
                              discussionQuestions[index] = value;
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeParagraph(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              // 문단 추가 버튼
              Center(
                child: ElevatedButton(
                  onPressed: _addParagraph,
                  child: Text('Add Paragraph'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    textStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 32),
              // 저장 버튼
              Center(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveDiscussionQuestion,
                  child: _isSaving
                      ? CircularProgressIndicator(color: Colors.black)
                      : Text('Save Discussion Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    textStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
