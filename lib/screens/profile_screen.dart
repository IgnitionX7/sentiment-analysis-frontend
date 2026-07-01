import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import 'guest_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) return _buildGuestView(context);
        return _buildUserView(context, user);
      },
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          const AppEmptyState(
            icon: Icons.lock_outline_rounded,
            title: 'Sign In to Access Your Profile',
            subtitle:
                'Create an account to share analyses and join the community.',
          ),
          const SizedBox(height: 28),
          Center(
            child: AppGradientButton(
              label: 'Sign In with Google',
              icon: Icons.login_rounded,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const GuestScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserView(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
          GlassCard(
            padding: const EdgeInsets.all(24),
            borderRadius: 20,
            child: Row(
              children: [
                if (user.photoURL != null)
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(user.photoURL!),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: kAccentGradient,
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 32),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'User',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? '',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(4),
            borderRadius: 16,
            child: ListTile(
              leading: const Icon(Icons.logout_rounded,
                  color: Colors.redAccent, size: 22),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                AuthService.signOut().then((_) {
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => const GuestScreen()),
                    );
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
