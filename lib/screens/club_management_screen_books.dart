import 'package:flutter/material.dart';

class BooksTab extends StatelessWidget {
  final String clubId;

  BooksTab({required this.clubId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Currently reading",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            "Your club is not currently reading any books",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Add a book 기능
              },
              child: Text("Add a book"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ),
          Divider(height: 32, color: Colors.white70),
          Text(
            "Books we've read",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            "Your club hasn’t read any books",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Add a book 기능
              },
              child: Text("Add a book"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ),
          Divider(height: 32, color: Colors.white70),
          Text(
            "Books we want to read",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            "Your club doesn't have any Books We Want to Read",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Add a book 기능
              },
              child: Text("Add a book"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
