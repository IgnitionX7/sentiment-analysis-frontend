import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/article_result.dart';
import '../theme.dart';

class SentimentChart extends StatelessWidget {
  final List<ArticleResult> articles;

  const SentimentChart({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{'positive': 0, 'neutral': 0, 'negative': 0};
    double totalScore = 0;
    int scoredCount = 0;

    for (final a in articles) {
      if (a.sentimentLabel != null) {
        counts[a.sentimentLabel!] = (counts[a.sentimentLabel!] ?? 0) + 1;
      }
      if (a.sentimentScore != null) {
        totalScore += a.sentimentScore!;
        scoredCount++;
      }
    }

    final total = articles.length;
    final avgConfidence =
        scoredCount > 0 ? (totalScore / scoredCount * 100).round() : 0;

    final dominant =
        counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final dominantColor = _colorFor(dominant);

    final sections = [
      if (counts['positive']! > 0)
        PieChartSectionData(
          value: counts['positive']!.toDouble(),
          color: AppColors.positive,
          title: '${(counts['positive']! / total * 100).round()}%',
          radius: 48,
          titleStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      if (counts['neutral']! > 0)
        PieChartSectionData(
          value: counts['neutral']!.toDouble(),
          color: AppColors.neutral,
          title: '${(counts['neutral']! / total * 100).round()}%',
          radius: 48,
          titleStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      if (counts['negative']! > 0)
        PieChartSectionData(
          value: counts['negative']!.toDouble(),
          color: AppColors.negative,
          title: '${(counts['negative']! / total * 100).round()}%',
          radius: 48,
          titleStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
        ),
    ];

    return Container(
      height: 180,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // Donut chart
          SizedBox(
            width: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 36,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: dominantColor,
                      ),
                    ),
                    const Text(
                      'results',
                      style: TextStyle(
                          fontSize: 9, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Legend
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sentiment Overview',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 10),
                _LegendRow(
                    color: AppColors.positive,
                    label: 'Positive',
                    count: counts['positive']!,
                    total: total),
                const SizedBox(height: 5),
                _LegendRow(
                    color: AppColors.neutral,
                    label: 'Neutral',
                    count: counts['neutral']!,
                    total: total),
                const SizedBox(height: 5),
                _LegendRow(
                    color: AppColors.negative,
                    label: 'Negative',
                    count: counts['negative']!,
                    total: total),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Avg confidence badge
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dominantColor.withValues(alpha: 0.12),
                  border: Border.all(
                      color: dominantColor.withValues(alpha: 0.35), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$avgConfidence%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: dominantColor,
                      ),
                    ),
                    Text(
                      'avg conf.',
                      style: const TextStyle(
                          fontSize: 8, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Mostly ${dominant[0].toUpperCase()}${dominant.substring(1)}',
                style: TextStyle(
                  fontSize: 10,
                  color: dominantColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorFor(String label) {
    switch (label) {
      case 'positive':
        return AppColors.positive;
      case 'negative':
        return AppColors.negative;
      default:
        return AppColors.neutral;
    }
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final int total;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100).round() : 0;
    final barFraction = total > 0 ? count / total : 0.0;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 54,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: barFraction.toDouble(),
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              color: color,
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          child: Text(
            '$count ($pct%)',
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 10),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
