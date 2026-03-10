class ArticleResult {
  final String title;
  final String description;
  final String source;
  final String url;
  final String publishedAt;
  final String? sentimentLabel;
  final double? sentimentScore;

  ArticleResult({
    required this.title,
    required this.description,
    required this.source,
    required this.url,
    required this.publishedAt,
    this.sentimentLabel,
    this.sentimentScore,
  });

  bool get isAnalyzed => sentimentLabel != null;

  /// From a raw /fetch response (no sentiment).
  factory ArticleResult.fromArticleJson(Map<String, dynamic> json) {
    return ArticleResult(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      source: json['source'] ?? '',
      url: json['url'] ?? '',
      publishedAt: json['published_at'] ?? '',
    );
  }

  /// From an /analyze response (includes sentiment).
  factory ArticleResult.fromJson(Map<String, dynamic> json) {
    final sentiment = json['sentiment'] as Map<String, dynamic>?;
    return ArticleResult(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      source: json['source'] ?? '',
      url: json['url'] ?? '',
      publishedAt: json['published_at'] ?? '',
      sentimentLabel: sentiment?['label'],
      sentimentScore: sentiment != null
          ? (sentiment['score'] as num).toDouble()
          : null,
    );
  }

  /// Serialize for sending to /analyze.
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'source': source,
        'url': url,
        'published_at': publishedAt,
      };
}
