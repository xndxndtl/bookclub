import 'package:flutter/material.dart';

class TopicSearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('발제문 검색'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          'Topic Search Screen',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

