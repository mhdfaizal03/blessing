import 'package:blessing/constands/colors.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Quran',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 15),
          CircleAvatar(radius: 14, child: Icon(Icons.person, size: 18)),
          SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildSearchBar(),
            const SizedBox(height: 25),
            _buildContinueReadingCard(),
            const SizedBox(height: 25),
            _buildTabSwitcher(),
            const SizedBox(height: 20),
            _selectedTabIndex == 0 ? _buildSurahList() : _buildJuzList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: colors.kSurface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterData,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: Colors.grey),
          hintText: _selectedTabIndex == 0
              ? "Search Surah..."
              : "Search Juz...",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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
        ).then((_) => _loadLastRead()); // Reload when coming back
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.kSecondaryBg,
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1544947950-fa07a98d237f',
            ),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CONTINUE READING",
                      style: TextStyle(
                        color: colors.kAccentNeon,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      surahName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Ayah $ayahNum",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFF12E612),
                  child: Icon(Icons.play_arrow, color: Colors.black, size: 30),
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
        color: const Color(0xFF142214),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
            ).then((_) => _loadLastRead()); // Reload when coming back
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
        border: isLastRead
            ? Border.all(color: colors.kAccentNeon.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.star, color: colors.kAccentDark, size: 40),
              Text(
                "${surah['id']}",
                style: TextStyle(
                  color: colors.kAccentNeon,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                surah['name'], // Transliterated name (e.g. Al-Fatihah)
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "${surah['type']} • ${surah['ayahs']} AYAHS",
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
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
              fontSize: 20,
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
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.star, color: colors.kAccentDark, size: 40),
              Text(
                "${juz['id']}",
                style: TextStyle(
                  color: colors.kAccentNeon,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  juz['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  juz['description'],
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
        ],
      ),
    );
  }
}
