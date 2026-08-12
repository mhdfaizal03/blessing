import 'package:blessing/constands/colors.dart';
import 'package:blessing/services/local_storage_service.dart';
import 'package:blessing/services/quran_service.dart';
import 'package:blessing/views/juz_details_screen.dart';
import 'package:blessing/views/prayer_times_screen.dart';
import 'package:blessing/views/surah_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuranSection extends StatefulWidget {
  const QuranSection({super.key});

  @override
  State<QuranSection> createState() => _QuranSectionState();
}

class _QuranSectionState extends State<QuranSection> {
  final AppColors colors = AppColors();
  final Color primaryGreen = const Color(0xFF00FF66);
  final QuranService _quranService = QuranService();
  final LocalStorageService _storageService = LocalStorageService();

  List<Map<String, dynamic>> _allSurahs = [];
  List<Map<String, dynamic>> _filteredSurahs = [];
  List<Map<String, dynamic>> _allJuz = [];
  List<Map<String, dynamic>> _filteredJuz = [];
  int _selectedTabIndex = 0; // 0 for Surah, 1 for Juz
  final TextEditingController _searchController = TextEditingController();

  Map<String, int>? _lastRead;
  Map<String, dynamic>? _lastSurahData;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
    _loadLastRead();
  }

  Future<void> _loadLastRead() async {
    final last = await _storageService.getLastRead();
    if (last != null) {
      final surahData = _quranService.getSurahDetails(last['surah']!);
      setState(() {
        _lastRead = last;
        _lastSurahData = surahData;
      });
    }
  }

  void _loadSurahs() {
    final surahs = _quranService.getAllSurahs();
    final juz = _quranService.getAllJuz();
    setState(() {
      _allSurahs = surahs;
      _filteredSurahs = surahs;
      _allJuz = juz;
      _filteredJuz = juz;
    });
  }

  void _filterData(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSurahs = _allSurahs;
        _filteredJuz = _allJuz;
      });
      return;
    }

    final q = query.toLowerCase();
    setState(() {
      _filteredSurahs = _allSurahs.where((surah) {
        final name = surah['name'].toString().toLowerCase();
        final meaning = surah['englishMeaning'].toString().toLowerCase();
        final id = surah['id'].toString();
        return name.contains(q) || meaning.contains(q) || id.contains(q);
      }).toList();

      _filteredJuz = _allJuz.where((juz) {
        final name = juz['name'].toString().toLowerCase();
        final id = juz['id'].toString();
        return name.contains(q) || id.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: Text(
          'Quran',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrayerTimesScreen()),
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
          children: [
            const SizedBox(height: 10),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildContinueReadingCard(),
            const SizedBox(height: 20),
            _buildTabSwitcher(),
            const SizedBox(height: 16),
            _selectedTabIndex == 0 ? _buildSurahList() : _buildJuzList(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterData,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          icon: const Icon(Icons.search_rounded, color: Colors.white38, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.white38, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _filterData('');
                  },
                )
              : null,
          hintText: _selectedTabIndex == 0 ? "Search Surah..." : "Search Juz...",
          hintStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildContinueReadingCard() {
    final surahName = _lastSurahData?['name'] ?? "Al-Fatihah";
    final ayahNum = _lastRead?['ayah'] ?? 1;
    final surahNum = _lastRead?['surah'] ?? 1;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SurahDetailScreen(surahNumber: surahNum, initialAyah: ayahNum),
          ),
        ).then((_) => _loadLastRead());
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF131924),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Opacity(
                  opacity: 0.12,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1609599006353-e629aaabfeae',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CONTINUE READING",
                      style: GoogleFonts.outfit(
                        color: primaryGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      surahName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Ayah $ayahNum",
                      style: GoogleFonts.outfit(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.play_arrow_rounded, color: Colors.black, size: 34),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? primaryGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Surah",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _selectedTabIndex == 0
                        ? Colors.black
                        : Colors.white60,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? primaryGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Juz",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _selectedTabIndex == 1
                        ? Colors.black
                        : Colors.white60,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredSurahs.length,
      itemBuilder: (context, index) {
        final surah = _filteredSurahs[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SurahDetailScreen(surahNumber: surah['id']),
              ),
            ).then((_) => _loadLastRead());
          },
          child: _buildSurahItem(surah),
        );
      },
    );
  }

  Widget _buildSurahItem(Map<String, dynamic> surah) {
    final isLastRead = _lastRead?['surah'] == surah['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLastRead
              ? primaryGreen
              : Colors.white.withValues(alpha: 0.06),
          width: isLastRead ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Star Icon with Surah Number inside
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 44,
                  color: primaryGreen.withValues(alpha: 0.15),
                ),
                Text(
                  "${surah['id']}",
                  style: GoogleFonts.outfit(
                    color: primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah['name'],
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 12, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text(
                      "${surah['type'].toString().toUpperCase()} • ${surah['ayahs']} AYAHS",
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            surah['arabicName'] ?? "",
            style: GoogleFonts.amiri(
              color: primaryGreen,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredJuz.length,
      itemBuilder: (context, index) {
        final juz = _filteredJuz[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JuzDetailScreen(juzNumber: juz['id']),
              ),
            ).then((_) => _loadLastRead());
          },
          child: _buildJuzItem(juz),
        );
      },
    );
  }

  Widget _buildJuzItem(Map<String, dynamic> juz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 44,
                  color: primaryGreen.withValues(alpha: 0.15),
                ),
                Text(
                  "${juz['id']}",
                  style: GoogleFonts.outfit(
                    color: primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  juz['name'],
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  juz['description'],
                  style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
        ],
      ),
    );
  }
}
