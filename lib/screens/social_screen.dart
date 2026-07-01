import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../models/article_result.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../services/post_service.dart';
import '../widgets/article_card.dart';
import '../widgets/sentiment_chart.dart';

class SocialScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;

  const SocialScreen({super.key, required this.onNavigate});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final _controller = TextEditingController();
  List<ArticleResult> _posts = [];
  bool _fetching = false;
  bool _analyzing = false;
  String? _fetchError;
  String? _analyzeError;
  bool _hasFetched = false;
  String _lastQuery = '';

  bool get _isAnalyzed => _posts.isNotEmpty && _posts.first.isAnalyzed;

  Future<void> _fetchPosts() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _fetching = true;
      _fetchError = null;
      _analyzeError = null;
      _posts = [];
      _hasFetched = false;
    });

    try {
      final posts =
          await ApiService.fetchArticles(query, source: 'bluesky');
      setState(() {
        _posts = posts;
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
    if (_posts.isEmpty) return;

    setState(() {
      _analyzing = true;
      _analyzeError = null;
    });

    try {
      final results = await ApiService.analyzeArticles(_posts);
      setState(() => _posts = results);
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
                  'Social Media Sentiment',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Search and analyze Bluesky posts',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          // Bluesky badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: kSocialGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_rounded, color: Colors.white, size: 13),
                SizedBox(width: 4),
                Text(
                  'Bluesky',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
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
                onSubmitted: (_) => _fetching ? null : _fetchPosts(),
                decoration: InputDecoration(
                  hintText:
                      'Enter keywords (e.g. climate, AI, politics)',
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
            label: 'Fetch Posts',
            icon: Icons.cloud_download_rounded,
            gradient: kSocialGradient,
            onTap: _fetching ? null : _fetchPosts,
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
            CircularProgressIndicator(color: AppColors.socialStart),
            SizedBox(height: 16),
            Text('Fetching posts...',
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
                onTap: _fetchPosts,
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasFetched) {
      return const AppEmptyState(
        icon: Icons.cloud_outlined,
        title: 'Search Bluesky Posts',
        subtitle:
            'Enter a keyword to find and analyze public posts.',
      );
    }

    if (_posts.isEmpty) {
      return const AppEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Posts Found',
        subtitle: 'Try a different keyword or broader search term.',
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
            itemCount: _posts.length,
            itemBuilder: (context, i) =>
                ArticleCard(article: _posts[i]),
          ),
        ),
        if (_isAnalyzed) SentimentChart(articles: _posts),
      ],
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        children: [
          Text(
            '${_posts.length} posts for "$_lastQuery"',
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
            )
          else if (FirebaseAuth.instance.currentUser != null)
            AppGradientButton(
              label: 'Share as Post',
              icon: Icons.share_rounded,
              gradient: kSocialGradient,
              onTap: () => _shareAsPost(context),
              verticalPadding: 9,
              horizontalPadding: 16,
            ),
        ],
      ),
    );
  }

  Future<void> _shareAsPost(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E0D40),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Share Analysis',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Post your "$_lastQuery" analysis to the community?',
              style:
                  const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '${_posts.length} posts · Bluesky',
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Post',
                style: TextStyle(color: AppColors.socialStart)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final post = Post(
        id: '',
        userId: user.uid,
        userName: user.displayName ?? 'User',
        userPhotoUrl: user.photoURL,
        query: _lastQuery,
        source: 'bluesky',
        createdAt: DateTime.now(),
        articles: _posts,
        sentimentCounts: Post.computeCounts(_posts),
      );
      await PostService.createPost(post);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Posted to Community!'),
            backgroundColor: AppColors.positive,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post: $e'),
            backgroundColor: AppColors.negative,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}
