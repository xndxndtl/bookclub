import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TopicSearchScreen extends StatefulWidget {
  @override
  _TopicSearchScreenState createState() => _TopicSearchScreenState();
}

class _TopicSearchScreenState extends State<TopicSearchScreen> {
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

    getJSONData(); // 페이지가 처음 로드될 때 초기 데이터 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: TextField(
          controller: _editingController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            hintText: '책 제목을 검색하세요',
            hintStyle: TextStyle(color: Colors.white54),
          ),
          onSubmitted: (value) {
            // 검색어를 제출할 때 데이터를 다시 로드
            page = 1;
            data.clear();
            getJSONData();
          },
        ),
        backgroundColor: Colors.black,
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
                color: Colors.grey[900],
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '저자: ${data[index]['authors'].join(', ')}',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '가격: ${formatPrice(data[index]['sale_price'])}',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '상태: ${data[index]['status'].toString()}',
                              style: TextStyle(color: Colors.white70),
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
        backgroundColor: Colors.green,
        onPressed: () {
          page = 1;
          data.clear();
          getJSONData();
        },
        child: const Icon(Icons.file_download, color: Colors.white),
      ),
    );
  }

  Future<void> getJSONData() async {
    var url =
        'https://dapi.kakao.com/v3/search/book?target=title&page=$page&query=${_editingController!.value.text}';
    var response = await http.get(Uri.parse(url),
        headers: {"Authorization": "KakaoAK bbe5732d7be1c934639116216a1a4ff4"});

    if (response.statusCode == 200) {
      var dataConvertedToJSON = json.decode(response.body);
      List result = dataConvertedToJSON['documents'];
      setState(() {
        data.addAll(result.cast<Map<String, dynamic>>());
        maxPage = dataConvertedToJSON['meta']['pageable_count']; // 최대 페이지 수 설정
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
