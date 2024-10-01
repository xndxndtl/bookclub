import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookclub.app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookclub.app/screens/sign_in_screen.dart';
import 'package:bookclub.app/screens/home_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:bookclub.app/screens/nickname_screen.dart';
import 'package:bookclub.app/screens/welcome_screen.dart'; // WelcomeScreen 임포트


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Club App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // 처음 화면은 WelcomeScreen으로 설정
      home: WelcomeScreen(),
    );
  }
}

/*  카카오 도서 api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const HttpApp(),
    );
  }
}



class HttpApp extends StatefulWidget {
  const HttpApp({Key? key});

  @override
  State<HttpApp> createState() => _HttpAppState();
}

class _HttpAppState extends State<HttpApp> {
  List<Map<String, dynamic>> data = [];
  TextEditingController? _editingController;
  ScrollController? _scrollController;
  int page = 1;
  int maxPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();
    _scrollController = ScrollController();

    _scrollController!.addListener(() {
      if (_scrollController!.offset >=
          _scrollController!.position.maxScrollExtent &&
          !_scrollController!.position.outOfRange &&
          !isLoading &&
          page < maxPage) {
        setState(() {
          isLoading = true;
        });
        page++;
        getJSONData();
      }
    });

    getJSONData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _editingController,
          style: const TextStyle(color: Colors.black),
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(hintText: '검색어를 입력하세요'),
        ),
      ),
      body: Center(
        child: data.isEmpty
            ? const CircularProgressIndicator()
            : ListView.builder(
          controller: _scrollController,
          itemCount: data.length + 1,
          itemBuilder: (context, index) {
            if (index < data.length) {
              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Image.network(
                          data[index]['thumbnail'],
                          height: 100,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              data[index]['title'].toString(),
                              style:
                              const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '저자: ${data[index]['authors'].join(', ')}',
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '가격: ${formatPrice(data[index]['sale_price'])}',
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '상태: ${data[index]['status'].toString()}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          page = 1;
          data.clear();
          getJSONData();
        },
        child: const Icon(Icons.file_download),
      ),
    );
  }

  Future<void> getJSONData() async {
    var url = 'https://dapi.kakao.com/v3/search/book?target=title&page=$page&query=${_editingController!.value.text}';
    var response = await http.get(Uri.parse(url),
        headers: {"Authorization": "KakaoAK bbe5732d7be1c934639116216a1a4ff4"});

    if (response.statusCode == 200) {
      var dataConvertedToJSON = json.decode(response.body);
      List result = dataConvertedToJSON['documents'];
      setState(() {
        data.addAll(result.cast<Map<String, dynamic>>());
        maxPage = dataConvertedToJSON['meta']['pageable_count']; // 페이징 정보에서 최대 페이지 수 가져오기
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  String formatPrice(int price) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    return currencyFormat.format(price);
  }
}

*/