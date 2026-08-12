import 'package:flutter/material.dart';

class AppColors {
  // Deep Obsidian Emerald Backgrounds
  final Color kPrimaryBg = const Color(0xFF050B05);
  final Color kSecondaryBg = const Color(0xFF0D170D);
  final Color kSurface = const Color(0xFF142414);
  final Color kElevatedSurface = const Color(0xFF1B2E1B);

  // Vibrant Emerald & Teal Accents
  final Color kAccentNeon = const Color(0xFF00E676);
  final Color kAccentTeal = const Color(0xFF10B981);
  final Color kAccentDark = const Color(0xFF183318);

  // Typography
  final Color kTextWhite = const Color(0xFFFFFFFF);
  final Color kTextGrey = const Color(0xFF9CA3AF);
  final Color kTextNeon = const Color(0xFF00E676);
  final Color kTextMuted = const Color(0xFF6B7280);

  // Cards & Shimmer
  final Color kCardBg = const Color(0xFF0D170D);
  final Color kShimmerBase = const Color(0xFF0D170D);
  final Color kShimmerHighlight = const Color(0xFF183318);

  // Modern Glassmorphism System Tokens
  final Color kGlassWhite = const Color(0x14FFFFFF);
  final Color kGlassBorder = const Color(0x2EFFFFFF);
  final Color kGlassHighlight = const Color(0x3DFFFFFF);

  // Reusable Component Gradients
  LinearGradient get emeraldGradient => const LinearGradient(
        colors: [Color(0xFF00E676), Color(0xFF10B981)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get glassGradient => const LinearGradient(
        colors: [Color(0x1AFFFFFF), Color(0x0AFFFFFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get darkCardGradient => const LinearGradient(
        colors: [Color(0xFF142414), Color(0xFF0D170D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
