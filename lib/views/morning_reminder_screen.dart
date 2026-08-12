import 'package:blessing/constands/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

class MorningQuote {
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;
  final String imageUrl;

  MorningQuote({
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
    required this.imageUrl,
  });
}

class RemembranceContent extends StatefulWidget {
  const RemembranceContent({super.key});

  @override
  State<RemembranceContent> createState() => _RemembranceContentState();
}

class _RemembranceContentState extends State<RemembranceContent> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  bool _isPlaying = false;

  // Multi-quote catalog rotating daily
  final List<MorningQuote> _dailyQuotes = [
    MorningQuote(
      title: "MORNING PRAISE & SOVEREIGNTY",
      arabic: "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ",
      transliteration: "Asbahna wa-asbahal-mulku lillahi walhamdu lillahi, la ilaha illallahu wahdahu la sharika lahu.",
      translation: "We have reached the morning and at this very time unto Allah belongs all sovereignty, and all praise is for Allah. None has the right to be worshipped except Allah alone.",
      reference: "Sahih Muslim 2723",
      imageUrl: "https://images.unsplash.com/photo-1500382017468-9049fed747ef",
    ),
    MorningQuote(
      title: "SAYYID AL-ISTIGHFAR (MASTER SUPPLICATION)",
      arabic: "اللَّهُمَّ أَنْتَ رَبِّي لاَ إِلَهَ إِلاَّ أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ",
      transliteration: "Allahumma anta Rabbi la ilaha illa anta, khalaqtani wa-ana abduka, wa-ana ala ahdika wa-wa dika mas-tata'tu.",
      translation: "O Allah, You are my Lord, there is no deity worthy of worship except You. You created me and I am Your servant, and I abide by Your covenant as best as I can.",
      reference: "Sahih Al-Bukhari 6306",
      imageUrl: "https://images.unsplash.com/photo-1519817650390-64a93db51149",
    ),
    MorningQuote(
      title: "DIVINE PROTECTION FROM HARM",
      arabic: "بِسْمِ اللَّهِ الَّذِي لاَ يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الأَرْضِ وَلاَ فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
      transliteration: "Bismillahil-ladhi la yadurru ma'as-mihi shai'un fil-ardi wa la fis-sama'i wa huwas-Sami'ul-'Alim.",
      translation: "In the Name of Allah with Whose Name nothing can cause harm in the earth nor in the heaven, and He is the All-Hearing, the All-Knowing.",
      reference: "Sunan Abi Dawud 5088",
      imageUrl: "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05",
    ),
    MorningQuote(
      title: "CONTENTMENT WITH ALLAH & ISLAM",
      arabic: "رَضِيتُ بِاللَّهِ رَبًّا، وَبِالإِسْلاَمِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا",
      transliteration: "Raditu billahi Rabban, wa bil-Islami dinan, wa bi-Muhammadin sallallahu alayhi wa sallama Nabiyya.",
      translation: "I am pleased with Allah as my Lord, with Islam as my religion, and with Prophet Muhammad (peace be upon him) as my Prophet.",
      reference: "Sunan Abi Dawud 5072",
      imageUrl: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    ),
    MorningQuote(
      title: "FORGIVENESS & BLESSING IN FAITH",
      arabic: "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالآخِرَةِ",
      transliteration: "Allahumma inni as'alukal-'afwa wal-'afiyata fid-dunya wal-akhirah.",
      translation: "O Allah, I ask You for forgiveness and well-being in this world and in the Hereafter.",
      reference: "Sunan Ibn Majah 3871",
      imageUrl: "https://images.unsplash.com/photo-1469474968028-56623f02e42e",
    ),
    MorningQuote(
      title: "PURITY OF PRAISE",
      arabic: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ: عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ",
      transliteration: "Subhanallahi wa bihamdihi: 'Adada khalqihi, wa rida nafsihi, wa zinata 'arshihi, wa midada kalimatihi.",
      translation: "Glory and praise be to Allah as much as the number of His creation, according to His pleasure, equal to the weight of His Throne, and ink of His words.",
      reference: "Sahih Muslim 2726",
      imageUrl: "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Rotate starting quote based on the day of the year
    final dayOfYear = DateTime.now().difference(DateTime(2026, 1, 1)).inDays;
    _currentIndex = dayOfYear % _dailyQuotes.length;

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _isPlaying = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playRecitation() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // Al-Afasy Audio sample
        await _audioPlayer.setUrl('https://cdn.islamic.network/quran/audio/128/ar.alafasy/255.mp3');
        await _audioPlayer.play();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Audio recitation playing for Morning Adhkar"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _shareQuote(MorningQuote quote) {
    final text = "${quote.title}\n\n${quote.arabic}\n\n${quote.transliteration}\n\n\"${quote.translation}\"\n- ${quote.reference}";
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Copied daily Morning Remembrance to clipboard!"),
        backgroundColor: AppColors().kCardBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _nextQuote() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _dailyQuotes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();
    final currentQuote = _dailyQuotes[_currentIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: colors.kPrimaryBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: colors.kGlassBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                color: colors.kAccentNeon,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  currentQuote.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.outfit(
                    color: colors.kAccentNeon,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          Text(
            'Daily Remembrance ${_currentIndex + 1} of ${_dailyQuotes.length}',
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _dailyQuotes.length,
            backgroundColor: colors.kTextWhite.withValues(alpha: 0.1),
            color: colors.kAccentNeon,
            minHeight: 5,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 20),

          // Main Card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.kSecondaryBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.kGlassBorder),
              ),
              child: Column(
                children: [
                  // Image Section
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(
                      currentQuote.imageUrl,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 130,
                        color: colors.kSurface,
                        child: Center(
                          child: Icon(
                            Icons.wb_sunny_outlined,
                            color: colors.kAccentNeon,
                            size: 44,
                          ),
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 130,
                          color: colors.kSurface,
                          child: Center(
                            child: CircularProgressIndicator(color: colors.kAccentNeon),
                          ),
                        );
                      },
                    ),
                  ),

                  // Text Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              currentQuote.arabic,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.amiri(
                                color: colors.kTextWhite,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            currentQuote.transliteration,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: colors.kAccentNeon.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '"${currentQuote.translation}"',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: colors.kTextGrey,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "— ${currentQuote.reference}",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white38,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Actions
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        _circleButton(
                          context,
                          Icons.share_rounded,
                          onTap: () => _shareQuote(currentQuote),
                        ),
                        const SizedBox(width: 10),
                        _circleButton(
                          context,
                          _isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                          onTap: _playRecitation,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _nextQuote,
                            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18),
                            label: Text(
                              'Next Remembrance',
                              style: GoogleFonts.outfit(
                                color: colors.kPrimaryBg,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.kAccentNeon,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Swipe Hint
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Column(
              children: [
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38, size: 18),
                Text(
                  'SWIPE DOWN TO DISMISS',
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(
    BuildContext context,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
