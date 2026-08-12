import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DuaItem {
  final String id;
  final String category;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;
  final String repeatCount;
  final String? audioUrl;

  DuaItem({
    required this.id,
    required this.category,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
    this.repeatCount = '1x',
    this.audioUrl,
  });
}

class DuaLibraryScreen extends StatefulWidget {
  const DuaLibraryScreen({super.key});

  @override
  State<DuaLibraryScreen> createState() => _DuaLibraryScreenState();
}

class _DuaLibraryScreenState extends State<DuaLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _selectedCategory = 'All';
  Set<String> _bookmarkedIds = {};
  bool _showBookmarksOnly = false;
  String? _currentlyPlayingId;
  bool _isPlaying = false;

  final List<String> _categories = [
    'All',
    'Morning',
    'Evening',
    'After Prayer',
    'Sleep & Wake',
    'Protection',
    'Travel',
    'Gratitude'
  ];

  final List<DuaItem> _allDuas = [
    DuaItem(
      id: 'dua_1',
      category: 'Morning',
      title: 'Morning Remembrance',
      arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ',
      transliteration: 'Asbahna wa-asbahal-mulku lillahi walhamdu lillahi, la ilaha illallahu wahdahu la sharika lahu.',
      translation: 'We have reached the morning and at this very time unto Allah belongs all sovereignty, and all praise is for Allah. None has the right to be worshipped except Allah alone.',
      reference: 'Sahih Muslim',
      repeatCount: '1x',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3',
    ),
    DuaItem(
      id: 'dua_2',
      category: 'Morning',
      title: 'Sayyid al-Istighfar (Master Supplication)',
      arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لاَ إِلَهَ إِلاَّ أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
      transliteration: 'Allahumma anta Rabbi la ilaha illa anta, khalaqtani wa-ana abduka, wa-ana ala ahdika wa-wa dika mas-tata\'tu.',
      translation: 'O Allah, You are my Lord, there is no deity worthy of worship except You. You created me and I am Your servant, and I abide by Your covenant as best as I can.',
      reference: 'Sahih Al-Bukhari',
      repeatCount: '1x',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/255.mp3',
    ),
    DuaItem(
      id: 'dua_3',
      category: 'Evening',
      title: 'Protection from Harm',
      arabic: 'بِسْمِ اللَّهِ الَّذِي لاَ يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الأَرْضِ وَلاَ فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      transliteration: 'Bismillahil-ladhi la yadurru ma\'as-mihi shai\'un fil-ardi wa la fis-sama\'i wa huwas-Sami\'ul-\'Alim.',
      translation: 'In the Name of Allah with Whose Name nothing can cause harm in the earth nor in the heaven, and He is the All-Hearing, the All-Knowing.',
      reference: 'Sunan Abi Dawud',
      repeatCount: '3x',
    ),
    DuaItem(
      id: 'dua_4',
      category: 'Evening',
      title: 'Evening Supplication for Wellbeing',
      arabic: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
      transliteration: 'Allahumma bika amsayna, wa bika asbahna, wa bika nahya, wa bika namutu wa ilaykal-masir.',
      translation: 'O Allah, by You we enter the evening and by You we enter the morning, by You we live and by You we die, and to You is the final return.',
      reference: 'At-Tirmidhi',
      repeatCount: '1x',
    ),
    DuaItem(
      id: 'dua_5',
      category: 'After Prayer',
      title: 'Ayat al-Kursi',
      arabic: 'اللَّهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ',
      transliteration: 'Allahu la ilaha illa huwal-Hayyul-Qayyum, la ta\'khuthuhu sinatun wa la nawm, lahu ma fis-samawati wa ma fil-ard.',
      translation: 'Allah! There is no deity except Him, the Ever-Living, the Sustainer of all existence. Neither drowsiness overtakes Him nor sleep.',
      reference: 'Surah Al-Baqarah 2:255',
      repeatCount: '1x',
      audioUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/255.mp3',
    ),
    DuaItem(
      id: 'dua_6',
      category: 'After Prayer',
      title: 'Seeking Forgiveness after Salah',
      arabic: 'أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ، اللَّهُمَّ أَنْتَ السَّلاَمُ وَمِنْكَ السَّلاَمُ تَبَارَكْتَ يَا ذَا الْجَلاَلِ وَالإِكْرَامِ',
      transliteration: 'Astaghfirullah (3x), Allahumma antas-Salamu wa minkas-salamu, tabarakta ya Dhal-Jalali wal-Ikram.',
      translation: 'I seek Allah\'s forgiveness (3x). O Allah, You are Peace and from You comes peace. Blessed are You, O Possessor of Majesty and Honor.',
      reference: 'Sahih Muslim',
      repeatCount: '1x',
    ),
    DuaItem(
      id: 'dua_7',
      category: 'Sleep & Wake',
      title: 'Before Going to Sleep',
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      transliteration: 'Bismika Allahumma amutu wa ahya.',
      translation: 'In Your Name, O Allah, I die and I live.',
      reference: 'Sahih Al-Bukhari',
      repeatCount: '1x',
    ),
    DuaItem(
      id: 'dua_8',
      category: 'Sleep & Wake',
      title: 'Upon Waking Up',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      transliteration: 'Alhamdu lillahil-ladhi ahyana ba\'da ma amatana wa ilayhin-nushur.',
      translation: 'All praise is due to Allah Who gave us life after causing us to die, and unto Him is the resurrection.',
      reference: 'Sahih Al-Bukhari',
      repeatCount: '1x',
    ),
    DuaItem(
      id: 'dua_9',
      category: 'Protection',
      title: 'Dua in Times of Distress',
      arabic: 'لاَ إِلَهَ إِلاَّ أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      transliteration: 'La ilaha illa anta subhanaka inni kuntu minadh-dhalimin.',
      translation: 'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
      reference: 'Surah Al-Anbiya 21:87',
      repeatCount: 'Anytime',
    ),
    DuaItem(
      id: 'dua_10',
      category: 'Travel',
      title: 'Dua for Journey & Vehicle',
      arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
      transliteration: 'Subhanal-ladhi sakkhara lana hadha wa ma kunna lahu muqrinin, wa inna ila Rabbina lamunqalibun.',
      translation: 'Glory be to Him Who has subjected this to us, when we could never have accomplished it by ourselves. And surely, to our Lord we shall return.',
      reference: 'Surah Az-Zukhruf 43:13-14',
      repeatCount: '1x',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _currentlyPlayingId = null;
            _isPlaying = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarkedIds = (prefs.getStringList('bookmarked_duas') ?? []).toSet();
    });
  }

  Future<void> _toggleBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_bookmarkedIds.contains(id)) {
        _bookmarkedIds.remove(id);
      } else {
        _bookmarkedIds.add(id);
      }
    });
    await prefs.setStringList('bookmarked_duas', _bookmarkedIds.toList());
  }

  Future<void> _playAudio(DuaItem item) async {
    if (item.audioUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio recitation for this Dua will be available soon.')),
      );
      return;
    }

    try {
      if (_currentlyPlayingId == item.id && _isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.setUrl(item.audioUrl!);
        await _audioPlayer.play();
        setState(() {
          _currentlyPlayingId = item.id;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  void _copyToClipboard(DuaItem item) {
    final textToCopy = '${item.title}\n\n${item.arabic}\n\n${item.transliteration}\n\n"${item.translation}"\n- Reference: ${item.reference}';
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied Dua to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<DuaItem> get _filteredDuas {
    final query = _searchController.text.trim().toLowerCase();
    return _allDuas.where((dua) {
      final matchesCategory = _selectedCategory == 'All' || dua.category == _selectedCategory;
      final matchesBookmark = !_showBookmarksOnly || _bookmarkedIds.contains(dua.id);
      final matchesSearch = query.isEmpty ||
          dua.title.toLowerCase().contains(query) ||
          dua.transliteration.toLowerCase().contains(query) ||
          dua.translation.toLowerCase().contains(query) ||
          dua.arabic.contains(query);
      return matchesCategory && matchesBookmark && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Hisn al-Muslim & Dua Library',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showBookmarksOnly ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _showBookmarksOnly ? primaryColor : Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _showBookmarksOnly = !_showBookmarksOnly;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search Duas, translations, or keywords...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.6)),
                ),
              ),
            ),
          ),

          // Categories Horizontal Chips List
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category && !_showBookmarksOnly;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _showBookmarksOnly = false;
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: primaryColor,
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? primaryColor : Colors.white10,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Main Dua List
          Expanded(
            child: _filteredDuas.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: _filteredDuas.length,
                    itemBuilder: (context, index) {
                      final dua = _filteredDuas[index];
                      final isBookmarked = _bookmarkedIds.contains(dua.id);
                      final isPlayingThis = _currentlyPlayingId == dua.id && _isPlaying;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isPlayingThis
                                ? primaryColor.withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.08),
                            width: isPlayingThis ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Top Bar: Category badge, repeat count, bookmark, copy
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      dua.category.toUpperCase(),
                                      style: GoogleFonts.outfit(
                                        color: primaryColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      dua.repeatCount,
                                      style: GoogleFonts.outfit(
                                        color: Colors.amberAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      isPlayingThis ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                      color: isPlayingThis ? primaryColor : Colors.white70,
                                      size: 26,
                                    ),
                                    onPressed: () => _playAudio(dua),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                      color: isBookmarked ? primaryColor : Colors.white54,
                                      size: 22,
                                    ),
                                    onPressed: () => _toggleBookmark(dua.id),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.copy_rounded, color: Colors.white54, size: 20),
                                    onPressed: () => _copyToClipboard(dua),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Dua Title
                              Text(
                                dua.title,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Arabic Text Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                ),
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    dua.arabic,
                                    style: GoogleFonts.amiri(
                                      color: const Color(0xFFF8FAFC),
                                      fontSize: 22,
                                      height: 1.8,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Transliteration
                              Text(
                                dua.transliteration,
                                style: GoogleFonts.outfit(
                                  color: primaryColor.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // English Translation
                              Text(
                                '"${dua.translation}"',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Reference Footer
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(Icons.menu_book_rounded, color: Colors.white38, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    dua.reference,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white38,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showBookmarksOnly ? Icons.bookmark_outline_rounded : Icons.search_off_rounded,
            size: 64,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          Text(
            _showBookmarksOnly ? 'No bookmarked Duas yet' : 'No matching Duas found',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showBookmarksOnly
                ? 'Tap the bookmark icon on any Dua to save it here.'
                : 'Try searching with different keywords or select another category.',
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
