import 'dart:ui';
import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:blessing/services/local_storage_service.dart';
import 'package:blessing/services/quran_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:marquee/marquee.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final int? initialAyah;
  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    this.initialAyah,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final AppColors colors = AppColors();
  final QuranService _quranService = QuranService();
  final LocalStorageService _storageService = LocalStorageService();
  final AudioPlayer _player = AudioPlayer();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic> _surahDetails = {};
  int _totalAyahs = 0;
  int _currentAyahPlaying = -1;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  bool _showTranslation = true;
  int? _lastPlayedAyah;

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _setupAudio();
    _loadLastRead();

    if (widget.initialAyah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playAyah(widget.initialAyah!);
        // Basic scroll attempt
        _scrollToAyah(widget.initialAyah!);
      });
    }
  }

  Future<void> _loadLastRead() async {
    final last = await _storageService.getLastRead();
    if (last != null && last['surah'] == widget.surahNumber) {
      if (mounted) {
        setState(() {
          _lastPlayedAyah = last['ayah'];
        });
      }
    }
  }

  void _scrollToAyah(int ayah) {
    // Very simple rough estimation: average height of verse is ~250
    // Not perfect but better than nothing without extra packages
    double offset = (ayah - 1) * 200.0;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _loadDetails() {
    _surahDetails = _quranService.getSurahDetails(widget.surahNumber);
    _totalAyahs = _surahDetails['ayahs'] as int;
    setState(() {});
  }

  Future<void> _setupAudio() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _isPlaying = false;
            // Auto play next verse
            if (_currentAyahPlaying != -1 &&
                _currentAyahPlaying < _totalAyahs) {
              _playAyah(_currentAyahPlaying + 1);
            } else {
              _currentAyahPlaying = -1;
            }
          }
        });
      }
    });
  }

  Future<void> _playAyah(int ayahNumber) async {
    try {
      if (_currentAyahPlaying == ayahNumber) {
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
        _lastPlayedAyah = ayahNumber;
      });

      // Save to local storage
      await _storageService.saveLastRead(widget.surahNumber, ayahNumber);

      final url = _quranService.getAudioUrl(widget.surahNumber, ayahNumber);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.kSecondaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CustomCircleIconButton(
          icon: Icons.keyboard_arrow_left_rounded,
          onTap: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              _surahDetails['name'] ??
                  '', // Transliterated name (e.g. Al-Fatihah)
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              _surahDetails['englishMeaning']?.toUpperCase() ??
                  '', // English Meaning
              style: TextStyle(fontSize: 10, color: colors.kTextGrey),
            ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${_surahDetails['type']}',
                style: TextStyle(
                  color: colors.kAccentNeon,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildViewToggle(),
                const SizedBox(height: 30),
                _buildBismillah(),
                SizedBox(height: _showTranslation ? 10 : 20),
                _showTranslation ? _buildVersesList() : _buildMushafView(),
                const SizedBox(height: 100), // Spacing for bottom sheet
              ],
            ),
          ),
          // We can remove the fixed bottom sheet or make it dynamic.
          // For now, let's keep the player controls at the bottom nav bar.
        ],
      ),
      bottomNavigationBar: _buildPlayerControls(),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildViewToggle() {
    return Container(
      width: 150,

      // padding: const EdgeInsets.only(left: 5, right: 5),
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

  Widget _buildBismillah() {
    return Center(
      child: Text(
        _quranService.getBasmala(),
        textAlign: TextAlign.center,
        style: GoogleFonts.amiri(fontSize: 24, color: colors.kTextWhite),
      ),
    );
  }

  Widget _buildVersesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _totalAyahs,
      itemBuilder: (context, index) {
        final verseNum = index + 1;
        return _buildVerseItem(verseNum);
      },
    );
  }

  Widget _buildMushafView() {
    return Container(
      decoration: BoxDecoration(
        color: colors.kGlassWhite,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(15),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            children: List.generate(_totalAyahs, (index) {
              final verseNum = index + 1;
              final arabic = _quranService.getVerseArabic(
                widget.surahNumber,
                verseNum,
              );
              final isPlaying = _currentAyahPlaying == verseNum;

              return TextSpan(
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => _playAyah(verseNum),
                      child: Text(
                        arabic,
                        style: GoogleFonts.amiri(
                          fontSize: 24,
                          height: 2.2,
                          fontWeight: verseNum == _currentAyahPlaying
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: verseNum == _currentAyahPlaying
                              ? colors.kAccentNeon
                              : colors.kTextWhite,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: " "),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildVerseItem(int verseNum) {
    final arabic = _quranService.getVerseArabic(widget.surahNumber, verseNum);
    final translation = _quranService.getVerseTranslation(
      widget.surahNumber,
      verseNum,
    );
    final isPlaying = _currentAyahPlaying == verseNum && _isPlaying;
    final isLastRead = _lastPlayedAyah == verseNum;

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
          // Action Bar for Verse
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.kAccentNeon.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Ayah $verseNum",
                  style: TextStyle(
                    color: colors.kAccentNeon,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _playAyah(verseNum),
                icon: _isLoadingAudio && _currentAyahPlaying == verseNum
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.kAccentNeon,
                        ),
                      )
                    : Icon(
                        isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle_outline,
                        color: colors.kAccentNeon,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Arabic Text
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              arabic,
              textAlign: TextAlign.justify,
              style: GoogleFonts.amiri(
                fontSize: 26,
                height: 2.2,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Translation
          Text(
            translation,
            style: TextStyle(
              color: colors.kTextGrey,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: colors.kTextWhite.withOpacity(0.1)),
        ],
      ),
    );
  }

  Widget _buildMarqueeOrText(String text, TextStyle style) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.rtl,
        )..layout();

        if (textPainter.width <= constraints.maxWidth) {
          return Center(
            child: Text(
              text,
              style: style,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          );
        } else {
          return SizedBox(
            height: 25,
            child: Marquee(
              text: "$text    ",
              style: style,
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: 50.0,
              velocity: 30.0,
              pauseAfterRound: const Duration(seconds: 2),
              startPadding: 10.0,
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          );
        }
      },
    );
  }

  Widget _buildPlayerControls() {
    // Simplified Controls for now - showing current status
    final style = TextStyle(
      color: colors.kTextWhite,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );

    return Container(
      height: 80,
      color: AppColors().kPrimaryBg,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _currentAyahPlaying != -1
                ? _buildMarqueeOrText(
                    _quranService.getVerseArabic(
                      widget.surahNumber,
                      _currentAyahPlaying,
                    ),
                    style,
                  )
                : _buildMarqueeOrText(_surahDetails['name'] ?? '', style),
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
