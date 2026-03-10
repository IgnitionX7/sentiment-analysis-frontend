import 'package:flutter/material.dart';
import 'models/article_result.dart';
import 'services/api_service.dart';
import 'widgets/article_card.dart';
import 'widgets/sentiment_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentiment Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();

  List<ArticleResult> _articles = [];
  bool _fetching = false;
  bool _analyzing = false;
  String? _fetchError;
  String? _analyzeError;
  bool _hasFetched = false;
  String _lastQuery = '';

  Future<void> _fetchNews() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _fetching = true;
      _fetchError = null;
      _analyzeError = null;
      _articles = [];
      _hasFetched = false;
    });

    try {
      final articles = await ApiService.fetchArticles(query);
      setState(() {
        _articles = articles;
        _lastQuery = query;
        _hasFetched = true;
      });
    } catch (e) {
      setState(() {
        _fetchError = e.toString().replaceFirst('Exception: ', '');
        _hasFetched = true;
      });
    } finally {
      setState(() => _fetching = false);
    }
  }

  Future<void> _analyzeSentiment() async {
    if (_articles.isEmpty) return;

    setState(() {
      _analyzing = true;
      _analyzeError = null;
    });

    try {
      final results = await ApiService.analyzeArticles(_articles);
      setState(() => _articles = results);
    } catch (e) {
      setState(() {
        _analyzeError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => _analyzing = false);
    }
  }

  bool get _isAnalyzed =>
      _articles.isNotEmpty && _articles.first.isAnalyzed;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentiment Analyzer'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search news by keyword...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: (_) => _fetchNews(),
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: (_fetching || _analyzing) ? null : _fetchNews,
              icon: const Icon(Icons.newspaper),
              label: const Text('Fetch News'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_fetching) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching articles...'),
          ],
        ),
      );
    }

    if (_fetchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _fetchError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasFetched) {
      return const Center(
        child: Text(
          'Enter a keyword to search for news articles',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_articles.isEmpty) {
      return const Center(
        child: Text(
          'No articles found for this keyword',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        _buildResultsHeader(),
        if (_analyzeError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Analysis failed: $_analyzeError',
                    style: const TextStyle(color: Colors.orange, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _articles.length,
            itemBuilder: (context, index) =>
                ArticleCard(article: _articles[index]),
          ),
        ),
        if (_isAnalyzed) SentimentChart(articles: _articles),
      ],
    );
  }

  Widget _buildResultsHeader() {
    final sources =
        _articles.map((a) => a.source).where((s) => s.isNotEmpty).toSet();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_articles.length} articles for "$_lastQuery"',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  sources.isEmpty
                      ? ''
                      : '${sources.length} source${sources.length > 1 ? 's' : ''}: ${sources.take(3).join(', ')}${sources.length > 3 ? '…' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (!_isAnalyzed)
            FilledButton.icon(
              onPressed: _analyzing ? null : _analyzeSentiment,
              icon: _analyzing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.psychology, size: 18),
              label: Text(_analyzing ? 'Analyzing...' : 'Analyze Sentiment'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          else
            _buildSentimentSummary(),
        ],
      ),
    );
  }

  Widget _buildSentimentSummary() {
    final counts = <String, int>{'positive': 0, 'neutral': 0, 'negative': 0};
    for (final a in _articles) {
      if (a.sentimentLabel != null) {
        counts[a.sentimentLabel!] = (counts[a.sentimentLabel!] ?? 0) + 1;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SentimentBadge(
            label: 'Pos', count: counts['positive']!, color: Colors.green),
        const SizedBox(width: 6),
        _SentimentBadge(
            label: 'Neu', count: counts['neutral']!, color: Colors.amber),
        const SizedBox(width: 6),
        _SentimentBadge(
            label: 'Neg', count: counts['negative']!, color: Colors.red),
      ],
    );
  }
}

class _SentimentBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SentimentBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              height: 1.1,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
