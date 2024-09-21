import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위한 패키지
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookclub.app/services/event_model.dart'; // EventModel import

class MeetingsTab extends StatelessWidget {
  final String clubId;

  MeetingsTab({required this.clubId});

  // Firestore에서 클럽의 이벤트 목록을 가져오는 함수
  Stream<List<EventModel>> getClubEvents(String clubId) {
    return FirebaseFirestore.instance
        .collection('clubs') // 'clubs' 컬렉션에서
        .doc(clubId) // 해당 클럽 문서의
        .collection('events') // 'events' 서브컬렉션 접근
        .orderBy('date') // 날짜순 정렬
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        print('Event Data: ${doc.data()}'); // 로그 출력
        return EventModel.fromDocument(doc);
      }).toList();
    });
  }

  // 사용자 참석 여부 업데이트 함수
  Future<void> _toggleAttendance(String eventId, bool isAttending) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference eventRef = FirebaseFirestore.instance
        .collection('clubs')
        .doc(clubId)
        .collection('events')
        .doc(eventId);

    if (isAttending) {
      await eventRef.update({
        'attendees': FieldValue.arrayUnion([userId])
      });
    } else {
      await eventRef.update({
        'attendees': FieldValue.arrayRemove([userId])
      });
    }
  }

  // 이벤트 상세 정보 다이얼로그
  void _showEventDetails(BuildContext context, EventModel event) async {
    List<String> attendeeNicknames = [];

    try {
      if (event.attendees.isNotEmpty) {
        // 참석자가 있을 때만 Firestore에서 사용자 정보 가져오기
        final attendeeSnapshots = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: event.attendees)
            .get();

        // 참석자 정보가 있을 경우 닉네임 리스트 생성
        attendeeNicknames = attendeeSnapshots.docs
            .map((doc) => doc.data()['nickname'] as String? ?? 'No nickname')
            .toList();
      }
    } catch (e) {
      print('Error fetching attendees: $e');
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.greenAccent.shade100, width: 1), // 테두리 설정
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 부분
                  Center(
                    child: Column(
                      children: [
                        Text(
                          event.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'by ${event.author}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.greenAccent.shade100), // 구분선 추가
                  SizedBox(height: 16),
                  _buildEventDetailRow('Book Title', event.bookTitle),
                  _buildEventDetailRow('Title', event.name),
                  _buildEventDetailRow('Description', event.description),
                  _buildEventDetailRow(
                    'Start',
                    DateFormat('yyyy-MM-dd hh:mm a').format(event.dateTime),
                  ),
                  _buildEventDetailRow(
                    'End',
                    event.endDateTime != null
                        ? DateFormat('yyyy-MM-dd hh:mm a').format(event.endDateTime!)
                        : 'N/A',
                  ),
                  _buildEventDetailRow('Notes', event.notes),
                  SizedBox(height: 16),
                  Text(
                    'Attendees:',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (attendeeNicknames.isEmpty)
                    Text(
                      'No attendees found',
                      style: TextStyle(color: Colors.white70),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: attendeeNicknames.map((nickname) {
                        return Text(
                          nickname,
                          style: TextStyle(color: Colors.white70),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  Widget _buildEventDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text('$title: ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<List<EventModel>>(
        stream: getClubEvents(clubId), // 이벤트 데이터 스트림
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm, size: 100, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    "Your club doesn't have any upcoming meetings",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          final now = DateTime.now();
          final upcomingEvents = snapshot.data!.where((event) => event.dateTime.isAfter(now)).toList();
          final pastEvents = snapshot.data!.where((event) => event.dateTime.isBefore(now)).toList();

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 다가오는 일정 섹션
                    Text(
                      '다가오는 일정',
                      style: TextStyle(
                        color: Colors.white54, // 글자색 회색으로 변경
                        fontSize: 20, // 글자 크기 축소
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ...upcomingEvents.map((event) {
                      bool isAttending = event.attendees.contains(FirebaseAuth.instance.currentUser!.uid);
                      return Card(
                        color: Colors.grey[900], // 카드 배경색 설정
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.bookTitle,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18, // 글자 크기 확대
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Author: ${event.author}',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Start: ${DateFormat('yyyy-MM-dd hh:mm a').format(event.dateTime)}',
                                      style: TextStyle(color: Colors.white70),
                                      overflow: TextOverflow.ellipsis, // 줄바꿈 방지
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            isAttending
                                                ? '참석'
                                                : '참석 여부',
                                            style: TextStyle(color: Colors.white70),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Switch(
                                          value: isAttending,
                                          onChanged: (value) {
                                            _toggleAttendance(event.id, value);
                                          },
                                          activeColor: Colors.green,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 크기 축소
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _showEventDetails(context, event),
                                child: Text('View Details', style: TextStyle(fontSize: 12)), // 버튼 크기 축소
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.black, // 텍스트 색상 설정
                                  minimumSize: Size(60, 36), // 버튼 최소 크기 설정
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 32),
                    // 지난 일정 섹션
                    Text(
                      '지난 일정',
                      style: TextStyle(
                        color: Colors.white54, // 글자색 회색으로 변경
                        fontSize: 20, // 글자 크기 축소
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ...pastEvents.map((event) {
                      return Card(
                        color: Colors.grey[900], // 카드 배경색 설정
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.bookTitle,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18, // 글자 크기 확대
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Author: ${event.author}',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Start: ${DateFormat('yyyy-MM-dd hh:mm a').format(event.dateTime)}',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _showEventDetails(context, event),
                                child: Text('View Details', style: TextStyle(fontSize: 12)), // 버튼 크기 축소
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.black, // 텍스트 색상 설정
                                  minimumSize: Size(60, 36), // 버튼 최소 크기 설정
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              // 일정 추가 버튼
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    // 일정 추가 기능 호출
                    _addEvent(context);
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 새로운 이벤트 추가 함수
  Future<void> _addEvent(BuildContext context) async {
    String title = '';
    String description = '';
    String bookTitle = '';
    String author = '';
    String notes = '';
    DateTime? startDate;
    TimeOfDay? startTime;
    DateTime? endDate;
    TimeOfDay? endTime;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.greenAccent.shade100, width: 1), // 테두리 색상 설정
              ),
              title: Text(
                'Add New Event',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // Book Title 입력
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Book Title',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (value) {
                        bookTitle = value;
                      },
                    ),
                    SizedBox(height: 8),
                    // Author 입력
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Author',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (value) {
                        author = value;
                      },
                    ),
                    SizedBox(height: 8),
                    // 이벤트 이름 입력
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (value) {
                        title = value;
                      },
                    ),
                    SizedBox(height: 8),
                    // 이벤트 설명 입력
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (value) {
                        description = value;
                      },
                    ),
                    SizedBox(height: 16),
                    // DatePicker 및 TimePicker
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              startDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              setState(() {
                                // Start Date 선택 후 End Date 자동 설정
                                endDate = startDate;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white70),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                                  SizedBox(width: 10),
                                  Text(
                                    startDate == null
                                        ? 'Start Date'
                                        : DateFormat.yMMMd().format(startDate!),
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              startTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              setState(() {
                                // Start Time 선택 후 End Time 자동 설정
                                endTime = startTime?.replacing(
                                  hour: (startTime!.hour + 2) % 24,
                                  minute: startTime!.minute,
                                );
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white70),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.access_time, color: Colors.white70, size: 16),
                                  SizedBox(width: 10),
                                  Text(
                                    startTime == null
                                        ? 'Start Time'
                                        : startTime!.format(context),
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              endDate = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white70),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                                  SizedBox(width: 10),
                                  Text(
                                    endDate == null
                                        ? 'End Date'
                                        : DateFormat.yMMMd().format(endDate!),
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              endTime = await showTimePicker(
                                context: context,
                                initialTime: startTime?.replacing(
                                  hour: (startTime!.hour + 2) % 24,
                                  minute: startTime!.minute,
                                ) ??
                                    TimeOfDay.now(),
                              );
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white70),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.access_time, color: Colors.white70, size: 16),
                                  SizedBox(width: 10),
                                  Text(
                                    endTime == null ? 'End Time' : endTime!.format(context),
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Notes 입력
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 3,
                      onChanged: (value) {
                        notes = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.green)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Add Event', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    if (title.isNotEmpty && startDate != null && startTime != null) {
                      // 이벤트 시작 시간과 종료 시간을 합침
                      DateTime startDateTime = DateTime(
                        startDate!.year,
                        startDate!.month,
                        startDate!.day,
                        startTime!.hour,
                        startTime!.minute,
                      );

                      DateTime? endDateTime;
                      if (endDate != null && endTime != null) {
                        endDateTime = DateTime(
                          endDate!.year,
                          endDate!.month,
                          endDate!.day,
                          endTime!.hour,
                          endTime!.minute,
                        );
                      }

                      // Firestore에 이벤트 저장
                      await FirebaseFirestore.instance
                          .collection('clubs')
                          .doc(clubId)
                          .collection('events')
                          .add({
                        'title': title,
                        'description': description,
                        'bookTitle': bookTitle,
                        'author': author,
                        'date': Timestamp.fromDate(startDateTime),
                        'endDate': endDateTime != null ? Timestamp.fromDate(endDateTime) : null,
                        'location': '', // location은 필요 시 추가
                        'notes': notes,
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
      },
    );
  }
}
