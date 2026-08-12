import 'dart:math';

import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  final AppColors _colors = AppColors();

  int _count = 0;
  int _target = 33;
  int _selectedDhikrIndex = 0;

  final List<Map<String, String>> _dhikrList = const [
    {
      'arabic': 'سُبْحَانَ اللَّهِ',
      'transliteration': 'SubhanAllah',
      'meaning': 'Glory be to Allah',
    },
    {
      'arabic': 'الْحَمْدُ لِلَّهِ',
      'transliteration': 'Alhamdulillah',
      'meaning': 'Praise be to Allah',
    },
    {
      'arabic': 'اللَّهُ أَكْبَرُ',
      'transliteration': 'Allahu Akbar',
      'meaning': 'Allah is the Greatest',
    },
    {
      'arabic': 'أَسْتَغْفِرُ اللَّهَ',
      'transliteration': 'Astaghfirullah',
      'meaning': 'I seek forgiveness from Allah',
    },
  ];

  void _increment() {
    setState(() {
      if (_count < _target) {
        _count++;
      } else {
        // Target reached reset or cycle next dhikr
        _count = 0;
        _selectedDhikrIndex = (_selectedDhikrIndex + 1) % _dhikrList.length;
      }
    });
  }

  void _reset() {
    setState(() => _count = 0);
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon'),
        backgroundColor: _colors.kCardBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dhikr = _dhikrList[_selectedDhikrIndex];

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
          'Tasbeeh',
          style: TextStyle(
            color: _colors.kTextWhite,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          CustomCircleIconButton(
            icon: Icons.tune_rounded,
            onTap: () => _showTargetDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onTap: _increment,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Dhikr Selector Switcher Bar
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _dhikrList.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedDhikrIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedDhikrIndex = index;
                        _count = 0;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _colors.kAccentNeon
                              : _colors.kSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? _colors.kAccentNeon
                                : _colors.kGlassBorder,
                          ),
                        ),
                        child: Text(
                          _dhikrList[index]['transliteration']!,
                          style: TextStyle(
                            color: isSelected
                                ? _colors.kPrimaryBg
                                : _colors.kTextWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Dhikr Titles
              Text(
                dhikr['arabic']!,
                style: TextStyle(
                  color: _colors.kTextWhite,
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dhikr['meaning']!,
                style: TextStyle(color: _colors.kTextGrey, fontSize: 14),
              ),

              const Spacer(),

              // Central Interactive Counter Circle
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow container
                    Container(
                      width: 290,
                      height: 290,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _colors.kAccentNeon.withValues(alpha: 0.08),
                            blurRadius: 35,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 280,
                      width: 280,
                      child: CustomPaint(
                        painter: TasbeehPainter(
                          progress: (_count / _target).clamp(0.0, 1.0),
                          color: _colors.kAccentNeon,
                          backgroundColor: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_count',
                          style: TextStyle(
                            color: _colors.kAccentNeon,
                            fontSize: 84,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -2,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _colors.kAccentNeon.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _colors.kAccentNeon.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'TARGET $_target',
                            style: TextStyle(
                              color: _colors.kAccentNeon,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Tap hint
              Text(
                'TAP ANYWHERE TO COUNT',
                style: TextStyle(
                  color: _colors.kTextMuted,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Bottom Actions Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _bottomAction(Icons.refresh_rounded, 'Reset', _reset),
                    _bottomAction(
                      Icons.history_rounded,
                      'History',
                      () => _showComingSoon('History'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTargetDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _colors.kSecondaryBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Target Goal',
              style: TextStyle(
                color: _colors.kTextWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [33, 99, 100, 500, 1000].map((t) {
                final isSelected = _target == t;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _target = t;
                      _count = 0;
                    });
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? _colors.kAccentNeon : _colors.kSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _colors.kGlassBorder),
                    ),
                    child: Text(
                      '$t',
                      style: TextStyle(
                        color: isSelected ? _colors.kPrimaryBg : _colors.kTextWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
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
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _colors.kSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _colors.kGlassBorder),
            ),
            child: Icon(icon, color: _colors.kTextWhite, size: 22),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: _colors.kTextGrey, fontSize: 12),
        ),
      ],
    );
  }
}

class TasbeehPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  TasbeehPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    final trackPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TasbeehPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.backgroundColor != backgroundColor;
}
