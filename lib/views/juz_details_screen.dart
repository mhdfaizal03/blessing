import 'package:blessing/constands/colors.dart';
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

  late Map<int, List<int>> _juzData;

  @override
  void initState() {
    super.initState();
    _juzData = quran.getSurahAndVersesFromJuz(widget.juzNumber);
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

  void _setupAudio() {
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
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

      // Save to local storage
      await _storageService.saveLastRead(surahNum, ayahNumber);

      final url = _quranService.getAudioUrl(surahNum, ayahNumber);
      await _player.setUrl(url);
      await _player.play();

      setState(() {
        _isLoadingAudio = false;
      });
    } catch (e) {
      debugPrint("Error playing audio: $e");
      setState(() {
        _isLoadingAudio = false;
        _isPlaying = false;
      });
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
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
              color: AppColors().kAccentNeon.withOpacity(0.1),
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
    final arabic = _quranService.getVerseArabic(surahNum, verseNum);
    final translation = _quranService.getVerseTranslation(surahNum, verseNum);
    final isPlaying =
        _currentAyahPlaying == verseNum &&
        _currentSurahPlaying == surahNum &&
        _isPlaying;
    final isLastRead =
        _lastPlayedAyah == verseNum && _lastPlayedSurah == surahNum;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: isLastRead ? const EdgeInsets.all(12) : null,
      decoration: isLastRead
          ? BoxDecoration(
              color: colors.kAccentNeon.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: colors.kAccentNeon.withOpacity(0.2)),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colors.kAccentNeon,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    "$verseNum",
                    style: TextStyle(
                      color: colors.kPrimaryBg,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: colors.kAccentNeon,
                            size: 28,
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
