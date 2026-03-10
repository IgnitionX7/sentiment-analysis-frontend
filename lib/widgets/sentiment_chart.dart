import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/article_result.dart';

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

    // Dominant sentiment
    final dominant = counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    final dominantColor = _colorFor(dominant);

    final sections = [
      if (counts['positive']! > 0)
        PieChartSectionData(
          value: counts['positive']!.toDouble(),
          color: Colors.green.shade400,
          title: counts['positive']! > 0
              ? '${(counts['positive']! / total * 100).round()}%'
              : '',
          radius: 52,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      if (counts['neutral']! > 0)
        PieChartSectionData(
          value: counts['neutral']!.toDouble(),
          color: Colors.amber.shade400,
          title: '${(counts['neutral']! / total * 100).round()}%',
          radius: 52,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      if (counts['negative']! > 0)
        PieChartSectionData(
          value: counts['negative']!.toDouble(),
          color: Colors.red.shade400,
          title: '${(counts['negative']! / total * 100).round()}%',
          radius: 52,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      height: 180,
      child: Row(
        children: [
          // Donut chart
          SizedBox(
            width: 148,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 38,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                ),
                // Center label
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
                    Text(
                      'articles',
                      style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 28),
          // Legend + stats
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sentiment Overview',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(height: 10),
                _LegendRow(
                  color: Colors.green.shade400,
                  label: 'Positive',
                  count: counts['positive']!,
                  total: total,
                ),
                const SizedBox(height: 5),
                _LegendRow(
                  color: Colors.amber.shade400,
                  label: 'Neutral',
                  count: counts['neutral']!,
                  total: total,
                ),
                const SizedBox(height: 5),
                _LegendRow(
                  color: Colors.red.shade400,
                  label: 'Negative',
                  count: counts['negative']!,
                  total: total,
                ),
              ],
            ),
          ),
          // Avg confidence stat
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dominantColor.withValues(alpha: 0.08),
                  border: Border.all(
                      color: dominantColor.withValues(alpha: 0.3), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$avgConfidence%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: dominantColor,
                      ),
                    ),
                    Text(
                      'avg conf.',
                      style:
                          TextStyle(fontSize: 9, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Mostly ${dominant[0].toUpperCase()}${dominant.substring(1)}',
                style: TextStyle(
                  fontSize: 11,
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
        return Colors.green.shade500;
      case 'negative':
        return Colors.red.shade500;
      default:
        return Colors.amber.shade600;
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 60,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        // Mini bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: barFraction.toDouble(),
              backgroundColor: Colors.grey.shade200,
              color: color,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          child: Text(
            '$count ($pct%)',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
