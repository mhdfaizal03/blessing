import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:blessing/services/local_storage_service.dart';
import 'package:blessing/services/quran_service.dart';
import 'package:blessing/views/juz_details_screen.dart';
import 'package:blessing/views/surah_details_screen.dart';
import 'package:flutter/material.dart';

class QuranSection extends StatefulWidget {
  const QuranSection({super.key});

  @override
  State<QuranSection> createState() => _QuranSectionState();
}

class _QuranSectionState extends State<QuranSection> {
  final AppColors colors = AppColors();
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
      backgroundColor: colors.kPrimaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Quran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.kTextWhite,
            fontSize: 22,
          ),
        ),
        actions: [
          CustomCircleIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notifications coming soon'),
                  backgroundColor: colors.kCardBg,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          CustomCircleIconButton(
            icon: Icons.person_outline_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Profile coming soon'),
                  backgroundColor: colors.kCardBg,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildContinueReadingCard(),
            const SizedBox(height: 24),
            _buildTabSwitcher(),
            const SizedBox(height: 20),
            _selectedTabIndex == 0 ? _buildSurahList() : _buildJuzList(),
            const SizedBox(height: 100), // Spacing for floating navbar
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.kGlassBorder),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterData,
        style: TextStyle(color: colors.kTextWhite),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: colors.kTextGrey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: colors.kTextGrey, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _filterData('');
                  },
                )
              : null,
          hintText: _selectedTabIndex == 0 ? "Search Surah by name or number..." : "Search Juz...",
          hintStyle: TextStyle(color: colors.kTextMuted, fontSize: 13),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.kSecondaryBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.kGlassBorder),
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1544947950-fa07a98d237f',
            ),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.kAccentNeon.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "LAST READ",
                    style: TextStyle(
                      color: colors.kAccentNeon,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  surahName,
                  style: TextStyle(
                    color: colors.kTextWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Ayah $ayahNum",
                  style: TextStyle(
                    color: colors.kTextGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: colors.emeraldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.kAccentNeon.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 30),
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
        color: colors.kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.kGlassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? colors.kAccentNeon
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Surah",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _selectedTabIndex == 0
                        ? colors.kPrimaryBg
                        : colors.kTextGrey,
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
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? colors.kAccentNeon
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Juz",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _selectedTabIndex == 1
                        ? colors.kPrimaryBg
                        : colors.kTextGrey,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.kSecondaryBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLastRead
              ? colors.kAccentNeon
              : colors.kGlassBorder,
          width: isLastRead ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.kAccentNeon.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: colors.kAccentNeon.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                "${surah['id']}",
                style: TextStyle(
                  color: colors.kAccentNeon,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                surah['name'],
                style: TextStyle(
                  color: colors.kTextWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 12, color: colors.kTextGrey),
                  const SizedBox(width: 4),
                  Text(
                    "${surah['type'].toString().toUpperCase()} • ${surah['ayahs']} AYAHS",
                    style: TextStyle(color: colors.kTextGrey, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            surah['arabicName'] ?? "",
            style: TextStyle(
              color: colors.kAccentNeon,
              fontSize: 22,
              fontFamily: 'Amiri',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.kSecondaryBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.kGlassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.kAccentNeon.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: colors.kAccentNeon.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                "${juz['id']}",
                style: TextStyle(
                  color: colors.kAccentNeon,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  juz['name'],
                  style: TextStyle(
                    color: colors.kTextWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  juz['description'],
                  style: TextStyle(color: colors.kTextGrey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: colors.kTextGrey, size: 14),
        ],
      ),
    );
  }
}
