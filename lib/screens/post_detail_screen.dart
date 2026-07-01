import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/post_service.dart';
import '../widgets/sentiment_chart.dart';
import '../widgets/article_card.dart';
import '../widgets/comment_widget.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      body: Container(
        decoration: const BoxDecoration(gradient: kMainGradient),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: chart + articles
                  Expanded(
                    flex: 3,
                    child: _buildArticlesPanel(),
                  ),
                  Container(width: 1, color: AppColors.cardBorder),
                  // Right: comments
                  Expanded(
                    flex: 2,
                    child: _buildCommentsPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${post.query}"',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'by ${post.userName} · ${_formatDate(post.createdAt)}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesPanel() {
    return Column(
      children: [
        SentimentChart(articles: post.articles),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: post.articles.length,
            itemBuilder: (context, i) =>
                ArticleCard(article: post.articles[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Comments',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Comment>>(
            stream: PostService.getComments(post.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.accent));
              }
              final comments = snapshot.data ?? [];
              if (comments.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No comments yet',
                  subtitle: 'Be the first to comment!',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: comments.length,
                itemBuilder: (context, i) =>
                    CommentTile(comment: comments[i]),
              );
            },
          ),
        ),
        CommentInput(postId: post.id),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
