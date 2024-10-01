/* import 'package:military_bookstore/data/BookInfo.dart';

class ApiResponse {
  Meta meta;
  BookInfo bookInfo;

  ApiResponse({
    required this.meta,
    required this.bookInfo,
  });

  factory ApiResponse.fromMap(Map<String, dynamic> data) {
    return ApiResponse(
      meta: Meta.fromJson(data['meta']),
      bookInfo: BookInfo.fromMap(data['documents'][0]),
    );
  }

}
*/
