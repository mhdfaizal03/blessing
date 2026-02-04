import 'dart:async';
import 'dart:ui';

import 'package:adhan/adhan.dart';
import 'package:blessing/constands/colors.dart';
import 'package:blessing/services/local_storage_service.dart';
import 'package:blessing/services/prayer_time_service.dart';
import 'package:blessing/services/quran_service.dart';
import 'package:blessing/views/prayer_times_screen.dart';
import 'package:blessing/views/surah_details_screen.dart';
import 'package:blessing/views/tasbeeh_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AppColors colors = AppColors();
  late final Color cardColor = colors.kCardBg;
  late final Color accentColor = colors.kAccentNeon;

  // Services & State
  final PrayerTimeService _prayerService = PrayerTimeService();
  final LocalStorageService _storageService = LocalStorageService();
  final QuranService _quranService = QuranService();
  PrayerTimes? _prayerTimes;
  bool _isLoading = true;

  Map<String, int>? _lastRead;
  Map<String, dynamic>? _lastSurahData;

  String _timeRemaining = "--:--:--";
  Timer? _timer;
  Position? _currentPosition;
  String _nextPrayerName = "--";
  String _nextPrayerTime = "--:--";
  double _timerProgress = 0.75; // Default/Loading state

  // Iftar State
  String _iftarTimeRemaining = "--h --m";
  String _iftarTimeDisplay = "--:-- PM";
  double _iftarProgress = 0.0;
  bool _isRamadan = false;

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
      // 0. Check Ramadan
      setState(() {
        _isRamadan = _prayerService.isRamadan();
      });

      // 1. Check Cache
      final cached = await _storageService.getCachedLocation();
      final reloadNeeded = await _storageService.needsReload();

      if (cached != null && !reloadNeeded) {
        debugPrint("Using cached data: ${cached['address']}");
        if (!mounted) return;
        setState(() {
          // Create dummy position for existing logic if needed
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

      // 2. Refresh Location if not cached or reload needed
      debugPrint("Fetching fresh location data...");
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final address = await _prayerService.getAddress(
        position.latitude,
        position.longitude,
      );

      // Save to Cache
      await _storageService.saveLocationData(
        lat: position.latitude,
        lng: position.longitude,
        address: address,
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
      });

      await _refreshPrayerTimes();
      _startTimer();
    } catch (e) {
      debugPrint("Error initializing dashboard: $e");
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
    if (_currentPosition == null) return;

    final pt = await _prayerService.getPrayerTimes(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    if (mounted) {
      setState(() {
        _prayerTimes = pt;
        _isLoading = false;
        _updateNextPrayerInfo();
        _updateIftarInfo();
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prayerTimes == null) return;

      // Check if we need to refresh prayer times (e.g. next day)
      // For simplicity, we just update countdowns here
      // Real-app might check date change.

      if (mounted) {
        setState(() {
          _updateNextPrayerInfo();
          _updateIftarInfo();
        });
      }
    });
  }

  void _updateNextPrayerInfo() {
    if (_prayerTimes == null) return;

    var next = _prayerTimes!.nextPrayer();
    var nextTime = _prayerTimes!.timeForPrayer(next);
    var prevPrayer = _prayerTimes!.currentPrayer();
    var prevTime = _prayerTimes!.timeForPrayer(prevPrayer);

    // Handle "After Isha" case -> Next is Tomorrow's Fajr
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
      // Handle "Early Morning" case (Before Fajr) -> Prev was Yesterday's Isha
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

    _nextPrayerName = _prayerService.getPrayerName(next);
    _nextPrayerTime = DateFormat('h:mm a').format(nextTime!);

    final now = DateTime.now();
    final difference = nextTime.difference(now);

    if (difference.isNegative) {
      // Time passed, trigger refresh to get fresh next prayer
      _refreshPrayerTimes();
      return;
    }

    // Format HH:MM:SS
    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
    _timeRemaining = "$hours:$minutes:$seconds";

    // Progress Calculation
    if (prevTime != null && nextTime != null) {
      final totalDuration = nextTime.difference(prevTime).inSeconds;
      final elapsed = now.difference(prevTime).inSeconds;
      if (totalDuration > 0) {
        _timerProgress = (elapsed / totalDuration).clamp(0.0, 1.0);
      }
    }
  }

  void _updateIftarInfo() {
    if (!_isRamadan) return; // Skip iftar calculations if not Ramadan
    if (_prayerTimes == null) return;

    final maghrib = _prayerTimes!.maghrib;
    _iftarTimeDisplay = "Sunset at ${DateFormat('h:mm a').format(maghrib)}";

    final now = DateTime.now();
    final diff = maghrib.difference(now);

    if (diff.isNegative) {
      _iftarTimeRemaining = "Completed";
      _iftarProgress = 1.0;
    } else {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      _iftarTimeRemaining = "${h}h ${m}m";

      // Progress based on day (Sunrise to Maghrib usually for fasting)
      final sunrise = _prayerTimes!.sunrise;
      final totalFasting = maghrib.difference(sunrise).inSeconds;
      final elapsedFasting = now.difference(sunrise).inSeconds;

      if (totalFasting > 0) {
        _iftarProgress = (elapsedFasting / totalFasting).clamp(0.0, 1.0);
      } else {
        _iftarProgress = 0.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? _buildShimmerLoading()
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildHeader(),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrayerTimesScreen(),
                          ),
                        );
                      },
                      child: _buildPrayerTimer(),
                    ),
                    const SizedBox(height: 30),
                    _buildActionGrid(),
                    const SizedBox(height: 20),
                    _buildContinueReading(),
                    const SizedBox(height: 20),
                    _buildDailyDua(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header Skeleton
            Row(
              children: [
                const CircleAvatar(radius: 22, backgroundColor: Colors.white),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 18,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Prayer Timer Skeleton
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
            const SizedBox(height: 30),
            // Action Grid Skeleton
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Continue Reading Skeleton
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=ahmed'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Salam Alaykum,",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              "Ahmed",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        const Icon(Icons.settings, color: Colors.white70),
      ],
    );
  }

  Widget _buildPrayerTimer() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 240,
            height: 240,
            child: CircularProgressIndicator(
              value: _timerProgress, // Updated Real Value
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: accentColor,
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Next Prayer",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                _timeRemaining, // Updated Real Value
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [
                    FontFeature.tabularFigures(),
                  ], // Fixed width numbers
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _nextPrayerName, // Updated Real Value
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "  •  $_nextPrayerTime", // Updated Real Value
                      style: const TextStyle(color: Colors.white70),
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

  Widget _buildActionGrid() {
    return Row(
      children: [
        // ------------------ CONDITIONAL CARD (Iftar / Habit) ------------------
        Expanded(
          child: _isRamadan ? _buildIftarCard() : _buildHabitTrackerCard(),
        ),

        const SizedBox(width: 15),

        // ------------------ TASBIH GLASS ACCENT CARD ------------------
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TasbeehScreen()),
              );
            },
            child: _glassAccentCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.touch_app, color: Colors.black),
                      Icon(Icons.arrow_forward, color: Colors.black),
                    ],
                  ),
                  const Text(
                    "Start\nTasbih",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      height: 1.1,
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

  Widget _buildIftarCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.nightlight_round, color: accentColor, size: 16),
              const SizedBox(width: 6),
              const Text(
                "IFTAR TIME",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),

          const Spacer(),

          Text(
            _iftarTimeRemaining, // Updated Real Value
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            _iftarTimeDisplay, // Updated Real Value
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),

          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: _iftarProgress, // Updated Real Value
            backgroundColor: Colors.white.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation(accentColor),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitTrackerCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: accentColor, size: 16),
              const SizedBox(width: 6),
              const Text(
                "DAILY HABITS",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),

          const Spacer(),

          const Text(
            "Track your\nSunnah",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _habitBubble(Icons.menu_book, true), // Quran
              _habitBubble(Icons.favorite_border, false), // Charity/Adhkar
              _habitBubble(Icons.water_drop_outlined, false), // Wudu/Other
              _habitBubble(Icons.mosque_outlined, true), // Prayer
            ],
          ),
        ],
      ),
    );
  }

  Widget _habitBubble(IconData icon, bool completed) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: completed ? accentColor : Colors.white10,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 14,
        color: completed ? Colors.black : Colors.white54,
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassAccentCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildContinueReading() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: colors.kGlassWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.kGlassBorder),
          ),
          child: Stack(
            children: [
              // background image glow
              Positioned(
                right: -20,
                top: 0,
                bottom: 0,
                child: Opacity(
                  opacity: 0.18,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1544947950-fa07a98d237f',
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book, color: accentColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Continue Reading",
                          style: TextStyle(
                            color: colors.kTextWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _lastSurahData != null
                          ? "${_lastSurahData!['name']} • Ayah ${_lastRead!['ayah']}"
                          : "Surah Al-Fatihah • Ayah 1",
                      style: TextStyle(color: colors.kTextGrey, fontSize: 13),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _lastRead != null && _lastSurahData != null
                                ? _lastRead!['ayah']! / _lastSurahData!['ayahs']
                                : 0.05,
                            backgroundColor: colors.kTextWhite.withOpacity(
                              0.12,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              accentColor,
                            ),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _lastRead != null && _lastSurahData != null
                              ? "${((_lastRead!['ayah']! / _lastSurahData!['ayahs']) * 100).toInt()}%"
                              : "0%",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      height: 38,
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
                            // Default to Fatihah if nothing read yet
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
                          backgroundColor: colors.kTextWhite.withOpacity(0.9),
                          foregroundColor: colors.kPrimaryBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Resume",
                          style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildDailyDua() {
    return _cardDuaWrapper(
      child: Column(
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
                  color: colors.kGlassWhite,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "TODAY'S DUA",
                  style: TextStyle(color: colors.kTextGrey, fontSize: 10),
                ),
              ),
              Icon(Icons.share, color: colors.kTextGrey, size: 18),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي",
            style: TextStyle(
              color: colors.kTextWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "\"My Lord, expand for me my breast [with assurance] and ease for me my task.\"",
            style: TextStyle(color: colors.kTextGrey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _cardDuaWrapper({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.kGlassWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.kGlassBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}
