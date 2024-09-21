import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class UpcomingEventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildUpcomingEventsSection();
  }

  // 내가 가입한 클럽들의 events에서 데이터를 가져와서 표시
  Widget _buildUpcomingEventsSection() {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('clubs')
          .where('members', arrayContains: userId) // 내 계정이 member 필드에 포함된 클럽 필터링
          .snapshots(),
      builder: (context, clubSnapshot) {
        if (clubSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (clubSnapshot.hasData && clubSnapshot.data!.docs.isNotEmpty) {
          // 가입한 클럽들을 조회하고, 각 클럽의 이벤트 데이터를 가져옴
          List<Future<QuerySnapshot>> eventFutures = [];
          for (var club in clubSnapshot.data!.docs) {
            eventFutures.add(
              FirebaseFirestore.instance
                  .collection('clubs')
                  .doc(club.id)
                  .collection('events')
                  .get(),
            );
          }

          return FutureBuilder<List<QuerySnapshot>>(
            future: Future.wait(eventFutures), // 모든 클럽의 이벤트 데이터 대기
            builder: (context, eventSnapshots) {
              if (eventSnapshots.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (eventSnapshots.hasData) {
                List<Widget> eventCards = [];

                for (var eventSnapshot in eventSnapshots.data!) {
                  for (var eventDoc in eventSnapshot.docs) {
                    final eventData = eventDoc.data() as Map<String, dynamic>;
                    eventCards.add(_buildEventCard(
                      eventData['title'],
                      (eventData['date'] as Timestamp)
                          .toDate(), // Timestamp를 DateTime으로 변환
                      eventData['location'], // location 필드 추가
                      eventData['description'],
                    ));
                  }
                }

                if (eventCards.isEmpty) {
                  return const Center(
                    child: Text(
                      '등록된 일정이 없습니다.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  return Column(children: eventCards);
                }
              } else {
                return const Center(
                  child: Text(
                    '등록된 일정이 없습니다.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            },
          );
        } else {
          return const Center(
            child: Text(
              '가입된 클럽이 없습니다.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
      },
    );
  }

  // Event Card
  Widget _buildEventCard(String title, DateTime date, String location, String description) {
    // 날짜 포맷 변환
    String formattedDate = DateFormat('MMMM dd, yyyy').format(date);
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              /*child: Image.asset(
                'assets/images/event_image.png', // 이벤트 이미지 로컬 경로
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),*/
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate, // 포맷된 날짜 표시
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location, // 위치 정보 추가
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
