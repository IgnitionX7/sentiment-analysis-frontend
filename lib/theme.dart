import 'package:flutter/material.dart';

// ── Colors ───────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Onboarding (light lavender)
  static const Color onboardingTop    = Color(0xFFECF0FD);
  static const Color onboardingBottom = Color(0xFFD0DAF5);

  // Guest screen (warm orange → pink)
  static const Color guestStart = Color(0xFFFF6B35);
  static const Color guestEnd   = Color(0xFFD4198C);

  // Main app (deep purple → near-black)
  static const Color bgTop    = Color(0xFF3B1B80);
  static const Color bgBottom = Color(0xFF0C0520);
  static const Color sidebar  = Color(0xFF1B0A4A);

  // Accent
  static const Color accent     = Color(0xFF7B2FFF);
  static const Color accentDark = Color(0xFF5410EE);

  // Quick-action cards
  static const Color newsStart   = Color(0xFF26C6DA);
  static const Color newsEnd     = Color(0xFF006064);
  static const Color socialStart = Color(0xFF42A5F5);
  static const Color socialEnd   = Color(0xFF1565C0);

  // Text
  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xFFB0B8D0);
  static const Color textMuted     = Color(0xFF6E7A96);

  // Glass card
  static const Color cardBg     = Color(0x1AFFFFFF); // 10% white
  static const Color cardBorder = Color(0x26FFFFFF); // 15% white

  // Sentiment
  static const Color positive = Color(0xFF4CAF50);
  static const Color neutral  = Color(0xFFFFC107);
  static const Color negative = Color(0xFFF44336);
}

// ── Gradients ─────────────────────────────────────────────────────────────────

const LinearGradient kOnboardingGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.onboardingTop, AppColors.onboardingBottom],
);

const LinearGradient kGuestGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.guestStart, AppColors.guestEnd],
);

const LinearGradient kMainGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.bgTop, AppColors.bgBottom],
);

const LinearGradient kAccentGradient = LinearGradient(
  colors: [AppColors.accent, AppColors.accentDark],
);

const LinearGradient kNewsGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.newsStart, AppColors.newsEnd],
);

const LinearGradient kSocialGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.socialStart, AppColors.socialEnd],
);

// ── Theme ─────────────────────────────────────────────────────────────────────

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.bgBottom,
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
    ),
  );
}

// ── Shared widgets ────────────────────────────────────────────────────────────

/// Pill-shaped gradient button used across all screens.
class AppGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Gradient gradient;
  final double verticalPadding;
  final double horizontalPadding;

  const AppGradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.gradient = kAccentGradient,
    this.verticalPadding = 14,
    this.horizontalPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Glass card container used for results and placeholders.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}

/// Empty-state widget reused across screens.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(24),
            borderRadius: 24,
            child: Icon(icon, color: AppColors.textSecondary, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
