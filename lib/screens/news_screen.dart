import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/article_result.dart';
import '../services/api_service.dart';
import '../widgets/article_card.dart';
import '../widgets/sentiment_chart.dart';

class NewsScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;

  const NewsScreen({super.key, required this.onNavigate});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _controller = TextEditingController();
  List<ArticleResult> _articles = [];
  bool _fetching = false;
  bool _analyzing = false;
  String? _fetchError;
  String? _analyzeError;
  bool _hasFetched = false;
  String _lastQuery = '';

  bool get _isAnalyzed => _articles.isNotEmpty && _articles.first.isAnalyzed;

  Future<void> _fetchArticles() async {
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
      final articles =
          await ApiService.fetchArticles(query, source: 'newsapi');
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildSearchBar(),
        const SizedBox(height: 8),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.onNavigate(0),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'News Sentiment Analysis',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Search and analyze news articles',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: AppColors.textPrimary),
                onSubmitted: (_) =>
                    _fetching ? null : _fetchArticles(),
                decoration: InputDecoration(
                  hintText:
                      'Enter keywords (e.g. technology, climate, politics)',
                  hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.4)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AppGradientButton(
            label: 'Fetch News',
            icon: Icons.newspaper_rounded,
            onTap: _fetching ? null : _fetchArticles,
            verticalPadding: 13,
            horizontalPadding: 18,
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
            CircularProgressIndicator(color: AppColors.accent),
            SizedBox(height: 16),
            Text('Fetching articles...',
                style: TextStyle(color: AppColors.textSecondary)),
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
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.negative),
              const SizedBox(height: 16),
              Text(
                _fetchError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.negative, fontSize: 14),
              ),
              const SizedBox(height: 20),
              AppGradientButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                onTap: _fetchArticles,
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasFetched) {
      return const AppEmptyState(
        icon: Icons.newspaper_outlined,
        title: 'Search for News',
        subtitle: 'Enter keywords to find and analyze news articles.',
      );
    }

    if (_articles.isEmpty) {
      return const AppEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Results',
        subtitle: 'No articles found. Try a different keyword.',
      );
    }

    return Column(
      children: [
        _buildResultsHeader(),
        if (_analyzeError != null)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.neutral, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Analysis failed: $_analyzeError',
                    style: const TextStyle(
                        color: AppColors.neutral, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            itemCount: _articles.length,
            itemBuilder: (context, i) =>
                ArticleCard(article: _articles[i]),
          ),
        ),
        if (_isAnalyzed) SentimentChart(articles: _articles),
      ],
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        children: [
          Text(
            '${_articles.length} articles for "$_lastQuery"',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
          ),
          const Spacer(),
          if (!_isAnalyzed)
            AppGradientButton(
              label: _analyzing ? 'Analyzing...' : 'Analyze Sentiment',
              icon: _analyzing ? null : Icons.psychology_rounded,
              onTap: _analyzing ? null : _analyzeSentiment,
              verticalPadding: 9,
              horizontalPadding: 16,
            ),
        ],
      ),
    );
  }
}
