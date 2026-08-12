import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:blessing/constands/colors.dart';
import 'package:blessing/services/local_storage_service.dart';
import 'package:blessing/services/notification_service.dart';
import 'package:blessing/services/prayer_time_service.dart';
import 'package:blessing/services/quran_service.dart';
import 'package:blessing/views/habit_tracker_screen.dart';
import 'package:blessing/views/prayer_times_screen.dart';
import 'package:blessing/views/settings_screen.dart';
import 'package:blessing/views/surah_details_screen.dart';
import 'package:blessing/views/tasbeeh_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AppColors colors = AppColors();
  final Color primaryGreen = const Color(0xFF00FF66);

  // Services & State
  final PrayerTimeService _prayerService = PrayerTimeService();
  final LocalStorageService _storageService = LocalStorageService();
  final QuranService _quranService = QuranService();
  PrayerTimes? _prayerTimes;
  bool _isLoading = true;

  Map<String, int>? _lastRead;
  Map<String, dynamic>? _lastSurahData;

  String _timeRemaining = "00:00:00";
  Timer? _timer;
  Position? _currentPosition;
  String _currentAddress = "Kozhikode, India";
  String _nextPrayerName = "DHUHR";
  String _nextPrayerTime = "12:33 PM";
  double _timerProgress = 0.65;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initData() async {
    _loadLastRead();
    try {
      final cached = await _storageService.getCachedLocation();
      final reloadNeeded = await _storageService.needsReload();

      if (cached != null && !reloadNeeded) {
        if (!mounted) return;
        setState(() {
          _currentAddress = cached['address'] ?? "Kozhikode, India";
          _currentPosition = Position(
            latitude: cached['lat'],
            longitude: cached['lng'],
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        });
        await _refreshPrayerTimes();
        _startTimer();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await _refreshPrayerTimes();
        _startTimer();
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final address = await _prayerService.getAddress(
        position.latitude,
        position.longitude,
      );

      await _storageService.saveLocationData(
        lat: position.latitude,
        lng: position.longitude,
        address: address,
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _currentAddress = address;
      });

      await _refreshPrayerTimes();
      _startTimer();
    } catch (e) {
      debugPrint("Error initializing dashboard: $e");
      await _refreshPrayerTimes();
      _startTimer();
    }
  }

  Future<void> _loadLastRead() async {
    final last = await _storageService.getLastRead();
    if (last != null) {
      final surahData = _quranService.getSurahDetails(last['surah']!);
      if (mounted) {
        setState(() {
          _lastRead = last;
          _lastSurahData = surahData;
        });
      }
    }
  }

  Future<void> _refreshPrayerTimes() async {
    final lat = _currentPosition?.latitude ?? 11.2588;
    final lng = _currentPosition?.longitude ?? 75.7804;

    final pt = await _prayerService.getPrayerTimes(lat, lng);

    NotificationService().syncPrayerNotifications(pt);

    if (mounted) {
      setState(() {
        _prayerTimes = pt;
        _isLoading = false;
        _updateNextPrayerInfo();
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prayerTimes == null) return;

      final prevRemaining = _timeRemaining;
      _updateNextPrayerInfo();

      if (mounted && _timeRemaining != prevRemaining) {
        setState(() {});
      }
    });
  }

  void _updateNextPrayerInfo() {
    if (_prayerTimes == null) return;

    var next = _prayerTimes!.nextPrayer();
    var nextTime = _prayerTimes!.timeForPrayer(next);
    var prevPrayer = _prayerTimes!.currentPrayer();
    var prevTime = _prayerTimes!.timeForPrayer(prevPrayer);

    if (next == Prayer.none) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final coordinates = Coordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;

      final tomorrowPrayerTimes = PrayerTimes(
        coordinates,
        DateComponents.from(tomorrow),
        params,
      );

      next = Prayer.fajr;
      nextTime = tomorrowPrayerTimes.fajr;
      prevPrayer = Prayer.isha;
      prevTime = _prayerTimes!.isha;
    } else if (prevPrayer == Prayer.none) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final coordinates = Coordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;

      final yesterdayPrayerTimes = PrayerTimes(
        coordinates,
        DateComponents.from(yesterday),
        params,
      );

      prevPrayer = Prayer.isha;
      prevTime = yesterdayPrayerTimes.isha;
    }

    if (nextTime == null || prevTime == null) return;

    _nextPrayerName = _prayerService.getPrayerName(next).toUpperCase();
    _nextPrayerTime = DateFormat('h:mm a').format(nextTime);

    final now = DateTime.now();
    final difference = nextTime.difference(now);

    if (difference.isNegative) {
      _refreshPrayerTimes();
      return;
    }

    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
    _timeRemaining = "$hours:$minutes:$seconds";

    final totalDuration = nextTime.difference(prevTime).inSeconds;
    final elapsed = now.difference(prevTime).inSeconds;
    if (totalDuration > 0) {
      _timerProgress = (elapsed / totalDuration).clamp(0.0, 1.0);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning,";
    } else if (hour < 17) {
      return "Good Afternoon,";
    } else {
      return "Good Evening,";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: _isLoading
            ? _buildShimmerLoading()
            : RefreshIndicator(
                color: primaryGreen,
                backgroundColor: const Color(0xFF131924),
                onRefresh: () async {
                  await _initData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildHeaderCard(),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrayerTimesScreen(),
                            ),
                          );
                        },
                        child: _buildPrayerTimerHero(),
                      ),
                      const SizedBox(height: 32),
                      _buildActionGrid(),
                      const SizedBox(height: 20),
                      _buildContinueReadingCard(),
                      const SizedBox(height: 20),
                      _buildDailyDuaCard(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // --- HEADER CARD MATCHING IMAGE ---
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Avatar G Circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: primaryGreen, width: 2),
            ),
            child: Center(
              child: Text(
                "G",
                style: GoogleFonts.outfit(
                  color: primaryGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Guest",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _currentAddress,
                  style: GoogleFonts.outfit(
                    color: primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.settings_rounded,
                color: Colors.white70,
                size: 20,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- PRAYER TIMER CIRCLE HERO MATCHING IMAGE ---
  Widget _buildPrayerTimerHero() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Glow Background
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withValues(alpha: 0.12),
                  blurRadius: 50,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),

          // Progress Arc Ring
          SizedBox(
            width: 240,
            height: 240,
            child: CircularProgressIndicator(
              value: _timerProgress,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              color: primaryGreen,
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "TIME TO $_nextPrayerName",
                style: GoogleFonts.outfit(
                  color: primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _timeRemaining,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: primaryGreen.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_filled,
                      color: primaryGreen,
                      size: 15,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Starts $_nextPrayerTime",
                      style: GoogleFonts.outfit(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- ACTION GRID MATCHING IMAGE ---
  Widget _buildActionGrid() {
    return Row(
      children: [
        // Left Habits Card
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HabitTrackerScreen(),
                ),
              );
            },
            child: Container(
              height: 160,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF131924),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          color: primaryGreen,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "HABITS",
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    "Track your\nSunnah",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Keep going!",
                        style: GoogleFonts.outfit(
                          color: primaryGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: primaryGreen,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Right Digital Tasbih Card
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TasbeehScreen()),
              );
            },
            child: Container(
              height: 160,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF131924),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: primaryGreen.withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryGreen.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.touch_app_rounded,
                          color: primaryGreen,
                          size: 20,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white54,
                        size: 18,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    "Digital\nTasbih",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- CONTINUE READING CARD MATCHING IMAGE ---
  Widget _buildContinueReadingCard() {
    final progressValue = _lastRead != null && _lastSurahData != null
        ? (_lastRead!['ayah']! / _lastSurahData!['ayahs']).clamp(0.0, 1.0)
        : 0.0;

    final progressPercent = (progressValue * 100).toInt();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Stack(
        children: [
          // Background Calligraphy Image Pattern Overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Opacity(
                opacity: 0.12,
                child: Image.network(
                  'https://images.unsplash.com/photo-1609599006353-e629aaabfeae',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: primaryGreen,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Continue Reading",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _lastSurahData != null
                      ? "${_lastSurahData!['name']} • Ayah ${_lastRead!['ayah']}"
                      : "Surah Al-Fatihah • Ayah 1",
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryGreen,
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "$progressPercent%",
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_lastRead != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SurahDetailScreen(
                              surahNumber: _lastRead!['surah']!,
                              initialAyah: _lastRead!['ayah'],
                            ),
                          ),
                        ).then((_) => _loadLastRead());
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SurahDetailScreen(surahNumber: 1),
                          ),
                        ).then((_) => _loadLastRead());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFE2E8F0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                    ),
                    child: Text(
                      "Resume",
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TODAY'S DUA CARD ---
  Widget _buildDailyDuaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "TODAY'S DUA",
                  style: GoogleFonts.outfit(
                    color: primaryGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Dua copied to clipboard"),
                      backgroundColor: const Color(0xFF131924),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.white54,
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي",
            style: GoogleFonts.amiri(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "\"My Lord, expand for me my breast [with assurance] and ease for me my task.\"",
            style: GoogleFonts.outfit(
              color: Colors.white60,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
