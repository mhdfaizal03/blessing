import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class SalahGuideScreen extends StatefulWidget {
  const SalahGuideScreen({super.key});

  @override
  State<SalahGuideScreen> createState() => _SalahGuideScreenState();
}

class _SalahGuideScreenState extends State<SalahGuideScreen> {
  final AppColors _colors = AppColors();
  int _currentStepIndex = 0;

  final List<Map<String, dynamic>> _salahSteps = const [
    {
      "title": "1. Takbir al-Ihram",
      "subtitle": "Starting Prayer",
      "arabic": "اللَّهُ أَكْبَرُ",
      "transliteration": "Allahu Akbar",
      "meaning": "Allah is the Greatest",
      "icon": Icons.pan_tool_rounded,
      "reps": 1,
    },
    {
      "title": "2. Qiyam",
      "subtitle": "Standing Position",
      "icon": Icons.accessibility_new_rounded,
      "sections": [
        {
          "label": "Opening Dua (Thana):",
          "arabic": "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلَا إِلَهَ غَيْرُكَ",
          "transliteration": "Subhanak Allahumma wa bihamdika, wa tabaraka ismuka, wa ta'ala jadduka, wa la ilaha ghairuk",
          "meaning": "Glory and praise be to You, O Allah. Blessed is Your Name, exalted is Your Majesty, and there is no god but You.",
        },
        {
          "label": "Ta'awwudh:",
          "arabic": "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ",
          "transliteration": "A'udhu billahi min ash-shaytan ir-rajim",
          "meaning": "I seek refuge in Allah from the accursed Satan.",
        },
        {
          "label": "Tasmiyah:",
          "arabic": "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
          "transliteration": "Bismillah ir-Rahman ir-Rahim",
          "meaning": "In the name of Allah, the Most Gracious, the Most Merciful.",
        },
        {
          "label": "Surah Al-Fatiha:",
          "subtitle": "Followed by a short Surah (e.g., Surah Ikhlas).",
        },
      ],
    },
    {
      "title": "3. Ruku",
      "subtitle": "Bowing Position",
      "arabic": "سُبْحَانَ رَبِّيَ الْعَظِيمِ",
      "transliteration": "Subhana Rabbiyal 'Azim",
      "meaning": "Glory to my Lord, the Most Great",
      "icon": Icons.airline_seat_recline_extra_rounded,
      "reps": 3,
    },
    {
      "title": "4. Standing After Ruku",
      "subtitle": "Rising from Bowing",
      "icon": Icons.accessibility_rounded,
      "sections": [
        {
          "arabic": "سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ",
          "transliteration": "Sami'Allahu liman hamidah",
          "meaning": "Allah hears those who praise Him.",
        },
        {
          "arabic": "رَبَّنَا وَلَكَ الْحَمْدُ",
          "transliteration": "Rabbana wa lakal hamd",
          "meaning": "Our Lord, praise is for You.",
        },
      ],
    },
    {
      "title": "5. Sujud",
      "subtitle": "Prostration",
      "arabic": "سُبْحَانَ رَبِّيَ الأَعْلَى",
      "transliteration": "Subhana Rabbiyal A'la",
      "meaning": "Glory to my Lord, the Most High",
      "icon": Icons.downhill_skiing_rounded,
      "reps": 3,
    },
    {
      "title": "6. Jalsa",
      "subtitle": "Sitting Between Two Prostrations",
      "arabic": "رَبِّ اغْفِرْ لِي",
      "transliteration": "Rabbighfir li",
      "meaning": "My Lord, forgive me.",
      "icon": Icons.event_seat_rounded,
    },
    {
      "title": "7. Tashahhud",
      "subtitle": "Final Sitting",
      "arabic": "التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ، وَأَشْهَدُ أَنَّ مُحَمَّداً عَبْدُهُ وَرَسُولُهُ",
      "transliteration": "At-tahiyyatu lillahi, was-salawatu wat-tayyibatu. As-salamu 'alayka ayyuhan-nabiyyu wa rahmatullahi wa barakatuh. As-salamu 'alayna wa 'ala 'ibadillahis-salihin. Ashhadu an la ilaha illallah, wa ashhadu anna Muhammadan 'abduhu wa rasuluh.",
      "meaning": "All greetings, prayers, and pure words are for Allah. Peace be upon you, O Prophet, and the mercy and blessings of Allah. Peace be upon us and on all righteous servants of Allah. I bear witness that there is no god but Allah, and I bear witness that Muhammad is His servant and Messenger.",
      "icon": Icons.self_improvement_rounded,
    },
    {
      "title": "8. Salawat",
      "subtitle": "Blessings on the Prophet",
      "arabic": "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ",
      "transliteration": "Allahumma salli 'ala Muhammad wa 'ala ali Muhammad, kama sallaita 'ala Ibrahim wa 'ala ali Ibrahim, innaka hameedun majid",
      "meaning": "O Allah, send Your blessings upon Muhammad and the family of Muhammad, as You blessed Ibrahim and the family of Ibrahim. Indeed, You are Praiseworthy, Glorious.",
      "icon": Icons.favorite_rounded,
    },
    {
      "title": "9. Final Dua",
      "subtitle": "Before Salam",
      "arabic": "رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِنْ ذُرِّيَّتِي، رَبَّنَا وَتَقَبَّلْ دُعَاءِ، رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ",
      "transliteration": "Rabbij'alni muqima as-salati wa min dhurriyyati, Rabbana wa taqabbal du'a, Rabbana-ghfir li wa li-walidayya wa lil-mu'minin yawma yaqumu al-hisab",
      "meaning": "O my Lord! Make me and my offspring steadfast in prayer. O our Lord, accept my supplication. O our Lord, forgive me, my parents, and the believers on the Day of Judgment.",
      "icon": Icons.auto_awesome_rounded,
    },
    {
      "title": "10. Salam",
      "subtitle": "Ending Prayer",
      "arabic": "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ",
      "transliteration": "Assalamu alaikum wa rahmatullah",
      "meaning": "Peace and mercy of Allah be upon you",
      "icon": Icons.done_all_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final step = _salahSteps[_currentStepIndex];
    final sections = step['sections'] as List<Map<String, String>>?;

    return Scaffold(
      backgroundColor: _colors.kPrimaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CustomCircleIconButton(
          icon: Icons.keyboard_arrow_left_rounded,
          onTap: () => Navigator.pop(context),
        ),
        title: Text(
          'Step-by-Step Salah Guide',
          style: TextStyle(
            color: _colors.kTextWhite,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Step Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "STEP ${_currentStepIndex + 1} OF ${_salahSteps.length}",
                        style: TextStyle(
                          color: _colors.kAccentNeon,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        step['title'] as String,
                        style: TextStyle(
                          color: _colors.kTextWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentStepIndex + 1) / _salahSteps.length,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      color: _colors.kAccentNeon,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Step Content Card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _colors.kSecondaryBg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: _colors.kGlassBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _colors.kAccentNeon.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              step['icon'] as IconData? ?? Icons.star_rounded,
                              color: _colors.kAccentNeon,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step['title'] as String,
                                  style: TextStyle(
                                    color: _colors.kTextWhite,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  step['subtitle'] as String,
                                  style: TextStyle(color: _colors.kTextGrey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          if (step.containsKey('reps'))
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _colors.kAccentNeon,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Repeat ${step['reps']}x",
                                style: TextStyle(
                                  color: _colors.kPrimaryBg,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Divider(color: _colors.kGlassBorder),
                      const SizedBox(height: 20),

                      if (step.containsKey('arabic')) ...[
                        Text(
                          step['arabic'] as String,
                          style: TextStyle(
                            color: _colors.kTextWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Amiri',
                            height: 1.6,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          step['transliteration'] as String,
                          style: TextStyle(
                            color: _colors.kAccentNeon,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "\"${step['meaning']!}\"",
                          style: TextStyle(
                            color: _colors.kTextGrey,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],

                      if (sections != null) ...[
                        ...sections.map((sec) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (sec.containsKey('label'))
                                  Text(
                                    sec['label']!,
                                    style: TextStyle(
                                      color: _colors.kAccentNeon,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (sec.containsKey('arabic')) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    sec['arabic']!,
                                    style: TextStyle(
                                      color: _colors.kTextWhite,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Amiri',
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                                if (sec.containsKey('transliteration')) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    sec['transliteration']!,
                                    style: TextStyle(
                                      color: _colors.kAccentNeon,
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                                if (sec.containsKey('meaning')) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "\"${sec['meaning']!}\"",
                                    style: TextStyle(color: _colors.kTextGrey, fontSize: 12),
                                  ),
                                ],
                                if (sec.containsKey('subtitle')) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    sec['subtitle']!,
                                    style: TextStyle(color: _colors.kTextGrey, fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Step Navigators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  if (_currentStepIndex > 0)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _currentStepIndex--),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text("Previous Step"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colors.kSurface,
                          foregroundColor: _colors.kTextWhite,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: _colors.kGlassBorder),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  if (_currentStepIndex > 0 && _currentStepIndex < _salahSteps.length - 1)
                    const SizedBox(width: 12),
                  if (_currentStepIndex < _salahSteps.length - 1)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _currentStepIndex++),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: const Text("Next Step"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colors.kAccentNeon,
                          foregroundColor: _colors.kPrimaryBg,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
