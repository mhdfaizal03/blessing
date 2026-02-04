import 'dart:ui';

import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:blessing/views/qibla_screen.dart';
import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  // Theme Constants
  static Color kAccentGreen = AppColors().kAccentNeon;
  static Color kCardBg = AppColors().kCardBg;
  static Color kTextGrey = AppColors().kTextGrey;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: Text(
          'More',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.kTextWhite,
          ),
        ),

        actions: [
          CustomCircleIconButton(icon: Icons.person, onTap: () {}),

          CustomCircleIconButton(icon: Icons.notifications, onTap: () {}),
          const SizedBox(width: 10),
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
              "Daily Verse",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.kTextWhite,
              ),
            ),
            const SizedBox(height: 15),
            _buildDailyVerseCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilityGrid(BuildContext context) {
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
              MaterialPageRoute(builder: (context) => QiblaScreen()),
            );
          },
          child: _utilityItem("Qibla", "DIRECTION", Icons.explore),
        ),
        GestureDetector(
          onTap: () {},
          child: _utilityItem("Mosque Finder", "NEARBY", Icons.map),
        ),
        GestureDetector(
          onTap: () {},
          child: _utilityItem("Tasbeeh", "COUNTER", Icons.numbers),
        ),
        GestureDetector(
          onTap: () {},
          child: _utilityItem(
            "Fasting Tracker",
            "FASTING GOALS",
            Icons.fast_forward,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: _utilityItem(
            "Habit Tracker",
            "HABIT GOALS",
            Icons.calendar_today,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: _utilityItem("Settings", "PREFERENCES", Icons.settings),
        ),
      ],
    );
  }

  Widget _utilityItem(String title, String sub, IconData icon) {
    final colors = AppColors();
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // glass layer
            color: colors.kGlassWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.kGlassBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // icon bubble
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.kAccentDark.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.kTextWhite.withOpacity(0.15),
                  ),
                ),
                child: Icon(icon, color: colors.kAccentNeon, size: 24),
              ),

              const Spacer(),

              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colors.kTextWhite,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                sub,
                style: TextStyle(
                  color: colors.kTextGrey,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyVerseCard() {
    final colors = AppColors();
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        children: [
          // Dark gradient overlay (for readability)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
            ),
          ),

          // Glass layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: colors.kGlassWhite,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: colors.kGlassBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "“Verily, with hardship comes ease”",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
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
                      Container(
                        width: 28,
                        height: 1,
                        color: colors.kAccentNeon,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Surah Ash-Sharh • 94:6",
                        style: TextStyle(
                          color: colors.kAccentNeon,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 28,
                        height: 1,
                        color: colors.kAccentNeon,
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.share,
                        size: 18,
                        color: colors.kPrimaryBg,
                      ),
                      label: Text(
                        "Share Verse",
                        style: TextStyle(
                          color: colors.kPrimaryBg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: colors.kAccentNeon,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
