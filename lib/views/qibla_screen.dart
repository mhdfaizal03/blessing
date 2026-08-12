import 'dart:async';
import 'dart:math' as math;

import 'package:blessing/constands/colors.dart';
import 'package:blessing/services/local_storage_service.dart';
import 'package:blessing/services/qibla_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final Color primaryGreen = const Color(0xFF00FF66);
  final AppColors colors = AppColors();

  final QiblaService _qiblaService = QiblaService();
  final LocalStorageService _storageService = LocalStorageService();

  double _deviceHeading = 0;
  double _qiblaBearing = -69;

  String _currentAddress = "Kozhikode, India";
  String _distance = "3994 km";

  StreamSubscription<CompassEvent>? _compassSubscription;

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

  Future<void> _initQibla() async {
    if (!mounted) return;

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _currentAddress = "Kozhikode, India";
        });
        return;
      }

      final cached = await _storageService.getCachedLocation();
      if (cached != null) {
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
          _qiblaBearing = bearing;
          _distance = "${dist.toStringAsFixed(0)} km";
          _currentAddress = cached['address'] ?? "Kozhikode, India";
        });

        _startCompassStream();
        return;
      }

      final position = await _qiblaService.getCurrentLocation();

      if (position == null) {
        if (!mounted) return;
        setState(() {
          _currentAddress = "Kozhikode, India";
        });
        _startCompassStream();
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
        _qiblaBearing = bearing;
        _distance = "${dist.toStringAsFixed(0)} km";
      });

      _getAddr(position);
      _startCompassStream();
    } catch (e) {
      debugPrint("Qibla init error: $e");
      if (!mounted) return;
      setState(() {
        _currentAddress = "Kozhikode, India";
      });
      _startCompassStream();
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

  String _getCardinalDirection(double heading) {
    double normalized = (heading % 360 + 360) % 360;
    if (normalized >= 337.5 || normalized < 22.5) return "N";
    if (normalized >= 22.5 && normalized < 67.5) return "NE";
    if (normalized >= 67.5 && normalized < 112.5) return "E";
    if (normalized >= 112.5 && normalized < 157.5) return "SE";
    if (normalized >= 157.5 && normalized < 202.5) return "S";
    if (normalized >= 202.5 && normalized < 247.5) return "SW";
    if (normalized >= 247.5 && normalized < 292.5) return "W";
    return "NW";
  }

  void _showSearchLocationModal() {
    final searchController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF0E1420),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
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
              Center(
                child: Text(
                  "Search Location",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF192232),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: TextField(
                  controller: searchController,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search_rounded, color: primaryGreen, size: 22),
                    hintText: "Enter city or place...",
                    hintStyle: GoogleFonts.outfit(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _cityTile("Kozhikode, India", 11.2588, 75.7804),
                    _cityTile("Mecca, Saudi Arabia", 21.4225, 39.8262),
                    _cityTile("Medina, Saudi Arabia", 24.4672, 39.6112),
                    _cityTile("Dubai, UAE", 25.2048, 55.2708),
                    _cityTile("London, UK", 51.5074, -0.1278),
                    _cityTile("New York, USA", 40.7128, -74.0060),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cityTile(String city, double lat, double lng) {
    return ListTile(
      leading: Icon(Icons.location_city_rounded, color: primaryGreen),
      title: Text(city, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
      onTap: () {
        final bearing = _qiblaService.calculateQibla(lat, lng);
        final dist = _qiblaService.calculateDistance(lat, lng);
        setState(() {
          _currentAddress = city;
          _qiblaBearing = bearing;
          _distance = "${dist.toStringAsFixed(0)} km";
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Qibla Finder',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              _buildLocationCard(),
              const SizedBox(height: 32),
              Center(
                child: _buildCompassDial(
                  deviceHeading: _deviceHeading,
                  qiblaBearing: _qiblaBearing,
                ),
              ),
              const SizedBox(height: 28),
              _buildHeadingDisplay(),
              const SizedBox(height: 28),
              _buildStatsRow(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on_rounded, color: primaryGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "CURRENT LOCATION",
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _currentAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showSearchLocationModal,
            child: Text(
              "CHANGE",
              style: GoogleFonts.outfit(
                color: primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          // Outer Ticks & Cardinal Directions Ring
          Transform.rotate(
            angle: -deviceHeading * (math.pi / 180),
            child: SizedBox(
              width: _dialSize,
              height: _dialSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(_dialSize, _dialSize),
                    painter: CompassTicksPainter(accentColor: primaryGreen),
                  ),
                  Positioned(
                    top: 20,
                    child: Text(
                      "N",
                      style: GoogleFonts.outfit(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Text(
                      "S",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    child: Text(
                      "W",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    child: Text(
                      "E",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dynamic Green Mosque Badge orbiting Qibla bearing
          Transform.rotate(
            angle: needleAngle,
            child: SizedBox(
              width: _dialSize,
              height: _dialSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 55,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF003816),
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryGreen, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: primaryGreen.withValues(alpha: 0.35),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(Icons.mosque_rounded, color: primaryGreen, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center Heading Circle
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFF131924),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${_deviceHeading.toInt()}°",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "HEADING",
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadingDisplay() {
    final cardinal = _getCardinalDirection(_deviceHeading);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              "${_deviceHeading.toInt()}° ",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              cardinal,
              style: GoogleFonts.outfit(
                color: primaryGreen,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Align arrow with Qibla icon",
          style: GoogleFonts.outfit(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF131924),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DISTANCE",
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _distance,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF131924),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "QIBLA",
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${_qiblaBearing.toInt()}°",
                  style: GoogleFonts.outfit(
                    color: primaryGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CompassTicksPainter extends CustomPainter {
  final Color accentColor;
  CompassTicksPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.0;

    final majorTickPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1.8;

    final mainTickPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3.0;

    for (int i = 0; i < 360; i += 3) {
      final angle = (i - 90) * math.pi / 180;
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;

      final tickLength = isCardinal ? 16.0 : (isMajor ? 12.0 : 6.0);
      final p1 = Offset(
        center.dx + (radius - tickLength) * math.cos(angle),
        center.dy + (radius - tickLength) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.drawLine(
        p1,
        p2,
        isCardinal ? mainTickPaint : (isMajor ? majorTickPaint : tickPaint),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
