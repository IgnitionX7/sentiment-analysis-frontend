import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_result.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000';

  static Future<List<ArticleResult>> analyze(
    String query, {
    int pageSize = 10,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query, 'page_size': pageSize}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Something went wrong');
    }

    final results = data['results'] as List;
    return results
        .map((json) => ArticleResult.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
