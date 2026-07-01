import 'package:cloud_firestore/cloud_firestore.dart';
import 'article_result.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String query;
  final String source;
  final DateTime createdAt;
  final List<ArticleResult> articles;
  final Map<String, int> sentimentCounts;
  final int commentCount;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.query,
    required this.source,
    required this.createdAt,
    required this.articles,
    required this.sentimentCounts,
    this.commentCount = 0,
  });

  static Map<String, int> computeCounts(List<ArticleResult> articles) {
    final counts = {'positive': 0, 'neutral': 0, 'negative': 0};
    for (final a in articles) {
      if (a.sentimentLabel != null) {
        counts[a.sentimentLabel!] = (counts[a.sentimentLabel!] ?? 0) + 1;
      }
    }
    return counts;
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'userName': userName,
        'userPhotoUrl': userPhotoUrl,
        'query': query,
        'source': source,
        'createdAt': Timestamp.fromDate(createdAt),
        'articles': articles.map((a) => a.toFullJson()).toList(),
        'sentimentCounts': sentimentCounts,
        'commentCount': commentCount,
      };

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final articlesData = (data['articles'] as List<dynamic>?) ?? [];
    final counts = (data['sentimentCounts'] as Map<String, dynamic>?) ?? {};
    return Post(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      query: data['query'] ?? '',
      source: data['source'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      articles: articlesData
          .map((a) => ArticleResult.fromFullJson(a as Map<String, dynamic>))
          .toList(),
      sentimentCounts:
          counts.map((k, v) => MapEntry(k, (v as num).toInt())),
      commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
    );
  }
}
