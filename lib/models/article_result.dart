class ArticleResult {
  final String title;
  final String description;
  final String source;
  final String url;
  final String publishedAt;
  final String sentimentLabel;
  final double sentimentScore;

  ArticleResult({
    required this.title,
    required this.description,
    required this.source,
    required this.url,
    required this.publishedAt,
    required this.sentimentLabel,
    required this.sentimentScore,
  });

  factory ArticleResult.fromJson(Map<String, dynamic> json) {
    final sentiment = json['sentiment'] as Map<String, dynamic>;
    return ArticleResult(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      source: json['source'] ?? '',
      url: json['url'] ?? '',
      publishedAt: json['published_at'] ?? '',
      sentimentLabel: sentiment['label'] ?? 'neutral',
      sentimentScore: (sentiment['score'] as num).toDouble(),
    );
  }
}
