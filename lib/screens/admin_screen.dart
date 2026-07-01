import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../models/app_user.dart';
import '../services/user_service.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      body: Container(
        decoration: const BoxDecoration(gradient: kMainGradient),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 24, 20),
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Panel',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Manage users and roles',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // User list
            Expanded(
              child: StreamBuilder<List<AppUser>>(
                stream: UserService.getAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accent),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: AppEmptyState(
                        icon: Icons.error_outline_rounded,
                        title: 'Failed to load users',
                        subtitle: snapshot.error.toString(),
                      ),
                    );
                  }
                  final users = snapshot.data ?? [];
                  if (users.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'No users yet',
                      subtitle: 'Users appear here after they sign in.',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: users.length,
                    itemBuilder: (context, i) =>
                        _UserTile(user: users[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isSelf = currentUid == user.uid;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 14,
        child: Row(
          children: [
            // Avatar
            _Avatar(photoUrl: user.photoUrl, name: user.displayName),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.displayName.isEmpty ? 'Unknown' : user.displayName,
                          style: TextStyle(
                            color: user.disabled
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelf) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: user.disabled
                          ? AppColors.textMuted
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.disabled)
                    const Text(
                      'Disabled',
                      style: TextStyle(
                          color: AppColors.negative,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Role toggle (disabled for self)
            if (!isSelf) ...[
              _RoleChip(
                isAdmin: user.isAdmin,
                onToggle: () => _toggleRole(context, user),
              ),
              const SizedBox(width: 8),

              // Disable/Enable button
              GestureDetector(
                onTap: () => _toggleDisabled(context, user),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: user.disabled
                        ? AppColors.positive.withValues(alpha: 0.12)
                        : AppColors.negative.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: user.disabled
                          ? AppColors.positive.withValues(alpha: 0.4)
                          : AppColors.negative.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    user.disabled ? 'Enable' : 'Disable',
                    style: TextStyle(
                      color: user.disabled
                          ? AppColors.positive
                          : AppColors.negative,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ] else
              _RoleChip(isAdmin: user.isAdmin, onToggle: null),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleRole(BuildContext context, AppUser user) async {
    final newRole = user.isAdmin ? 'user' : 'admin';
    final label = user.isAdmin ? 'remove admin from' : 'make admin';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E0D40),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Role',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to $label ${user.displayName}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await UserService.updateUserRole(user.uid, newRole);
    }
  }

  Future<void> _toggleDisabled(BuildContext context, AppUser user) async {
    final action = user.disabled ? 'enable' : 'disable';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E0D40),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${user.disabled ? 'Enable' : 'Disable'} User',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to $action ${user.displayName}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              user.disabled ? 'Enable' : 'Disable',
              style: TextStyle(
                  color: user.disabled
                      ? AppColors.positive
                      : AppColors.negative),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await UserService.setUserDisabled(user.uid, !user.disabled);
    }
  }
}

class _RoleChip extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback? onToggle;

  const _RoleChip({required this.isAdmin, this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: isAdmin ? kAccentGradient : null,
          color: isAdmin ? null : AppColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isAdmin
                ? AppColors.accent.withValues(alpha: 0.6)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAdmin
                  ? Icons.admin_panel_settings_rounded
                  : Icons.person_rounded,
              size: 13,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              isAdmin ? 'Admin' : 'User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  const _Avatar({this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null) {
      return CircleAvatar(
          radius: 20, backgroundImage: NetworkImage(photoUrl!));
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.accent.withValues(alpha: 0.3),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }
}
