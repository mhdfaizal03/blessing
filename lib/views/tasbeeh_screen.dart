import 'dart:math';
import 'package:flutter/material.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int count = 33;
  final int target = 100;

  void increment() {
    setState(() {
      if (count < target) count++;
    });
  }

  void reset() {
    setState(() => count = 0);
  }

  @override
  Widget build(BuildContext context) {
    const kBgColor = Color(0xFF071207);
    const kAccentGreen = Color(0xFF12E612);

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: GestureDetector(
        onTap: increment, // Tap anywhere to increment
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "سُبْحَانَ اللَّهِ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Glory be to Allah",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),

            const Spacer(),

            // Central Counter with Progress
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 280,
                    width: 280,
                    child: CustomPaint(
                      painter: TasbeehPainter(
                        progress: count / target,
                        color: kAccentGreen,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$count",
                        style: const TextStyle(
                          color: kAccentGreen,
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF112511),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Text(
                          "TARGET $target",
                          style: const TextStyle(
                            color: kAccentGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _bottomAction(Icons.refresh, "Reset", reset),
                  _bottomAction(Icons.history, "History", () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomAction(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF111D11),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

class TasbeehPainter extends CustomPainter {
  final double progress;
  final Color color;

  TasbeehPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // 1. Draw Background Track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw Progress Arc with Glow
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.solid,
        3,
      ); // The "Neon Glow" effect

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
