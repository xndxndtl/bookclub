/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bookclub.app/services/ApiResponse.dart';

Future<void> getBookInfo(String query) async {
  const apiUrl = "https://dapi.kakao.com/v3/search/book";
  const apiKey = "bbe5732d7be1c934639116216a1a4ff4";

  final response = await http.get(
    Uri.parse('$apiUrl?query=$query'),
    headers: {
      'Authorization': 'KakaoAK $apiKey',
    },
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    ApiResponse apiResponse = ApiResponse.fromMap(data);
    /// api로 받아온 결과에서 title을 query 값인 책 제목으로 수정 (부제 제거 목적)
    apiResponse.bookInfo.title = query;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await _firestore
        .collection('bookInfos')
        .where('title', isEqualTo: query)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      await _firestore
          .collection("bookInfos")
          .doc(query)
          .set(apiResponse.bookInfo.toMap());
    }

  } else {
    throw Exception('Failed to load books');
  }
}
*/