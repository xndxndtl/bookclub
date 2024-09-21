import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String name;
  final String description;
  final String bookTitle;
  final String author;
  final DateTime dateTime; // Start date and time
  final DateTime? endDateTime; // Optional end date and time
  final String notes;
  final List<String> attendees; // List of user IDs who are attending
  final String clubId;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.bookTitle,
    required this.author,
    required this.dateTime,
    this.endDateTime,
    required this.notes,
    required this.attendees,
    required this.clubId,
  });

  // Firestore Document를 EventModel로 변환
  factory EventModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      name: data['title'] ?? '', // Firestore 필드 이름에 맞게 변경
      description: data['description'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      author: data['author'] ?? '',
      dateTime: (data['date'] as Timestamp).toDate(),
      endDateTime: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      notes: data['notes'] ?? '',
      attendees: List<String>.from(data['attendees'] ?? []), // 참석자 목록
      clubId: data['clubId'] ?? '',
    );
  }
}
