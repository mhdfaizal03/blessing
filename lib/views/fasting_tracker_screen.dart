import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:blessing/services/local_storage_service.dart';
import 'package:blessing/services/prayer_time_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class FastingTrackerScreen extends StatefulWidget {
  const FastingTrackerScreen({super.key});

  @override
  State<FastingTrackerScreen> createState() => _FastingTrackerScreenState();
}

class _FastingTrackerScreenState extends State<FastingTrackerScreen> {
  final AppColors _colors = AppColors();
  final PrayerTimeService _prayerService = PrayerTimeService();
  final LocalStorageService _storageService = LocalStorageService();

  bool _isLoading = true;
  PrayerTimes? _prayerTimes;
  Timer? _timer;

  String _suhoorTime = "--:--";
  String _iftarTime = "--:--";
  String _countdownTitle = "NEXT IFTAR IN";
  String _countdownDisplay = "00:00:00";
  double _fastingProgress = 0.0;

  bool _isFastingToday = false;
  int _completedFastsCount = 14;
  int _currentStreak = 3;

  final HijriCalendar _hijri = HijriCalendar.now();

  @override
  void initState() {
    super.initState();
    _initFastingData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateCountdown();
      }
    });
  }

  Future<void> _initFastingData() async {
    try {
      Position position;
      try {
        position = await Geolocator.getCurrentPosition();
      } catch (_) {
        position = Position(
          longitude: 39.8262,
          latitude: 21.4225,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }

      final times = await _prayerService.getPrayerTimes(
        position.latitude,
        position.longitude,
      );

      final isFastingLogged = await _storageService.isFastingLoggedToday();

      if (!mounted) return;
      setState(() {
        _prayerTimes = times;
        _suhoorTime = DateFormat('h:mm a').format(times.fajr);
        _iftarTime = DateFormat('h:mm a').format(times.maghrib);
        _isFastingToday = isFastingLogged;
        _isLoading = false;
      });

      _updateCountdown();
    } catch (e) {
      debugPrint("Fasting init error: $e");
      setState(() => _isLoading = false);
    }
  }

  void _updateCountdown() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    final fajr = _prayerTimes!.fajr;
    final maghrib = _prayerTimes!.maghrib;

    if (now.isBefore(fajr)) {
      // Before Suhoor ends
      _countdownTitle = "SUHOOR ENDS IN";
      final diff = fajr.difference(now);
      _countdownDisplay = _formatDuration(diff);
      _fastingProgress = 0.0;
    } else if (now.isBefore(maghrib)) {
      // During Fasting Hours
      _countdownTitle = "IFTAR TIME IN";
      final diff = maghrib.difference(now);
      _countdownDisplay = _formatDuration(diff);

      final totalSeconds = maghrib.difference(fajr).inSeconds;
      final elapsed = now.difference(fajr).inSeconds;
      _fastingProgress = (elapsed / totalSeconds).clamp(0.0, 1.0);
    } else {
      // After Iftar
      _countdownTitle = "FAST COMPLETED TODAY";
      _countdownDisplay = "00:00:00";
      _fastingProgress = 1.0;
    }

    setState(() {});
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  Future<void> _toggleFastingLog() async {
    final newStatus = !_isFastingToday;
    await _storageService.setFastingLoggedToday(newStatus);
    setState(() {
      _isFastingToday = newStatus;
      if (newStatus) {
        _completedFastsCount++;
        _currentStreak++;
      } else {
        if (_completedFastsCount > 0) _completedFastsCount--;
        if (_currentStreak > 0) _currentStreak--;
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus ? "Fast logged for today! May Allah accept it." : "Fast status unlogged."),
          backgroundColor: _colors.kCardBg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayName = DateFormat('EEEE').format(DateTime.now());
    final isSunnahDay = todayName == "Monday" || todayName == "Thursday" || _hijri.hDay == 13 || _hijri.hDay == 14 || _hijri.hDay == 15;

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
          'Fasting Tracker',
          style: TextStyle(
            color: _colors.kTextWhite,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          CustomCircleIconButton(
            icon: Icons.calendar_month_rounded,
            onTap: () => _showCalendarSheet(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: _colors.kAccentNeon))
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Sunnah Fast Badge
              if (isSunnahDay) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _colors.kAccentNeon.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _colors.kAccentNeon.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: _colors.kAccentNeon, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        "SUNNAH FASTING DAY (${_hijri.hDay} ${_hijri.longMonthName})",
                        style: TextStyle(
                          color: _colors.kAccentNeon,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Countdown Ring Header
              _buildFastingTimerRing(),

              const SizedBox(height: 28),

              // Suhoor & Iftar Times Card
              _buildSuhoorIftarTimesCard(),

              const SizedBox(height: 20),

              // Log Fast CTA Button
              _buildLogFastButton(),

              const SizedBox(height: 28),

              // Fasting Stats Row
              _buildFastingStatsRow(),

              const SizedBox(height: 28),

              // Iftar Dua Card
              _buildIftarDuaCard(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFastingTimerRing() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _colors.kAccentNeon.withValues(alpha: 0.08),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 240,
            height: 240,
            child: CircularProgressIndicator(
              value: _fastingProgress,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              color: _colors.kAccentNeon,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _countdownTitle,
                style: TextStyle(
                  color: _colors.kTextGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _countdownDisplay,
                style: TextStyle(
                  color: _colors.kTextWhite,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${(_fastingProgress * 100).toInt()}% completed",
                style: TextStyle(color: _colors.kAccentNeon, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuhoorIftarTimesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _colors.kSecondaryBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _colors.kGlassBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Icon(Icons.wb_twilight_rounded, color: _colors.kAccentNeon, size: 18),
                  const SizedBox(width: 6),
                  Text("SUHOOR (FAJR)", style: TextStyle(color: _colors.kTextGrey, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              Text(_suhoorTime, style: TextStyle(color: _colors.kTextWhite, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(width: 1, height: 40, color: _colors.kGlassBorder),
          Column(
            children: [
              Row(
                children: [
                  Icon(Icons.nightlight_round, color: _colors.kAccentNeon, size: 18),
                  const SizedBox(width: 6),
                  Text("IFTAR (MAGHRIB)", style: TextStyle(color: _colors.kTextGrey, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              Text(_iftarTime, style: TextStyle(color: _colors.kTextWhite, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogFastButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _toggleFastingLog,
        icon: Icon(
          _isFastingToday ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
          color: _isFastingToday ? _colors.kAccentNeon : _colors.kPrimaryBg,
        ),
        label: Text(
          _isFastingToday ? "Fast Logged Today" : "Log Today's Fast",
          style: TextStyle(
            color: _isFastingToday ? _colors.kAccentNeon : _colors.kPrimaryBg,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFastingToday ? _colors.kSecondaryBg : _colors.kAccentNeon,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: _isFastingToday ? BorderSide(color: _colors.kAccentNeon) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFastingStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statBox("COMPLETED FASTS", "$_completedFastsCount", "This Month", Icons.calendar_month_rounded),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _statBox("CURRENT STREAK", "$_currentStreak Days", "Consistent", Icons.local_fire_department_rounded),
        ),
      ],
    );
  }

  Widget _statBox(String label, String val, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colors.kSecondaryBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _colors.kGlassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _colors.kAccentNeon, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: _colors.kTextGrey, fontSize: 10, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(val, style: TextStyle(color: _colors.kTextWhite, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(sub, style: TextStyle(color: _colors.kTextGrey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildIftarDuaCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _colors.kSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _colors.kGlassBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _colors.kAccentNeon.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "DUA FOR BREAKING FAST (IFTAR)",
                  style: TextStyle(
                    color: _colors.kAccentNeon,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Icon(Icons.format_quote_rounded, color: _colors.kTextGrey, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الأَجْرُ إِنْ شَاءَ اللَّهُ",
            style: TextStyle(
              color: _colors.kTextWhite,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Dhahaba al-dhama'u wa abtallat al-'urooouqu wa thabata al-ajru in sha' Allah",
            style: TextStyle(color: _colors.kAccentNeon, fontSize: 12, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "\"The thirst has gone, the veins are moistened, and the reward is confirmed, if Allah wills.\"",
            style: TextStyle(color: _colors.kTextGrey, fontSize: 13, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCalendarSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _colors.kSecondaryBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Recommended Fasting Days",
              style: TextStyle(color: _colors.kTextWhite, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _calendarInfoRow("Mondays & Thursdays", "Sunnah of the Prophet (SAW)"),
            const SizedBox(height: 10),
            _calendarInfoRow("Ayyam al-Beed (White Days)", "13th, 14th, 15th of every Hijri month"),
            const SizedBox(height: 10),
            _calendarInfoRow("Day of Arafah (9 Dhul Hijjah)", "Expiates sins of previous and coming year"),
            const SizedBox(height: 10),
            _calendarInfoRow("Ashura (10 Muharram)", "Expiates sins of the previous year"),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _calendarInfoRow(String title, String desc) {
    return Row(
      children: [
        Icon(Icons.star_rounded, color: _colors.kAccentNeon, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: _colors.kTextWhite, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(desc, style: TextStyle(color: _colors.kTextGrey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
