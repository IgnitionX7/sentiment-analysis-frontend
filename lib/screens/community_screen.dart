import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/post_service.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Community',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Explore sentiment analyses shared by others',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Post>>(
            stream: PostService.getPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: AppEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Failed to load posts',
                    subtitle: snapshot.error.toString(),
                  ),
                );
              }
              final posts = snapshot.data ?? [];
              if (posts.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.people_outline_rounded,
                  title: 'No Posts Yet',
                  subtitle:
                      'Be the first to share a sentiment analysis!',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: posts.length,
                itemBuilder: (context, i) => PostCard(
                  post: posts[i],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            PostDetailScreen(post: posts[i]),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
