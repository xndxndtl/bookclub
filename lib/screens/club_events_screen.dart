// lib/screens/club_events_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import 'create_event_screen.dart';

class ClubEventsScreen extends StatelessWidget {
  final String clubId;

  ClubEventsScreen({required this.clubId});

  // Firestore에서 이벤트 목록을 가져와 EventModel 인스턴스로 변환하는 함수
  Stream<List<EventModel>> getClubEvents(String clubId) {
    return FirebaseFirestore.instance
        .collection('events')
        .where('clubId', isEqualTo: clubId)
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => EventModel.fromDocument(doc)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateEventScreen(clubId: clubId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: getClubEvents(clubId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events found.'));
          }
          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event.name),
                subtitle: Text(event.description),
                trailing: TextButton(
                  onPressed: () {
                    // RSVP 기능 또는 이벤트 상세 화면으로 이동
                  },
                  child: Text('View Details'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
