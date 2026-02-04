import 'package:blessing/constands/colors.dart';
import 'package:flutter/material.dart';

class RemembranceContent extends StatelessWidget {
  const RemembranceContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: colors.kPrimaryBg, // Standardized background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                color: AppColors().kAccentNeon,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                "MORNING REMEMBRANCE",
                style: TextStyle(
                  color: colors.kAccentNeon,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Progress Bar
          const Text(
            "Session Progress  3 of 8",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 3 / 8,
            backgroundColor: colors.kTextWhite.withOpacity(0.1),
            color: colors.kAccentNeon,
            minHeight: 6,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 30),

          // Main Card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.kSecondaryBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Image Section
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Text Content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.kTextWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "\"We have reached the morning and at this very time unto Allah belongs all sovereignty...\"",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.kTextGrey,
                            fontSize: 16,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Bottom Actions
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      children: [
                        _circleButton(Icons.share),
                        const SizedBox(width: 12),
                        _circleButton(Icons.volume_up),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.black,
                            ),
                            label: Text(
                              "Share Verse",
                              style: TextStyle(
                                color: colors.kPrimaryBg,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.kAccentNeon,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(Icons.keyboard_arrow_down, color: Colors.white38),
                Text(
                  "SWIPE DOWN TO DISMISS",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white10,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class RemembranceOverlay extends StatelessWidget {
  const RemembranceOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF0D140D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "☀️ MORNING REMEMBRANCE",
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Central Content Card
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F1A),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
          const Text(
            "SWIPE DOWN TO DISMISS",
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
