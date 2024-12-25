import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddDiscussionQuestionScreen extends StatefulWidget {
  final String clubId;

  AddDiscussionQuestionScreen({required this.clubId});

  @override
  _AddDiscussionQuestionScreenState createState() =>
      _AddDiscussionQuestionScreenState();
}

class _AddDiscussionQuestionScreenState
    extends State<AddDiscussionQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  List<String> discussionQuestions = [''];
  bool _isSaving = false;

  void _addParagraph() {
    setState(() {
      discussionQuestions.add('');
    });
  }

  void _removeParagraph(int index) {
    setState(() {
      if (discussionQuestions.length > 1) {
        discussionQuestions.removeAt(index);
      }
    });
  }
  // 도서 검색 함수
  Future<List<Map<String, dynamic>>> _searchBooks(String query) async {
    final url =
        'https://dapi.kakao.com/v3/search/book?target=title&query=$query';
    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "KakaoAK bbe5732d7be1c934639116216a1a4ff4"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['documents']);
    } else {
      throw Exception('Failed to fetch books');
    }
  }

  // 도서 검색 팝업
  void _showBookSearchPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return BookSearchScreen(
          onBookSelected: (bookTitle, author) {
            setState(() {
              _bookTitleController.text = bookTitle;
              _authorController.text = author;
            });
            Navigator.pop(context); // 팝업 닫기
          },
        );
      },
    );
  }

  Future<void> _saveDiscussionQuestion() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSaving = true;
      });

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      try {
        await FirebaseFirestore.instance
            .collection('clubs')
            .doc(widget.clubId)
            .collection('discussionQuestions')
            .add({
          'bookTitle': _bookTitleController.text,
          'author': _authorController.text,
          'discussionQuestions': discussionQuestions,
          'createdAt': Timestamp.now(),
          'createdBy': userId,
          'hasDiscussed': false,
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
        title: Text(
          'Add Discussion Question',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Book 버튼
              ElevatedButton(
                onPressed: _showBookSearchPopup,
                child: Text('Add Book'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
              SizedBox(height: 16),
              // 책 제목 입력
              TextFormField(
                controller: _bookTitleController,
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
              ),
              SizedBox(height: 16),
              // 작가 입력
              TextFormField(
                controller: _authorController,
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
              ),
              SizedBox(height: 16),
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

// 도서 검색 화면
class BookSearchScreen extends StatefulWidget {
  final Function(String, String) onBookSelected;

  BookSearchScreen({required this.onBookSelected});

  @override
  _BookSearchScreenState createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _books = [];
  bool _isLoading = false;

  void _searchBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _AddDiscussionQuestionScreenState()._searchBooks(
        _searchController.text,
      );
      setState(() {
        _books = results;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search books...',
              hintStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _searchBooks,
            child: Text('Search'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          SizedBox(height: 16),
          _isLoading
              ? CircularProgressIndicator()
              : Expanded(
            child: ListView.builder(
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return ListTile(
                  title: Text(
                    book['title'],
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    book['authors'].join(', '),
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    widget.onBookSelected(
                        book['title'], book['authors'].join(', '));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
