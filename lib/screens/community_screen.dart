import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  Future<void> _confirmDeletePost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E0D40),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Post',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will permanently remove the post and all its comments.',
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
      await PostService.deletePost(postId);
    }
  }

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
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              final currentUid = authSnapshot.data?.uid;

              return StreamBuilder<String?>(
                stream: UserService.watchCurrentUserRole(),
                builder: (context, roleSnapshot) {
                  final isAdmin = roleSnapshot.data == 'admin';

                  return StreamBuilder<List<Post>>(
                    stream: PostService.getPosts(),
                    builder: (context, postsSnapshot) {
                      if (postsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accent),
                        );
                      }
                      if (postsSnapshot.hasError) {
                        return Center(
                          child: AppEmptyState(
                            icon: Icons.error_outline_rounded,
                            title: 'Failed to load posts',
                            subtitle: postsSnapshot.error.toString(),
                          ),
                        );
                      }
                      final posts = postsSnapshot.data ?? [];
                      if (posts.isEmpty) {
                        return const AppEmptyState(
                          icon: Icons.people_outline_rounded,
                          title: 'No Posts Yet',
                          subtitle:
                              'Be the first to share a sentiment analysis!',
                        );
                      }
                      return ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: posts.length,
                        itemBuilder: (context, i) {
                          final post = posts[i];
                          final canDelete =
                              currentUid == post.userId || isAdmin;
                          return PostCard(
                            post: post,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PostDetailScreen(post: post),
                                ),
                              );
                            },
                            onDelete: canDelete
                                ? () => _confirmDeletePost(post.id)
                                : null,
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
