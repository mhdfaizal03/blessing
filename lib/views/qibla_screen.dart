import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:blessing/services/local_storage_service.dart';
import 'package:blessing/services/qibla_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final Color kAccentGreen = AppColors().kAccentNeon;
  final Color kTextGrey = AppColors().kTextGrey;

  final QiblaService _qiblaService = QiblaService();
  final LocalStorageService _storageService = LocalStorageService();

  double _deviceHeading = 0;
  double _qiblaBearing = 0;

  String _currentAddress = "Locating...";
  String _distance = "Calculating...";

  StreamSubscription<CompassEvent>? _compassSubscription;

  bool _hasPermission = false;
  bool _isLoading = true;

  static const double _dialSize = 280;

  @override
  void initState() {
    super.initState();
    _initQibla();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  // ---------------- INIT ----------------

  Future<void> _initQibla() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _hasPermission = false;
          _isLoading = false;
          _currentAddress = "Location permission required";
        });
        return;
      }

      // Check Cache
      final cached = await _storageService.getCachedLocation();
      if (cached != null) {
        debugPrint("QiblaScreen: Using cached data");
        final bearing = _qiblaService.calculateQibla(
          cached['lat'],
          cached['lng'],
        );
        final dist = _qiblaService.calculateDistance(
          cached['lat'],
          cached['lng'],
        );

        if (!mounted) return;
        setState(() {
          _hasPermission = true;
          _qiblaBearing = bearing;
          _distance = "${dist.toStringAsFixed(0)} km";
          _currentAddress = cached['address'];
          _isLoading = false;
        });

        _startCompassStream();
        return;
      }

      final position = await _qiblaService.getCurrentLocation();

      if (position == null) {
        if (!mounted) return;
        setState(() {
          _hasPermission = false;
          _isLoading = false;
          _currentAddress = "Location not available";
        });
        return;
      }

      final bearing = _qiblaService.calculateQibla(
        position.latitude,
        position.longitude,
      );

      final dist = _qiblaService.calculateDistance(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _hasPermission = true;
        _qiblaBearing = bearing;
        _distance = "${dist.toStringAsFixed(0)} km";
        _isLoading = false;
      });

      _getAddr(position);
      _startCompassStream();
    } catch (e) {
      debugPrint("Qibla init error: $e");
      if (!mounted) return;
      setState(() {
        _hasPermission = false;
        _isLoading = false;
        _currentAddress = "Location error";
      });
    }
  }

  void _startCompassStream() {
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (!mounted) return;
      final heading = event.heading;
      if (heading == null) return;
      setState(() {
        _deviceHeading = heading;
      });
    });
  }

  Future<void> _getAddr(Position p) async {
    final addr = await _qiblaService.getAddressDisplay(p.latitude, p.longitude);
    if (!mounted) return;
    setState(() {
      _currentAddress = addr;
    });
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();
    return Scaffold(
      backgroundColor: colors.kPrimaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Qibla',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.kTextWhite,
            fontSize: 22,
          ),
        ),
        actions: [
          CustomCircleIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notifications coming soon'),
                  backgroundColor: colors.kCardBg,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          CustomCircleIconButton(
            icon: Icons.person_outline_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Profile coming soon'),
                  backgroundColor: colors.kCardBg,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildShimmerLoading()
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    RepaintBoundary(child: _buildLocationCard()),
                    const SizedBox(height: 30),
                    if (!_hasPermission) _buildPermissionCard(),
                    if (_hasPermission) ...[
                      Center(
                        child: RepaintBoundary(
                          child: _buildCompassDial(
                            deviceHeading: _deviceHeading,
                            qiblaBearing: _qiblaBearing,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildDirectionText(),
                      const SizedBox(height: 28),
                      _buildStatsRow(),
                    ],
                    const SizedBox(height: 100), // Spacing for floating navbar
                  ],
                ),
              ),
      ),
    );
  }

  // ---------------- LOCATION CARD ----------------

  Widget _buildLocationCard() {
    final colors = AppColors();
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.kGlassWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.kGlassBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.kAccentNeon.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on_rounded, color: colors.kAccentNeon, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "CURRENT LOCATION",
                      style: TextStyle(
                        color: colors.kTextGrey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.kTextWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _initQibla,
                child: Text(
                  "REFRESH",
                  style: TextStyle(
                    color: colors.kAccentNeon,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- PERMISSION CARD ----------------

  Widget _buildPermissionCard() {
    final colors = AppColors();
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_disabled_rounded,
                  color: Colors.redAccent,
                  size: 44,
                ),
                const SizedBox(height: 12),
                Text(
                  "Location Permission Required",
                  style: TextStyle(
                    color: colors.kTextWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Please enable location permissions to locate Makkah direction accurately.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.kTextGrey, fontSize: 13),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.kAccentNeon,
                    foregroundColor: colors.kPrimaryBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    await Geolocator.openAppSettings();
                    if (!mounted) return;
                    await _initQibla();
                  },
                  child: const Text("Open Settings", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- COMPASS ----------------

  Widget _buildCompassDial({
    required double deviceHeading,
    required double qiblaBearing,
  }) {
    final colors = AppColors();
    final double needleAngle = (qiblaBearing - deviceHeading) * (math.pi / 180);

    return SizedBox(
      width: _dialSize,
      height: _dialSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Outer Ring Glow
          Container(
            width: _dialSize,
            height: _dialSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.kSurface,
              border: Border.all(color: colors.kGlassBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: colors.kAccentNeon.withValues(alpha: 0.1),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          // Cardinal labels
          Transform.rotate(
            angle: -deviceHeading * (math.pi / 180),
            child: SizedBox(
              width: _dialSize,
              height: _dialSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 14,
                    child: Text(
                      "N",
                      style: TextStyle(
                        color: colors.kAccentNeon,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    child: Text(
                      "S",
                      style: TextStyle(
                        color: colors.kTextGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    child: Text(
                      "W",
                      style: TextStyle(
                        color: colors.kTextGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 14,
                    child: Text(
                      "E",
                      style: TextStyle(
                        color: colors.kTextGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Qibla needle pointer
          Transform.rotate(
            angle: needleAngle,
            child: SizedBox(
              width: _dialSize,
              height: _dialSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 3,
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.kAccentNeon, colors.kAccentNeon.withValues(alpha: 0.1)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: colors.emeraldGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.kAccentNeon.withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mosque_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center Pivot Dot
          Container(
            height: 14,
            width: 14,
            decoration: BoxDecoration(
              color: colors.kAccentNeon,
              shape: BoxShape.circle,
              border: Border.all(color: colors.kPrimaryBg, width: 2),
              boxShadow: [
                BoxShadow(
                  color: colors.kAccentNeon,
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- DIRECTION TEXT ----------------

  Widget _buildDirectionText() {
    final colors = AppColors();
    final dir = _bearingToDirection(_qiblaBearing);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              "${_qiblaBearing.toStringAsFixed(2)}°",
              style: TextStyle(
                color: colors.kTextWhite,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              dir,
              style: TextStyle(
                color: colors.kAccentNeon,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Calibrated to your location",
          style: TextStyle(color: colors.kTextGrey, fontSize: 13),
        ),
      ],
    );
  }

  String _bearingToDirection(double b) {
    if (b >= 337.5 || b < 22.5) return "N";
    if (b < 67.5) return "NE";
    if (b < 112.5) return "E";
    if (b < 157.5) return "SE";
    if (b < 202.5) return "S";
    if (b < 247.5) return "SW";
    if (b < 292.5) return "W";
    return "NW";
  }

  // ---------------- STATS ----------------

  Widget _buildStatsRow() {
    final colors = AppColors();
    return Row(
      children: [
        _statBox("DISTANCE", _distance, colors.kTextWhite),
        const SizedBox(width: 15),
        _statBox("DIRECTION", "Makkah", colors.kAccentNeon),
      ],
    );
  }

  Widget _statBox(String label, String value, Color valColor) {
    final colors = AppColors();
    return Expanded(
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.kGlassWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.kGlassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: colors.kTextGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      color: valColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Container(
                width: _dialSize,
                height: _dialSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Container(
                height: 45,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
