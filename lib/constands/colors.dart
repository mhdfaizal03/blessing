import 'dart:ui';

class AppColors {
  // Backgrounds
  final Color kPrimaryBg = const Color(0xFF070E07); // Darkest green-black
  final Color kSecondaryBg = const Color(
    0xFF111D11,
  ); // Lighter green-black (Cards/Detail)
  final Color kSurface = const Color(
    0xFF142214,
  ); // Even lighter for Search Bars/Toggles

  // Accents
  final Color kAccentNeon = const Color(0xFF00FF00); // Vibrant Neon Green
  final Color kAccentDark = const Color(
    0xFF1B301B,
  ); // Muted Dark Green for Icons/Shapes

  // Text
  final Color kTextWhite = const Color(0xFFFFFFFF);
  final Color kTextGrey = const Color(0xFF8E8E8E);
  final Color kTextNeon = const Color(0xFF00FF00);

  // Cards & Shimmer
  final Color kCardBg = const Color(0xFF111D11);
  final Color kShimmerBase = const Color(0xFF111D11);
  final Color kShimmerHighlight = const Color(0xFF1B301B);

  // Glassy Effects
  final Color kGlassWhite = const Color(
    0x0F9E9E9E,
  ); // white.withOpacity(0.06) is ~0x0FFFFFFF but user used 0x06 which is very subtle. Actually white.withOpacity(0.06) is 0x0FFFFFFF but opacity 0.06 of 255 is 15. So 0x0FFFFFFF becomes 0x0F.
  final Color kGlassBorder = const Color(
    0x2EFFFFFF,
  ); // white.withOpacity(0.18) is ~0x2E
}
