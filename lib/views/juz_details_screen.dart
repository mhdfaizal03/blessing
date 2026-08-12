import 'dart:async';
import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:blessing/services/local_storage_service.dart';
import 'package:blessing/services/quran_service.dart';
import 'package:blessing/views/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;

class JuzDetailScreen extends StatefulWidget {
  final int juzNumber;
  const JuzDetailScreen({super.key, required this.juzNumber});

  @override
  State<JuzDetailScreen> createState() => _JuzDetailScreenState();
}

class _JuzDetailScreenState extends State<JuzDetailScreen> {
  final AppColors colors = AppColors();
  final Color primaryGreen = const Color(0xFF00FF66);
  final QuranService _quranService = QuranService();
  final LocalStorageService _storageService = LocalStorageService();
  final AudioPlayer _player = AudioPlayer();
  final ScrollController _scrollController = ScrollController();

  int _currentAyahPlaying = -1;
  int _currentSurahPlaying = -1;
  int _currentFlatIndex = 0;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  bool _showTranslation = true;

  // Auto Scroll Controls
  bool _isAutoScrolling = false;
  double _scrollSpeed = 20.0;
  Timer? _autoScrollTimer;

  final Map<String, GlobalKey> _juzAyahKeys = {};
  final List<Map<String, int>> _allFlatVerses = [];
  late Map<int, List<int>> _juzData;

