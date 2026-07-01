import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/sentiment_chart.dart';
import '../widgets/article_card.dart';
import '../widgets/comment_widget.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Future<void> _confirmDeletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E0D40),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Post',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will permanently remove the post.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.negative)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await PostService.deletePost(widget.post.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDeleteComment(
      String postId, String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E0D40),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Comment',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Remove this comment?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.negative)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await PostService.deleteComment(postId, commentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final currentUid = authSnapshot.data?.uid;

        return StreamBuilder<String?>(
          stream: UserService.watchCurrentUserRole(),
          builder: (context, roleSnapshot) {
            final isAdmin = roleSnapshot.data == 'admin';
            final canDeletePost = currentUid == widget.post.userId || isAdmin;

            return Scaffold(
              backgroundColor: AppColors.bgBottom,
              body: Container(
                decoration: const BoxDecoration(gradient: kMainGradient),
                child: Column(
                  children: [
                    _buildHeader(context, canDeletePost),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildArticlesPanel(),
                          ),
                          Container(
                              width: 1, color: AppColors.cardBorder),
                          Expanded(
                            flex: 2,
                            child: _buildCommentsPanel(
                                currentUid, isAdmin),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool canDeletePost) {
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
                  '"${widget.post.query}"',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'by ${widget.post.userName} · ${_formatDate(widget.post.createdAt)}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (canDeletePost)
            GestureDetector(
              onTap: _confirmDeletePost,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.negative.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.negative.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.negative, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArticlesPanel() {
    return Column(
      children: [
        SentimentChart(articles: widget.post.articles),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: widget.post.articles.length,
            itemBuilder: (context, i) =>
                ArticleCard(article: widget.post.articles[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsPanel(String? currentUid, bool isAdmin) {
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
            stream: PostService.getComments(widget.post.id),
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
                itemBuilder: (context, i) {
                  final comment = comments[i];
                  final canDelete =
                      currentUid == comment.userId || isAdmin;
                  return CommentTile(
                    comment: comment,
                    onDelete: canDelete
                        ? () => _confirmDeleteComment(
                            widget.post.id, comment.id)
                        : null,
                  );
                },
              );
            },
          ),
        ),
        CommentInput(postId: widget.post.id),
      ],
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';
}
