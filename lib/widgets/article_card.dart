import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article_result.dart';
import '../theme.dart';

class ArticleCard extends StatelessWidget {
  final ArticleResult article;

  const ArticleCard({super.key, required this.article});

  Color get _sentimentColor {
    switch (article.sentimentLabel) {
      case 'positive':
        return AppColors.positive;
      case 'negative':
        return AppColors.negative;
      default:
        return AppColors.neutral;
    }
  }

  IconData get _sentimentIcon {
    switch (article.sentimentLabel) {
      case 'positive':
        return Icons.sentiment_satisfied_alt_rounded;
      case 'negative':
        return Icons.sentiment_dissatisfied_rounded;
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }

  String get _formattedDate {
    final dt = DateTime.tryParse(article.publishedAt);
    if (dt == null) return '';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (article.isAnalyzed) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _sentimentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _sentimentColor.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_sentimentIcon,
                              size: 14, color: _sentimentColor),
                          const SizedBox(width: 4),
                          Text(
                            '${article.sentimentLabel} ${(article.sentimentScore! * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: _sentimentColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              // Source + date
              Row(
                children: [
                  Icon(Icons.person_outline_rounded,
                      size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    article.source.isNotEmpty ? article.source : 'Unknown',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_formattedDate.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text('·',
                        style: TextStyle(
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                            fontSize: 12)),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      _formattedDate,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ],
              ),
              // Description
              if (article.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  article.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
              // Tap hint (pre-analysis)
              if (!article.isAnalyzed) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.open_in_new_rounded,
                        size: 12,
                        color: AppColors.textMuted.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to open',
                      style: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
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