  @override
  void initState() {
    super.initState();
    _juzData = quran.getSurahAndVersesFromJuz(widget.juzNumber);
    _juzData.forEach((surahNum, verses) {
      for (var verseNum in verses) {
        _allFlatVerses.add({'surah': surahNum, 'ayah': verseNum});
      }
    });

    if (_allFlatVerses.isNotEmpty) {
      _currentSurahPlaying = _allFlatVerses[0]['surah']!;
      _currentAyahPlaying = _allFlatVerses[0]['ayah']!;
    }

    _setupAudio();
    _loadLastRead();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _player.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLastRead() async {
    final last = await _storageService.getLastRead();
    if (last != null) {
      if (mounted) {
        final index = _allFlatVerses.indexWhere(
          (v) => v['surah'] == last['surah'] && v['ayah'] == last['ayah'],
        );
        if (index != -1) {
          setState(() {
            _currentFlatIndex = index;
            _currentSurahPlaying = last['surah']!;
            _currentAyahPlaying = last['ayah']!;
          });
        }
      }
    }
  }

  void _scrollToAyah(int surahNum, int verseNum) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _juzAyahKeys["${surahNum}_$verseNum"];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
          alignment: 0.38,
        );
      }
    });
  }

  void _setupAudio() {
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _isPlaying = false;
            _playNextAyah();
          }
        });
      }
    });
  }

  Future<void> _playAyah(int surahNum, int ayahNumber) async {
    try {
      if (_currentAyahPlaying == ayahNumber &&
          _currentSurahPlaying == surahNum &&
          _player.audioSource != null) {
        if (_isPlaying) {
          await _player.pause();
        } else {
          if (_player.processingState == ProcessingState.completed) {
            await _player.seek(Duration.zero);
          }
          await _player.play();
        }
        return;
      }

      final index = _allFlatVerses.indexWhere(
        (v) => v['surah'] == surahNum && v['ayah'] == ayahNumber,
      );

      setState(() {
        _isLoadingAudio = true;
        _currentAyahPlaying = ayahNumber;
        _currentSurahPlaying = surahNum;
        if (index != -1) _currentFlatIndex = index;
      });

      _scrollToAyah(surahNum, ayahNumber);
      await _storageService.saveLastRead(surahNum, ayahNumber);

      final url = _quranService.getAudioUrl(surahNum, ayahNumber);
      await _player.setUrl(url);
      await _player.play();

      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
        });
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
          _isPlaying = false;
        });
      }
    }
  }

  void _playNextAyah() {
    if (_currentFlatIndex + 1 < _allFlatVerses.length) {
      final next = _allFlatVerses[_currentFlatIndex + 1];
      _playAyah(next['surah']!, next['ayah']!);
    }
  }

  void _toggleAutoScroll(bool enable) {
    setState(() {
      _isAutoScrolling = enable;
    });

    if (enable) {
      _startAutoScroll();
    } else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll() {
    _stopAutoScroll();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_scrollController.hasClients) return;
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.offset;
      double delta = (_scrollSpeed * 0.05);

      if (currentScroll + delta >= maxScroll) {
        _scrollController.jumpTo(maxScroll);
        _toggleAutoScroll(false);
      } else {
        _scrollController.jumpTo(currentScroll + delta);
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Center(
          child: CustomCircleIconButton(
            icon: Icons.keyboard_arrow_left_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "Juz ${widget.juzNumber}",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "${_allFlatVerses.length} VERSES",
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: Colors.white54,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildViewToggle(),
            const SizedBox(height: 20),
            _buildJuzContent(),
            if (!_showTranslation) ...[
              const SizedBox(height: 20),
              _buildAutoScrollControls(),
            ],
            const SizedBox(height: 140),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomPlayerControls(),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showTranslation = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _showTranslation ? primaryGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: _showTranslation ? Colors.black : Colors.white60,
                  size: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showTranslation = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !_showTranslation ? primaryGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: !_showTranslation ? Colors.black : Colors.white60,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJuzContent() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _juzData.keys.length,
      itemBuilder: (context, index) {
        final surahNum = _juzData.keys.elementAt(index);
        final verses = _juzData[surahNum]!;
        final surahDetails = _quranService.getSurahDetails(surahNum);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131924),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryGreen.withValues(alpha: 0.15),
                    child: Text(
                      "$surahNum",
                      style: GoogleFonts.outfit(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surahDetails['name'] ?? '',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${surahDetails['englishMeaning']} • Verses ${verses.first}-${verses.last}",
                        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (surahNum != 9) ...[
              Center(
                child: Text(
                  _quranService.getBasmala(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(fontSize: 24, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
            ],

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: verses.length,
              itemBuilder: (ctx, vIndex) {
                final verseNum = verses[vIndex];
                return _buildVerseItem(surahNum, verseNum);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildVerseItem(int surahNum, int verseNum) {
    final keyStr = "${surahNum}_$verseNum";
    final key = _juzAyahKeys.putIfAbsent(keyStr, () => GlobalKey());
    final arabic = _quranService.getVerseArabic(surahNum, verseNum);
    final translation = _quranService.getVerseTranslation(surahNum, verseNum);
    final isCurrentlyPlaying =
        _currentSurahPlaying == surahNum && _currentAyahPlaying == verseNum;
    final isPlayingAudio = isCurrentlyPlaying && _isPlaying;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Ayah $verseNum",
                  style: GoogleFonts.outfit(
                    color: primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _playAyah(surahNum, verseNum),
                icon: _isLoadingAudio && isCurrentlyPlaying
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryGreen,
                        ),
                      )
                    : Icon(
                        isPlayingAudio
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: primaryGreen,
                        size: 28,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              "$arabic ﴿$verseNum﴾",
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                fontSize: 26,
                height: 2.2,
                color: isCurrentlyPlaying ? primaryGreen : Colors.white,
                fontWeight: isCurrentlyPlaying ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (_showTranslation) ...[
            const SizedBox(height: 10),
            Text(
              translation,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.08)),
        ],
      ),
    );
  }

  Widget _buildAutoScrollControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Scroll Speed",
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: primaryGreen,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                    thumbColor: primaryGreen,
                  ),
                  child: Slider(
                    value: _scrollSpeed,
                    min: 5.0,
                    max: 50.0,
                    onChanged: (val) {
                      setState(() {
                        _scrollSpeed = val;
                      });
                      if (_isAutoScrolling) {
                        _startAutoScroll();
                      }
                    },
                  ),
                ),
              ),
              Text(
                "${_scrollSpeed.toInt()} px/s",
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Auto Scroll",
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
              ),
              Switch(
                value: _isAutoScrolling,
                onChanged: _toggleAutoScroll,
                activeThumbColor: primaryGreen,
                activeTrackColor: primaryGreen.withValues(alpha: 0.3),
                inactiveThumbColor: Colors.white38,
                inactiveTrackColor: Colors.white10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPlayerControls() {
    final surahName = _quranService.getSurahName(_currentSurahPlaying > 0 ? _currentSurahPlaying : 1);

    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              surahName,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_currentSurahPlaying > 0 && _currentAyahPlaying > 0) {
                _playAyah(_currentSurahPlaying, _currentAyahPlaying);
              }
            },
            child: Container(
              width: 54,
              height: 54,
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
              child: Center(
                child: _isLoadingAudio
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 34,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: Icon(Icons.settings_rounded, color: primaryGreen, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Audio reciter: Mishary Alafasy"),
                  backgroundColor: const Color(0xFF131924),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
