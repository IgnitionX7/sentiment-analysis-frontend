import 'package:flutter/material.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'news_screen.dart';
import 'social_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'guest_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _navigateTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      body: Container(
        decoration: const BoxDecoration(gradient: kMainGradient),
        child: Row(
          children: [
            _AppSidebar(
              selectedIndex: _index,
              onNavigate: _navigateTo,
            ),
            // Vertical divider
            Container(width: 1, color: AppColors.cardBorder),
            // Content
            Expanded(
              child: IndexedStack(
                index: _index,
                children: [
                  HomeScreen(onNavigate: _navigateTo),
                  NewsScreen(onNavigate: _navigateTo),
                  SocialScreen(onNavigate: _navigateTo),
                  const HistoryScreen(),
                  const ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavigate;

  const _AppSidebar({
    required this.selectedIndex,
    required this.onNavigate,
  });

  // Treat indices 0, 1, 2 (Home + analysis screens) as "Home" active
  bool get _homeActive => selectedIndex <= 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          _buildUserInfo(),
          const SizedBox(height: 28),
          Divider(
              color: Colors.white.withValues(alpha: 0.08),
              height: 1,
              indent: 16,
              endIndent: 16),
          const SizedBox(height: 12),
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            active: _homeActive,
            onTap: () => onNavigate(0),
          ),
          _NavItem(
            icon: Icons.history_rounded,
            label: 'History',
            active: selectedIndex == 3,
            onTap: () => onNavigate(3),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            active: selectedIndex == 4,
            onTap: () => onNavigate(4),
          ),
          _NavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            active: false,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Settings coming soon!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
          ),
          const Spacer(),
          Divider(
              color: Colors.white.withValues(alpha: 0.08),
              height: 1,
              indent: 16,
              endIndent: 16),
          const SizedBox(height: 8),
          _NavItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            active: false,
            isLogout: true,
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const GuestScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: kAccentGradient,
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guest User',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'guest@sentilyze.app',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nav item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool isLogout;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLogout
        ? Colors.redAccent.shade100
        : active
            ? Colors.white
            : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: active
              ? AppColors.accent.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: active
              ? Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
