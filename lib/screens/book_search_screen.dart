import 'package:flutter/material.dart';

class BookSearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Books"),
      ),
      body: Center(
        child: Text("Book Search Results Here"),
      ),
    );
  }
}
