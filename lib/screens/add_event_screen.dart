import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEventScreen extends StatefulWidget {
  final String clubId;

  AddEventScreen({required this.clubId});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _eventName;
  String? _eventDescription;
  String? _eventLocation;
  DateTime? _eventDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Event Name'),
                onSaved: (value) {
                  _eventName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) {
                  _eventDescription = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                onSaved: (value) {
                  _eventLocation = value;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  setState(() {
                    _eventDate = selectedDate;
                  });
                },
                child: Text(
                  _eventDate == null
                      ? 'Select Date'
                      : 'Selected Date: ${_eventDate!.toLocal()}'.split(' ')[0],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _addEventToFirestore();
                    Navigator.pop(context);
                  }
                },
                child: Text('Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addEventToFirestore() async {
    if (_eventName != null && _eventDate != null) {
      await FirebaseFirestore.instance
          .collection('clubs')
          .doc(widget.clubId)
          .collection('events')
          .add({
        'eventName': _eventName,
        'description': _eventDescription,
        'location': _eventLocation,
        'eventDate': _eventDate,
      });
    }
  }
}
