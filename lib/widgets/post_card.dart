import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pos = post.sentimentCounts['positive'] ?? 0;
    final neu = post.sentimentCounts['neutral'] ?? 0;
    final neg = post.sentimentCounts['negative'] ?? 0;
    final total = pos + neu + neg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info row
              Row(
                children: [
                  _UserAvatar(
                      photoUrl: post.userPhotoUrl, name: post.userName),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatTime(post.createdAt),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SourceBadge(source: post.source),
                ],
              ),
              const SizedBox(height: 12),

              // Query
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Analysis: ',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                    ),
                    TextSpan(
                      text: '"${post.query}"',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Mini sentiment bar
              if (total > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      if (pos > 0)
                        Expanded(
                          flex: pos,
                          child: Container(
                              height: 7, color: AppColors.positive),
                        ),
                      if (neu > 0)
                        Expanded(
                          flex: neu,
                          child: Container(
                              height: 7, color: AppColors.neutral),
                        ),
                      if (neg > 0)
                        Expanded(
                          flex: neg,
                          child: Container(
                              height: 7, color: AppColors.negative),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Dot(color: AppColors.positive, label: '$pos pos'),
                    const SizedBox(width: 10),
                    _Dot(color: AppColors.neutral, label: '$neu neu'),
                    const SizedBox(width: 10),
                    _Dot(color: AppColors.negative, label: '$neg neg'),
                    const Spacer(),
                    const Icon(Icons.chat_bubble_outline_rounded,
                        size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentCount}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
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

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  const _UserAvatar({this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null) {
      return CircleAvatar(
          radius: 18, backgroundImage: NetworkImage(photoUrl!));
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.accent.withValues(alpha: 0.3),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String source;
  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final isNews = source == 'newsapi';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: isNews ? kNewsGradient : kSocialGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isNews ? 'NewsAPI' : 'Bluesky',
        style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}
