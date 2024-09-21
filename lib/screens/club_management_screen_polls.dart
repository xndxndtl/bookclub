import 'package:flutter/material.dart';

class PollsTab extends StatelessWidget {
  final String clubId;

  PollsTab({required this.clubId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.poll, size: 100, color: Colors.green),
          SizedBox(height: 16),
          Text(
            "Your club doesn't have upcoming polls",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Create a new poll 기능
            },
            child: Text("CREATE A NEW POLL"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
