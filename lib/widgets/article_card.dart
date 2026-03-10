import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article_result.dart';

class ArticleCard extends StatelessWidget {
  final ArticleResult article;

  const ArticleCard({super.key, required this.article});

  Color get _sentimentColor {
    switch (article.sentimentLabel) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.amber;
    }
  }

  IconData get _sentimentIcon {
    switch (article.sentimentLabel) {
      case 'positive':
        return Icons.sentiment_satisfied_alt;
      case 'negative':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String get _formattedDate {
    final dt = DateTime.tryParse(article.publishedAt);
    if (dt == null) return '';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final uri = Uri.tryParse(article.url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row + optional sentiment chip
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (article.isAnalyzed) ...[
                    const SizedBox(width: 12),
                    Chip(
                      avatar: Icon(_sentimentIcon,
                          size: 18, color: _sentimentColor),
                      label: Text(
                        '${article.sentimentLabel} ${(article.sentimentScore! * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: _sentimentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor:
                          _sentimentColor.withValues(alpha: 0.1),
                      side: BorderSide(
                          color: _sentimentColor.withValues(alpha: 0.3)),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // Source + date
              Row(
                children: [
                  const Icon(Icons.source_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    article.source.isNotEmpty ? article.source : 'Unknown',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (_formattedDate.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text('•',
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 12)),
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ],
              ),
              // Description
              if (article.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  article.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              // Unanalyzed hint
              if (!article.isAnalyzed) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.open_in_new,
                        size: 13, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to open article',
                      style: TextStyle(
                          color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
