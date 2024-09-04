import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventCalendarScreen extends StatefulWidget {
  final String clubId;

  EventCalendarScreen({required this.clubId});

  @override
  _EventCalendarScreenState createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  Future<void> _addEvent(BuildContext context) async {
    String title = '';
    String description = '';
    String location = '';
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Event'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Title'),
                  onChanged: (value) {
                    title = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onChanged: (value) {
                    description = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Location'),
                  onChanged: (value) {
                    location = value;
                  },
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 10),
                      Text(selectedDate == null
                          ? 'Select Date'
                          : DateFormat.yMMMd().format(selectedDate!)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add Event'),
              onPressed: () async {
                if (title.isNotEmpty && selectedDate != null) {
                  // Firestore에 이벤트 저장
                  await FirebaseFirestore.instance
                      .collection('clubs')
                      .doc(widget.clubId)
                      .collection('events')
                      .add({
                    'title': title,
                    'description': description,
                    'date': Timestamp.fromDate(selectedDate!),
                    'location': location,
                    'createdBy': FirebaseAuth.instance.currentUser?.uid,
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Calendar'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clubs')
            .doc(widget.clubId)
            .collection('events')
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final eventDate = event['date'].toDate();
              return ListTile(
                title: Text(event['title']),
                subtitle: Text(
                    '${DateFormat.yMMMd().format(eventDate)} - ${event['location']}'),
                onTap: () {
                  // 이벤트 상세보기 기능 구현 가능
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEvent(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
