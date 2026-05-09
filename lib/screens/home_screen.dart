import 'package:flutter/material.dart';
import '../theme.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            '👋 Welcome back!',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'What would you like to analyze today?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 40),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 500;
              if (wide) {
                return Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        gradient: kSocialGradient,
                        icon: Icons.cloud_rounded,
                        title: 'Analyze Social Media',
                        subtitle: 'Get sentiment from Bluesky posts',
                        onTap: () => onNavigate(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _QuickActionCard(
                        gradient: kNewsGradient,
                        icon: Icons.newspaper_rounded,
                        title: 'Analyze News',
                        subtitle: 'Get sentiment from news articles',
                        onTap: () => onNavigate(1),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _QuickActionCard(
                    gradient: kSocialGradient,
                    icon: Icons.cloud_rounded,
                    title: 'Analyze Social Media',
                    subtitle: 'Get sentiment from Bluesky posts',
                    onTap: () => onNavigate(2),
                  ),
                  const SizedBox(height: 16),
                  _QuickActionCard(
                    gradient: kNewsGradient,
                    icon: Icons.newspaper_rounded,
                    title: 'Analyze News',
                    subtitle: 'Get sentiment from news articles',
                    onTap: () => onNavigate(1),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),

          // About section
          const Text(
            'About Sentilyze',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          const _InfoCard(
            icon: Icons.psychology_rounded,
            title: 'AI-Powered Analysis',
            subtitle:
                'Uses a transformer model trained on millions of posts to detect positive, neutral, and negative sentiment.',
          ),
          const SizedBox(height: 12),
          const _InfoCard(
            icon: Icons.bar_chart_rounded,
            title: 'Visual Insights',
            subtitle:
                'See sentiment breakdowns with interactive charts after every analysis.',
          ),
          const SizedBox(height: 12),
          const _InfoCard(
            icon: Icons.public_rounded,
            title: 'Two Data Sources',
            subtitle:
                'Bluesky social posts give you real public opinion. NewsAPI articles show the editorial perspective.',
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final Gradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 34),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
