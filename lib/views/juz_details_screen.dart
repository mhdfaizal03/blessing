import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:blessing/services/local_storage_service.dart';
import 'package:blessing/services/quran_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:quran/quran.dart' as quran;

class JuzDetailScreen extends StatefulWidget {
  final int juzNumber;
  const JuzDetailScreen({super.key, required this.juzNumber});

  @override
  State<JuzDetailScreen> createState() => _JuzDetailScreenState();
}

class _JuzDetailScreenState extends State<JuzDetailScreen> {
  final AppColors colors = AppColors();
  final QuranService _quranService = QuranService();
  final LocalStorageService _storageService = LocalStorageService();
  final AudioPlayer _player = AudioPlayer();
  final ScrollController _scrollController = ScrollController();

  int _currentAyahPlaying = -1;
  int _currentSurahPlaying = -1;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  bool _showTranslation = true;
  int? _lastPlayedAyah;
  int? _lastPlayedSurah;
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
    _setupAudio();
    _loadLastRead();
  }

  Future<void> _loadLastRead() async {
    final last = await _storageService.getLastRead();
    if (last != null) {
      if (mounted) {
        setState(() {
          _lastPlayedAyah = last['ayah'];
          _lastPlayedSurah = last['surah'];
        });
      }
    }
  }

  void _scrollToAyah(int surahNum, int verseNum) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _juzAyahKeys["${surahNum}_$verseNum"];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          alignment: 0.25,
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
            // Auto play next verse in Juz
            final currentIndex = _allFlatVerses.indexWhere(
              (v) =>
                  v['surah'] == _currentSurahPlaying &&
                  v['ayah'] == _currentAyahPlaying,
            );
            if (currentIndex != -1 &&
                currentIndex + 1 < _allFlatVerses.length) {
              final next = _allFlatVerses[currentIndex + 1];
              _playAyah(next['surah']!, next['ayah']!);
            } else {
              _currentAyahPlaying = -1;
              _currentSurahPlaying = -1;
            }
          }
        });
      }
    });
  }

  Future<void> _playAyah(int surahNum, int ayahNumber) async {
    try {
      if (_currentAyahPlaying == ayahNumber &&
          _currentSurahPlaying == surahNum) {
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

      setState(() {
        _isLoadingAudio = true;
        _currentAyahPlaying = ayahNumber;
        _currentSurahPlaying = surahNum;
        _lastPlayedAyah = ayahNumber;
        _lastPlayedSurah = surahNum;
      });

      // Smooth auto-scroll to the active verse
      _scrollToAyah(surahNum, ayahNumber);

      // Save to local storage
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

  @override
  void dispose() {
    _player.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().kPrimaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CustomCircleIconButton(
          icon: Icons.keyboard_arrow_left_rounded,
          onTap: () => Navigator.pop(context),
        ),
        title: Text(
          "Juz ${widget.juzNumber}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildViewToggle(),
                const SizedBox(height: 30),
                _showTranslation ? _buildVersesList() : _buildMushafView(),
                const SizedBox(height: 100), // Spacing for bottom sheet
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildPlayerControls(),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: colors.kGlassWhite,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          _toggleItem(Icons.notes, _showTranslation, () {
            setState(() => _showTranslation = true);
          }),
          _toggleItem(Icons.menu_book_rounded, !_showTranslation, () {
            setState(() => _showTranslation = false);
          }),
        ],
      ),
    );
  }

  Widget _toggleItem(IconData icon, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? colors.kAccentNeon : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            icon,
            color: isActive ? colors.kPrimaryBg : colors.kTextGrey,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildVersesList() {
    List<Widget> children = [];
    _juzData.forEach((surahNum, verses) {
      children.add(_buildSurahHeader(surahNum));
      for (var verseNum in verses) {
        children.add(_buildVerseItem(surahNum, verseNum));
      }
    });

    return Column(children: children);
  }

  Widget _buildSurahHeader(int surahNum) {
    final surahName = quran.getSurahName(surahNum);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors().kAccentNeon.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Surah $surahName",
              style: TextStyle(
                color: colors.kAccentNeon,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const Expanded(child: Divider(indent: 10, color: Colors.white12)),
        ],
      ),
    );
  }

  Widget _buildMushafView() {
    List<InlineSpan> spans = [];
    _juzData.forEach((surahNum, verses) {
      // Add surah name in mushaf view too? Maybe just a distinct color or divider
      spans.add(
        TextSpan(
          text: "\n\n Surah ${quran.getSurahName(surahNum)} \n\n",
          style: const TextStyle(color: Colors.grey, fontSize: 14, height: 2),
        ),
      );

      for (var verseNum in verses) {
        final arabic = _quranService.getVerseArabic(surahNum, verseNum);
        final isPlaying =
            _currentAyahPlaying == verseNum && _currentSurahPlaying == surahNum;

        spans.add(
          WidgetSpan(
            child: GestureDetector(
              onTap: () => _playAyah(surahNum, verseNum),
              child: Text(
                arabic,
                style: GoogleFonts.amiri(
                  fontSize: 24,
                  height: 2.2,
                  color: isPlaying ? colors.kAccentNeon : colors.kTextWhite,
                ),
              ),
            ),
          ),
        );
        spans.add(const TextSpan(text: " "));
      }
    });

    return Container(
      padding: const EdgeInsets.all(15),
      child: Directionality(
        textDirection:
            TextDirection.ltr, // Matches user's recent change for Mushaf
        child: RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(children: spans),
        ),
      ),
    );
  }

  Widget _buildVerseItem(int surahNum, int verseNum) {
    final key = _juzAyahKeys.putIfAbsent(
      "${surahNum}_$verseNum",
      () => GlobalKey(),
    );
    final arabic = _quranService.getVerseArabic(surahNum, verseNum);
    final translation = _quranService.getVerseTranslation(surahNum, verseNum);
    final isCurrentlyPlaying =
        _currentAyahPlaying == verseNum && _currentSurahPlaying == surahNum;
    final isPlayingAudio = isCurrentlyPlaying && _isPlaying;
    final isLastRead =
        _lastPlayedAyah == verseNum && _lastPlayedSurah == surahNum;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrentlyPlaying
            ? colors.kAccentNeon.withValues(alpha: 0.08)
            : (isLastRead
                ? colors.kAccentNeon.withValues(alpha: 0.03)
                : colors.kSurface.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentlyPlaying
              ? colors.kAccentNeon
              : (isLastRead
                  ? colors.kAccentNeon.withValues(alpha: 0.3)
                  : colors.kGlassBorder),
          width: isCurrentlyPlaying ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCurrentlyPlaying
                      ? colors.kAccentNeon
                      : colors.kAccentNeon.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Ayah $verseNum",
                  style: TextStyle(
                    color: isCurrentlyPlaying
                        ? colors.kPrimaryBg
                        : colors.kAccentNeon,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  IconButton(
                    icon:
                        _isLoadingAudio &&
                            _currentAyahPlaying == verseNum &&
                            _currentSurahPlaying == surahNum
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.kAccentNeon,
                            ),
                          )
                        : Icon(
                            isPlayingAudio
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: colors.kAccentNeon,
                            size: 26,
                          ),
                    onPressed: () => _playAyah(surahNum, verseNum),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            arabic,
            textAlign: TextAlign.right,
            style: GoogleFonts.amiri(
              fontSize: 26,
              height: 1.8,
              color: colors.kTextWhite,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            translation,
            style: TextStyle(
              color: colors.kTextGrey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    final style = TextStyle(
      color: colors.kTextWhite,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );

    String playingText = "Juz ${widget.juzNumber}";
    if (_currentAyahPlaying != -1) {
      final surahName = quran.getSurahName(_currentSurahPlaying);
      playingText = "$surahName Ayah $_currentAyahPlaying";
    }

    return Container(
      height: 80,
      color: AppColors().kPrimaryBg,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textPainter = TextPainter(
                  text: TextSpan(text: playingText, style: style),
                  maxLines: 1,
                  textDirection: TextDirection.ltr,
                )..layout();

                if (textPainter.width <= constraints.maxWidth) {
                  return Center(child: Text(playingText, style: style));
                } else {
                  return SizedBox(
                    height: 25,
                    child: Marquee(
                      text: "$playingText    ",
                      style: style,
                      blankSpace: 50.0,
                      velocity: 30.0,
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 20),
          CircleAvatar(
            radius: 28,
            backgroundColor: colors.kAccentNeon,
            child: IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                color: colors.kPrimaryBg,
                size: 30,
              ),
              onPressed: () {
                if (_currentAyahPlaying != -1) {
                  if (_isPlaying) {
                    _player.pause();
                  } else {
                    _player.play();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
