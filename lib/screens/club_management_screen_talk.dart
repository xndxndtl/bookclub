import 'package:flutter/material.dart';

class MessagesTab extends StatelessWidget {
  final String clubId;

  MessagesTab({required this.clubId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message, size: 100, color: Colors.green),
          SizedBox(height: 16),
          Text(
            "Your club doesn't have any messages.",
            style: TextStyle(color: Colors.white70),
          ),
          Text(
            "Create one now!",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Post a new message 기능
            },
            child: Text("POST A NEW MESSAGE"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
