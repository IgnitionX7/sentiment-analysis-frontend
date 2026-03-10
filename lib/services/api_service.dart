import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_result.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000';

  /// Fetches articles from NewsAPI without running sentiment analysis.
  static Future<List<ArticleResult>> fetchArticles(
    String query, {
    int pageSize = 10,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/fetch'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query, 'page_size': pageSize}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Something went wrong');
    }

    final articles = data['articles'] as List;
    return articles
        .map((json) =>
            ArticleResult.fromArticleJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Runs sentiment analysis on pre-fetched articles.
  static Future<List<ArticleResult>> analyzeArticles(
    List<ArticleResult> articles,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'articles': articles.map((a) => a.toJson()).toList(),
      }),
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
