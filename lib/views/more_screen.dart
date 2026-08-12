import 'package:blessing/views/dua_library_screen.dart';
import 'package:blessing/views/fasting_tracker_screen.dart';
import 'package:blessing/views/mosque_finder_screen.dart';
import 'package:blessing/views/prayer_times_screen.dart';
import 'package:blessing/views/qibla_screen.dart';
import 'package:blessing/views/salah_guide_screen.dart';
import 'package:blessing/views/settings_screen.dart';
import 'package:blessing/views/tasbeeh_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF00FF66);

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: Text(
          'More',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        actions: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.person_rounded, color: Colors.white70, size: 20),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 10),
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrayerTimesScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildGridSection(context, primaryGreen),
            const SizedBox(height: 28),
            Text(
              'Daily Verse',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            _buildDailyVerseCard(context, primaryGreen),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildGridSection(BuildContext context, Color primaryGreen) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.15,
      children: [
        _buildGridItem(
          context,
          title: "Qibla",
          sub: "DIRECTION",
          icon: Icons.explore_rounded,
          primaryGreen: primaryGreen,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaScreen())),
        ),
        _buildGridItem(
          context,
          title: "Mosque Finder",
          sub: "NEARBY",
          icon: Icons.map_rounded,
          primaryGreen: primaryGreen,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MosqueFinderScreen())),
        ),
        _buildGridItem(
          context,
          title: "Tasbeeh",
          sub: "COUNTER",
          icon: Icons.tag_rounded,
          primaryGreen: primaryGreen,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbeehScreen())),
        ),
        _buildGridItem(
          context,
          title: "Salah Guide",
          sub: "STEP BY STEP",
          icon: Icons.accessibility_new_rounded,
          primaryGreen: primaryGreen,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalahGuideScreen())),
        ),
        _buildGridItem(
          context,
          title: "Fasting Tracker",
          sub: "FASTING GOALS",
          icon: Icons.fast_rewind_rounded,
          primaryGreen: primaryGreen,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FastingTrackerScreen())),
        ),
        _buildGridItem(
          context,
          title: "Favorites",
          sub: "SAVED DUAS",
          icon: Icons.favorite_rounded,
          primaryGreen: primaryGreen,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DuaLibraryScreen())),
        ),
        _buildGridItem(
          context,
          title: "Duas",
          sub: "PRAYERS",
          icon: Icons.notes_rounded,
          primaryGreen: primaryGreen,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DuaLibraryScreen())),
        ),
        _buildGridItem(
          context,
          title: "Settings",
          sub: "PREFERENCES",
          icon: Icons.settings_rounded,
          primaryGreen: primaryGreen,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
      ],
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required String sub,
    required IconData icon,
    required Color primaryGreen,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131924),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryGreen, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: GoogleFonts.outfit(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyVerseCard(BuildContext context, Color primaryGreen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
            style: GoogleFonts.amiri(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "\"Indeed, with hardship will come ease.\"",
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "Surah Ash-Sharh (94:6)",
            style: GoogleFonts.outfit(color: primaryGreen, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
