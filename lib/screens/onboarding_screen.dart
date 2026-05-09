import 'package:flutter/material.dart';
import '../theme.dart';
import 'guest_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  static const int _total = 3;

  void _next() {
    if (_page < _total - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _toGuest();
    }
  }

  void _toGuest() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GuestScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kOnboardingGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Page content
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _buildPage1(),
                    _buildPage2(),
                    _buildPage3(),
                  ],
                ),
              ),

              // Bottom controls
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_total, (i) {
                        final active = i == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.accent
                                : AppColors.accent.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),
                    // Buttons row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _toGuest,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppGradientButton(
                            label: _page == _total - 1
                                ? 'Get Started'
                                : 'Next',
                            icon: Icons.arrow_forward_rounded,
                            onTap: _next,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Page builders ──────────────────────────────────────────────────────────

  Widget _buildPage1() {
    return _OnboardingPageLayout(
      iconData: Icons.auto_awesome_rounded,
      iconColors: const [Color(0xFF9B59FF), Color(0xFF6B1FEE)],
      title: 'Welcome to Sentilyze',
      subtitle:
          'Analyze emotions and sentiments in social media posts and news articles with advanced AI technology.',
    );
  }

  Widget _buildPage2() {
    return _OnboardingPageLayout(
      iconData: Icons.description_outlined,
      iconColors: const [Color(0xFF6B8EFF), Color(0xFF3B5BDB)],
      title: 'Multiple Input Options',
      subtitle:
          'Choose from news analysis or social media sentiment to get started.',
      tiles: const [
        _TileInfo(icon: Icons.newspaper_rounded, label: 'Analyze News'),
        _TileInfo(icon: Icons.cloud_rounded, label: 'Social Media'),
      ],
    );
  }

  Widget _buildPage3() {
    return _OnboardingPageLayout(
      iconData: Icons.bar_chart_rounded,
      iconColors: const [Color(0xFF9B59FF), Color(0xFF6B1FEE)],
      title: 'Insights & Visualizations',
      subtitle:
          'Get detailed visualizations and insights to understand sentiment patterns better.',
      tiles: const [
        _TileInfo(icon: Icons.donut_large_rounded, label: 'Visualizations'),
      ],
    );
  }
}

// ── Supporting widgets ─────────────────────────────────────────────────────────

class _TileInfo {
  final IconData icon;
  final String label;
  const _TileInfo({required this.icon, required this.label});
}

class _OnboardingPageLayout extends StatelessWidget {
  final IconData iconData;
  final List<Color> iconColors;
  final String title;
  final String subtitle;
  final List<_TileInfo> tiles;

  const _OnboardingPageLayout({
    required this.iconData,
    required this.iconColors,
    required this.title,
    required this.subtitle,
    this.tiles = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: iconColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: iconColors.last.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(iconData, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 36),
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
          if (tiles.isNotEmpty) ...[
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: tiles.map((t) {
                return Container(
                  width: 130,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(t.icon, color: AppColors.accent, size: 30),
                      const SizedBox(height: 10),
                      Text(
                        t.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
