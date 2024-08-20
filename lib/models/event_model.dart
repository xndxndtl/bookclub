// lib/models/event_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String id;
  String clubId;
  String name;
  String description;
  DateTime dateTime;
  String location;
  String createdBy;
  List<String> attendees;

  EventModel({
    required this.id,
    required this.clubId,
    required this.name,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.createdBy,
    required this.attendees,
  });

  // Firestore 문서 데이터를 EventModel 인스턴스로 변환
  factory EventModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      clubId: data['clubId'],
      name: data['name'],
      description: data['description'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      location: data['location'],
      createdBy: data['createdBy'],
      attendees: List<String>.from(data['attendees'] ?? []),
    );
  }

  // EventModel 인스턴스를 Firestore 문서로 변환
  Map<String, dynamic> toMap() {
    return {
      'clubId': clubId,
      'name': name,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'location': location,
      'createdBy': createdBy,
      'attendees': attendees,
    };
  }
}
