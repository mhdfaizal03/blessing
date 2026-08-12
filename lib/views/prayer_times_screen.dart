import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:blessing/services/local_storage_service.dart';
import 'package:blessing/services/prayer_time_service.dart';
import 'package:blessing/services/notification_service.dart';
import 'package:blessing/views/prayer_journey.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final AppColors colors = AppColors();
  final PrayerTimeService _prayerService = PrayerTimeService();
  final LocalStorageService _storageService = LocalStorageService();
  final NotificationService _notificationService = NotificationService();

  PrayerTimes? _prayerTimes;
  String _currentAddress = "Locating...";
  String _formattedDate = "";
  String _hijriDate = "";
  Prayer _nextPrayer = Prayer.none;
  Timer? _timer;

  // Azan settings
  final Map<String, bool> _azanEnabled = {
    "Fajr": false,
    "Dhuhr": false,
    "Asr": false,
    "Maghrib": false,
    "Isha": false,
  };

  @override
  void initState() {
    super.initState();
    _initData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // Refresh UI every minute for calculations if needed
          if (_prayerTimes != null) {
            _nextPrayer = _prayerService.getNextPrayer(_prayerTimes!);
          }
        });
      }
    });
  }

  Future<void> _initData() async {
    try {
      // 1. Check Cache
      final cached = await _storageService.getCachedLocation();
      final reloadNeeded = await _storageService.needsReload();

      if (cached != null && !reloadNeeded) {
        debugPrint("PrayerTimesScreen: Using cached data");
        final times = await _prayerService.getPrayerTimes(
          cached['lat'],
          cached['lng'],
        );

        if (!mounted) return;
        setState(() {
          _prayerTimes = times;
          _currentAddress = cached['address'];
          _formattedDate = _prayerService.getFormattedDate(DateTime.now());
          _hijriDate = "1445 AH";
          _nextPrayer = _prayerService.getNextPrayer(times);
        });
        _loadAzanSettings();
        return;
      }

      // 2. Fetch Fresh
      debugPrint("PrayerTimesScreen: Fetching fresh location");
      Position position = await Geolocator.getCurrentPosition();
      final times = await _prayerService.getPrayerTimes(
        position.latitude,
        position.longitude,
      );
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
        _prayerTimes = times;
        _currentAddress = address;
        _formattedDate = _prayerService.getFormattedDate(DateTime.now());
        _hijriDate = "1445 AH";
        _nextPrayer = _prayerService.getNextPrayer(times);
      });
      _loadAzanSettings();
    } catch (e) {
      debugPrint("Error fetching prayer times: $e");
      if (mounted) {
        setState(() {
          _currentAddress = "Location Error";
        });
      }
    }
  }

  Future<void> _loadAzanSettings() async {
    for (var key in _azanEnabled.keys) {
      bool enabled = await _storageService.isAzanEnabled(key);
      setState(() {
        _azanEnabled[key] = enabled;
      });
    }
  }

  Future<void> _toggleAzan(String name, bool enabled, DateTime? time) async {
    setState(() {
      _azanEnabled[name] = enabled;
    });
    await _storageService.setAzanEnabled(name, enabled);

    if (enabled && time != null) {
      // Use consistent IDs for prayers
      int id = 0;
      switch (name) {
        case "Fajr":
          id = 1;
          break;
        case "Dhuhr":
          id = 2;
          break;
        case "Asr":
          id = 3;
          break;
        case "Maghrib":
          id = 4;
          break;
        case "Isha":
          id = 5;
          break;
      }
      await _notificationService.scheduleAzan(
        id: id,
        title: name,
        scheduledDate: time,
      );
    } else {
      int id = 0;
      switch (name) {
        case "Fajr":
          id = 1;
          break;
        case "Dhuhr":
          id = 2;
          break;
        case "Asr":
          id = 3;
          break;
        case "Maghrib":
          id = 4;
          break;
        case "Isha":
          id = 5;
          break;
      }
      await _notificationService.cancelNotification(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CustomCircleIconButton(
          icon: Icons.arrow_back,
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "PRAYER TIMES",
          style: TextStyle(
            color: colors.kAccentNeon,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          CustomCircleIconButton(
            icon: Icons.settings,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrayerJourneyScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _locationChip(),
                const SizedBox(height: 15),
                Text(
                  _formattedDate.isNotEmpty
                      ? "$_hijriDate • $_formattedDate"
                      : "Loading",
                  style: TextStyle(color: colors.kTextGrey),
                ),
                const SizedBox(height: 30),
                if (_prayerTimes == null)
                  if (_currentAddress == "Location Error")
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 48,
                            color: colors.kTextGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Unable to load prayer times",
                            style: TextStyle(
                              color: colors.kTextWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Please check your location settings and network connection.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.kTextGrey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _initData,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text(
                              "Retry",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.kAccentNeon,
                              foregroundColor: colors.kPrimaryBg,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    CircularProgressIndicator(color: colors.kAccentNeon)
                else
                  ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      _prayerTile(
                        "Fajr",
                        DateFormat.jm().format(_prayerTimes!.fajr),
                        _azanEnabled["Fajr"] ?? false,
                        isNext: _nextPrayer == Prayer.fajr,
                        onToggle: (v) =>
                            _toggleAzan("Fajr", v, _prayerTimes!.fajr),
                      ),
                      _prayerTile(
                        "Sunrise",
                        DateFormat.jm().format(_prayerTimes!.sunrise),
                        false,
                        isSunrise: true,
                        // Sunrise usually doesn't have azan, but we could add if needed
                      ),
                      _prayerTile(
                        "Dhuhr",
                        DateFormat.jm().format(_prayerTimes!.dhuhr),
                        _azanEnabled["Dhuhr"] ?? false,
                        isNext: _nextPrayer == Prayer.dhuhr,
                        onToggle: (v) =>
                            _toggleAzan("Dhuhr", v, _prayerTimes!.dhuhr),
                      ),
                      _prayerTile(
                        "Asr",
                        DateFormat.jm().format(_prayerTimes!.asr),
                        _azanEnabled["Asr"] ?? false,
                        isNext: _nextPrayer == Prayer.asr,
                        onToggle: (v) =>
                            _toggleAzan("Asr", v, _prayerTimes!.asr),
                      ),
                      _prayerTile(
                        "Maghrib",
                        DateFormat.jm().format(_prayerTimes!.maghrib),
                        _azanEnabled["Maghrib"] ?? false,
                        isNext: _nextPrayer == Prayer.maghrib,
                        onToggle: (v) =>
                            _toggleAzan("Maghrib", v, _prayerTimes!.maghrib),
                      ),
                      _prayerTile(
                        "Isha",
                        DateFormat.jm().format(_prayerTimes!.isha),
                        _azanEnabled["Isha"] ?? false,
                        isNext: _nextPrayer == Prayer.isha,
                        onToggle: (v) =>
                            _toggleAzan("Isha", v, _prayerTimes!.isha),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _prayerTile(
    String name,
    String time,
    bool isActive, {
    bool isNext = false,
    bool isSunrise = false,
    Function(bool)? onToggle,
  }) {
    final bool isHighlighted = isNext;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? colors.kAccentNeon.withValues(alpha: 0.1)
            : colors.kSecondaryBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isHighlighted ? colors.kAccentNeon : colors.kGlassBorder,
          width: isHighlighted ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? colors.kAccentNeon
                  : colors.kAccentNeon.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSunrise
                  ? Icons.wb_sunny_rounded
                  : Icons.notifications_active_rounded,
              color: isHighlighted ? colors.kPrimaryBg : colors.kAccentNeon,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: colors.kTextWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              if (isNext)
                Text(
                  "NEXT PRAYER",
                  style: TextStyle(
                    color: colors.kAccentNeon,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            time,
            style: TextStyle(
              color: isHighlighted ? colors.kAccentNeon : colors.kTextWhite,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          if (!isSunrise)
            Switch(
              value: isActive,
              activeTrackColor: colors.kAccentNeon.withValues(alpha: 0.5),
              activeThumbColor: colors.kAccentNeon,
              onChanged: onToggle,
            ),
        ],
      ),
    );
  }

  Widget _locationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.kSurface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, color: colors.kAccentNeon, size: 16),
          const SizedBox(width: 5),
          Text(
            _currentAddress.toUpperCase(),
            style: TextStyle(
              color: colors.kTextWhite,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
