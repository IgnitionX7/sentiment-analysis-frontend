import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'home_screen.dart';
import 'news_screen.dart';
import 'social_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';
import 'guest_screen.dart';
import 'admin_screen.dart';

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
            Container(width: 1, color: AppColors.cardBorder),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: [
                  HomeScreen(onNavigate: _navigateTo),
                  NewsScreen(onNavigate: _navigateTo),
                  SocialScreen(onNavigate: _navigateTo),
                  const CommunityScreen(),
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
            icon: Icons.people_rounded,
            label: 'Community',
            active: selectedIndex == 3,
            onTap: () => onNavigate(3),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            active: selectedIndex == 4,
            onTap: () => onNavigate(4),
          ),
          StreamBuilder<String?>(
            stream: UserService.watchCurrentUserRole(),
            builder: (context, snapshot) {
              if (snapshot.data != 'admin') return const SizedBox.shrink();
              return _NavItem(
                icon: Icons.admin_panel_settings_rounded,
                label: 'Admin',
                active: false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const AdminScreen()),
                  );
                },
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
              AuthService.signOut().then((_) {
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const GuestScreen()),
                  );
                }
              });
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
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          final name = user?.displayName ?? 'Guest User';
          final email = user?.email ?? 'guest@sentilyze.app';
          final photoUrl = user?.photoURL;

          return Row(
            children: [
              if (photoUrl != null)
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(photoUrl),
                )
              else
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: active
              ? AppColors.accent.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: active
              ? Border.all(color: AppColors.accent.withValues(alpha: 0.3))
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
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
