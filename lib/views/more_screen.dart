import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:blessing/views/dua_library_screen.dart';
import 'package:blessing/views/fasting_tracker_screen.dart';
import 'package:blessing/views/habit_tracker_screen.dart';
import 'package:blessing/views/mosque_finder_screen.dart';
import 'package:blessing/views/salah_guide_screen.dart';
import 'package:blessing/views/settings_screen.dart';
import 'package:blessing/views/tasbeeh_screen.dart';
import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();
    return Scaffold(
      backgroundColor: colors.kPrimaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'More',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.kTextWhite,
            fontSize: 22,
          ),
        ),
        actions: [
          CustomCircleIconButton(
            icon: Icons.settings_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildUtilityGrid(context),
            const SizedBox(height: 30),
            Text(
              'Daily Inspiration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.kTextWhite,
              ),
            ),
            const SizedBox(height: 14),
            _buildDailyVerseCard(context),
            const SizedBox(height: 100), // Spacing for floating navbar
          ],
        ),
      ),
    );
  }

  Widget _buildUtilityGrid(BuildContext context) {
    final colors = AppColors();
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TasbeehScreen()),
            );
          },
          child: _utilityItem(colors, 'Tasbeeh', 'COUNTER', Icons.numbers_rounded, isHighlight: true),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MosqueFinderScreen()),
            );
          },
          child: _utilityItem(colors, 'Mosque Finder', 'NEARBY MOSQUES', Icons.near_me_rounded),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FastingTrackerScreen()),
            );
          },
          child: _utilityItem(colors, 'Fasting Tracker', 'RAMADAN & SUNNAH', Icons.fast_forward_rounded),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HabitTrackerScreen()),
            );
          },
          child: _utilityItem(colors, 'Habit Tracker', 'SUNNAH GOALS', Icons.check_circle_outline_rounded),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DuaLibraryScreen()),
            );
          },
          child: _utilityItem(colors, 'Dua Library', 'AZKAR & PRAYERS', Icons.menu_book_rounded),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalahGuideScreen()),
            );
          },
          child: _utilityItem(colors, 'Salah Guide', 'PRAYER STEPS', Icons.accessibility_new_rounded),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          child: _utilityItem(colors, 'Settings', 'PREFERENCES', Icons.tune_rounded),
        ),
      ],
    );
  }

  Widget _utilityItem(
    AppColors colors,
    String title,
    String sub,
    IconData icon, {
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight
            ? colors.kAccentNeon.withValues(alpha: 0.12)
            : colors.kSecondaryBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHighlight
              ? colors.kAccentNeon.withValues(alpha: 0.4)
              : colors.kGlassBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: isHighlight
                  ? colors.kAccentNeon
                  : colors.kAccentNeon.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isHighlight ? colors.kPrimaryBg : colors.kAccentNeon,
              size: 22,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: colors.kTextWhite,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              color: colors.kTextGrey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyVerseCard(BuildContext context) {
    final colors = AppColors();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.kSecondaryBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.kGlassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '"Verily, with hardship comes ease"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              height: 1.4,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: colors.kTextWhite,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 24, height: 1, color: colors.kAccentNeon),
              const SizedBox(width: 10),
              Text(
                'Surah Ash-Sharh • 94:6',
                style: TextStyle(
                  color: colors.kAccentNeon,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 24, height: 1, color: colors.kAccentNeon),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Verse copied & ready to share!"),
                    backgroundColor: colors.kCardBg,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              icon: Icon(Icons.share_outlined, size: 16, color: colors.kPrimaryBg),
              label: Text(
                'Share Verse',
                style: TextStyle(
                  color: colors.kPrimaryBg,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: colors.kAccentNeon,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
