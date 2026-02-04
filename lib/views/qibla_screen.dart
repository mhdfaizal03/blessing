import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:blessing/constands/colors.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Qibla',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 15),
          CircleAvatar(radius: 14, child: Icon(Icons.person, size: 18)),
          SizedBox(width: 15),
        ],
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(),
          child: SafeArea(
            child: _isLoading
                ? _buildShimmerLoading()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),

                        RepaintBoundary(child: _buildLocationCard()),

                        const SizedBox(height: 30),

                        if (!_hasPermission) _buildPermissionCard(),

                        const SizedBox(height: 10),

                        if (_hasPermission)
                          Center(
                            child: RepaintBoundary(
                              child: _buildCompassDial(
                                deviceHeading: _deviceHeading,
                                qiblaBearing: _qiblaBearing,
                              ),
                            ),
                          ),

                        const SizedBox(height: 30),

                        if (_hasPermission) _buildDirectionText(),

                        const SizedBox(height: 30),

                        if (_hasPermission) _buildStatsRow(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ---------------- LOCATION CARD ----------------

  Widget _buildLocationCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF1A301A).withOpacity(0.75),
                child: Icon(Icons.location_on, color: kAccentGreen, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "CURRENT LOCATION",
                      style: TextStyle(
                        color: kTextGrey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "CHANGE",
                  style: TextStyle(
                    color: kAccentGreen,
                    fontSize: 12,
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
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_disabled,
                  color: Colors.red,
                  size: 40,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Location Permission Required",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Please enable location permissions to use Qibla Finder.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTextGrey, fontSize: 12),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    await Geolocator.openAppSettings();
                    if (!mounted) return;
                    await _initQibla();
                  },
                  child: const Text("Open Settings"),
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
    final double needleAngle = (qiblaBearing - deviceHeading) * (math.pi / 180);

    return SizedBox(
      width: _dialSize,
      height: _dialSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: _dialSize,
            height: _dialSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10, width: 1),
            ),
          ),

          // labels (bounded stack – FIX)
          Transform.rotate(
            angle: -deviceHeading * (math.pi / 180),
            child: SizedBox(
              width: _dialSize,
              height: _dialSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 10,
                    child: Text(
                      "N",
                      style: TextStyle(
                        color: kTextGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    child: Text(
                      "S",
                      style: TextStyle(
                        color: kTextGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    child: Text(
                      "W",
                      style: TextStyle(
                        color: kTextGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    child: Text(
                      "E",
                      style: TextStyle(
                        color: kTextGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // needle
          Transform.rotate(
            angle: needleAngle,
            child: SizedBox(
              width: _dialSize,
              height: _dialSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 2,
                    height: 220,
                    color: kAccentGreen.withOpacity(0.35),
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kAccentGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mosque,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              color: kAccentGreen,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: kAccentGreen, blurRadius: 10)],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- DIRECTION TEXT ----------------

  Widget _buildDirectionText() {
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              dir,
              style: TextStyle(
                color: kAccentGreen,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          "Calibrated to your location",
          style: TextStyle(color: kTextGrey, fontSize: 13),
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
    return Row(
      children: [
        _statBox("DISTANCE", _distance, Colors.white),
        const SizedBox(width: 15),
        _statBox("DIRECTION", "Makkah", kAccentGreen),
      ],
    );
  }

  Widget _statBox(String label, String value, Color valColor) {
    return Expanded(
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: kTextGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Location Card Skeleton
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 30),
            // Compass Skeleton
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
            // Direction Text Skeleton
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
            // Stats Row Skeleton
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
