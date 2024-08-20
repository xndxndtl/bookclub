// lib/screens/create_event_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';

class CreateEventScreen extends StatefulWidget {
  final String clubId;

  CreateEventScreen({required this.clubId});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  Future<void> _createEvent() async {
    try {
      EventModel newEvent = EventModel(
        id: '', // ID는 Firestore에서 자동 생성되므로 비워 둡니다.
        clubId: widget.clubId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        dateTime: _selectedDateTime,
        location: _locationController.text.trim(),
        createdBy: FirebaseAuth.instance.currentUser!.uid,
        attendees: [],
      );

      await FirebaseFirestore.instance.collection('events').add(newEvent.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event created successfully!')),
      );

      Navigator.pop(context); // 이벤트 생성 후 이전 화면으로 이동
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event. Please try again.')),
      );
    }
  }
  /*
  Future<void> _createEvent() async {
    try {
      await FirebaseFirestore.instance.collection('events').add({
        'clubId': widget.clubId,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'dateTime': _selectedDateTime,
        'location': _locationController.text.trim(),
        'createdBy': FirebaseAuth.instance.currentUser?.uid,
        'attendees': [],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event created successfully!')),
      );

      Navigator.pop(context); // 이벤트 생성 후 이전 화면으로 이동
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event. Please try again.')),
      );
    }
  }

   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Event Description'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Event Location'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text("Date & Time: ${_selectedDateTime.toLocal()}"),
                Spacer(),
                TextButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDateTime,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Text('Select Date & Time'),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createEvent,
              child: Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}
