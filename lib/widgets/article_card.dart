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
    final confidence = (article.sentimentScore * 100).toStringAsFixed(0);

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
              // Title + sentiment chip
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
                  const SizedBox(width: 12),
                  Chip(
                    avatar: Icon(_sentimentIcon, size: 18, color: _sentimentColor),
                    label: Text(
                      '${article.sentimentLabel} $confidence%',
                      style: TextStyle(
                        color: _sentimentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: _sentimentColor.withValues(alpha: 0.1),
                    side: BorderSide(color: _sentimentColor.withValues(alpha: 0.3)),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Source + date
              Text(
                '${article.source}  •  $_formattedDate',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
