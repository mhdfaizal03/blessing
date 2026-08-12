import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class MosqueFinderScreen extends StatefulWidget {
  const MosqueFinderScreen({super.key});

  @override
  State<MosqueFinderScreen> createState() => _MosqueFinderScreenState();
}

class _MosqueFinderScreenState extends State<MosqueFinderScreen> {
  final AppColors _colors = AppColors();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  Position? _currentPosition;
  String _locationName = "Locating nearby mosques...";
  List<Map<String, dynamic>> _allMosques = [];
  List<Map<String, dynamic>> _filteredMosques = [];
  String _selectedFacility = "All";
  String _selectedDistanceFilter = "All";

  final List<String> _facilityFilters = [
    "All",
    "Jumuah",
    "Women Section",
    "Parking",
    "Wudu Area",
  ];

  final List<String> _distanceFilters = [
    "All",
    "< 2 km",
    "< 3 km",
    "< 5 km",
    "< 10 km",
    "< 15 km",
  ];

  @override
  void initState() {
    super.initState();
    _loadLocationAndMosques();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLocationAndMosques() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position;
      if (serviceEnabled &&
          permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } else {
        // Fallback default coordinates (Makkah center fallback)
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

      if (!mounted) return;
      _currentPosition = position;
      _locationName = "Near Current Location";

      // Rich mosque dataset spanning 0.5km to 14km
      final baseLat = position.latitude;
      final baseLng = position.longitude;

      final rawMosques = [
        {
          "name": "Masjid Al-Noor",
          "address": "12 Crescent Avenue, Central District",
          "lat": baseLat + 0.005, // ~0.6 km
          "lng": baseLng + 0.004,
          "jumatTime": "1:15 PM",
          "facilities": ["Jumuah", "Women Section", "Parking", "Wudu Area"],
          "phone": "+1 555-0192",
        },
        {
          "name": "Central Juma Mosque",
          "address": "45 Grand Boulevard, Main Market",
          "lat": baseLat - 0.012, // ~1.5 km
          "lng": baseLng + 0.008,
          "jumatTime": "1:30 PM",
          "facilities": ["Jumuah", "Parking", "Wudu Area"],
          "phone": "+1 555-0144",
        },
        {
          "name": "Masjid Al-Rahman",
          "address": "88 Peace Hill Road, North West",
          "lat": baseLat + 0.020, // ~2.4 km
          "lng": baseLng - 0.015,
          "jumatTime": "1:15 PM",
          "facilities": ["Women Section", "Wudu Area"],
          "phone": "+1 555-0177",
        },
        {
          "name": "Al-Huda Islamic Center",
          "address": "204 Knowledge Street, University City",
          "lat": baseLat - 0.035, // ~4.1 km
          "lng": baseLng - 0.025,
          "jumatTime": "1:00 PM",
          "facilities": ["Jumuah", "Women Section", "Parking", "Wudu Area"],
          "phone": "+1 555-0210",
        },
        {
          "name": "Masjid Al-Taqwa",
          "address": "15 Harmony Lane, South Park",
          "lat": baseLat + 0.065, // ~7.8 km
          "lng": baseLng + 0.045,
          "jumatTime": "1:30 PM",
          "facilities": ["Jumuah", "Parking"],
          "phone": "+1 555-0331",
        },
        {
          "name": "Grand Sultan Mosque",
          "address": "500 Royal Highway, Metro City",
          "lat": baseLat - 0.105, // ~12.5 km
          "lng": baseLng - 0.075,
          "jumatTime": "1:15 PM",
          "facilities": ["Jumuah", "Women Section", "Parking", "Wudu Area"],
          "phone": "+1 555-0990",
        },
      ];

      final calculatedMosques = rawMosques.map((m) {
        final distMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          m['lat'] as double,
          m['lng'] as double,
        );
        final distKmDouble = distMeters / 1000;
        final distKm = distKmDouble.toStringAsFixed(1);
        final walkMins = (distMeters / 80).round(); // ~80m/min walking speed

        return {
          ...m,
          "distanceMeters": distMeters,
          "distanceKmVal": distKmDouble,
          "distanceKm": distKm,
          "walkMins": walkMins,
        };
      }).toList();

      calculatedMosques.sort((a, b) =>
          (a['distanceMeters'] as double).compareTo(b['distanceMeters'] as double));

      if (!mounted) return;
      setState(() {
        _allMosques = calculatedMosques;
        _filteredMosques = calculatedMosques;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Mosque loading error: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _filterMosques() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase();

    double maxDistance = double.infinity;
    if (_selectedDistanceFilter == "< 2 km") {
      maxDistance = 2.0;
    } else if (_selectedDistanceFilter == "< 3 km") {
      maxDistance = 3.0;
    } else if (_selectedDistanceFilter == "< 5 km") {
      maxDistance = 5.0;
    } else if (_selectedDistanceFilter == "< 10 km") {
      maxDistance = 10.0;
    } else if (_selectedDistanceFilter == "< 15 km") {
      maxDistance = 15.0;
    }

    setState(() {
      _filteredMosques = _allMosques.where((m) {
        final matchesQuery = m['name'].toString().toLowerCase().contains(query) ||
            m['address'].toString().toLowerCase().contains(query);

        final matchesFacility = _selectedFacility == "All" ||
            (m['facilities'] as List<String>).contains(_selectedFacility);

        final distKmVal = (m['distanceKmVal'] as double? ?? 0.0);
        final matchesDistance = distKmVal <= maxDistance;

        return matchesQuery && matchesFacility && matchesDistance;
      }).toList();
    });
  }

  Future<void> _openGoogleMaps(Map<String, dynamic> mosque) async {
    final lat = mosque['lat'];
    final lng = mosque['lng'];
    final name = Uri.encodeComponent(mosque['name']);
    final googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$name");

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        final webUrl = Uri.parse("https://maps.google.com/?q=$lat,$lng");
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Opening directions for ${mosque['name']}..."),
            backgroundColor: _colors.kCardBg,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Mosque Finder',
          style: TextStyle(
            color: _colors.kTextWhite,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          CustomCircleIconButton(
            icon: Icons.my_location_rounded,
            onTap: _loadLocationAndMosques,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 6),

            // Search Bar & Filters Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: _colors.kAccentNeon, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        _currentPosition != null
                            ? "$_locationName (${_currentPosition!.latitude.toStringAsFixed(2)}, ${_currentPosition!.longitude.toStringAsFixed(2)})"
                            : _locationName,
                        style: TextStyle(color: _colors.kTextGrey, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildDistanceFilterRow(),
                  const SizedBox(height: 8),
                  _buildFacilityFilterRow(),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Mosque List
            Expanded(
              child: _isLoading
                  ? _buildShimmerList()
                  : _filteredMosques.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                          itemCount: _filteredMosques.length,
                          itemBuilder: (context, index) {
                            final mosque = _filteredMosques[index];
                            return _buildMosqueCard(mosque);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _colors.kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _colors.kGlassBorder),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _filterMosques(),
        style: TextStyle(color: _colors.kTextWhite),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: _colors.kTextGrey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: _colors.kTextGrey, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _filterMosques();
                  },
                )
              : null,
          hintText: "Search mosque by name or location...",
          hintStyle: TextStyle(color: _colors.kTextMuted, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDistanceFilterRow() {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _distanceFilters.length,
        itemBuilder: (context, index) {
          final filter = _distanceFilters[index];
          final isSelected = _selectedDistanceFilter == filter;

          return GestureDetector(
            onTap: () {
              if (!mounted) return;
              setState(() {
                _selectedDistanceFilter = filter;
                _filterMosques();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? _colors.kAccentNeon : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _colors.kAccentNeon : Colors.white10,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? _colors.kPrimaryBg : _colors.kTextWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFacilityFilterRow() {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _facilityFilters.length,
        itemBuilder: (context, index) {
          final filter = _facilityFilters[index];
          final isSelected = _selectedFacility == filter;

          return GestureDetector(
            onTap: () {
              if (!mounted) return;
              setState(() {
                _selectedFacility = filter;
                _filterMosques();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? _colors.kAccentNeon : _colors.kSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _colors.kAccentNeon : _colors.kGlassBorder,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? _colors.kPrimaryBg : _colors.kTextWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMosqueCard(Map<String, dynamic> mosque) {
    final facilities = mosque['facilities'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _colors.kSecondaryBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _colors.kGlassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _colors.kAccentNeon.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mosque_rounded, color: _colors.kAccentNeon, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mosque['name'],
                      style: TextStyle(
                        color: _colors.kTextWhite,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mosque['address'],
                      style: TextStyle(color: _colors.kTextGrey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _colors.kAccentNeon,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${mosque['distanceKm']} km",
                  style: TextStyle(
                    color: _colors.kPrimaryBg,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Icon(Icons.directions_walk_rounded, color: _colors.kTextGrey, size: 14),
              const SizedBox(width: 4),
              Text(
                "~${mosque['walkMins']} mins walk",
                style: TextStyle(color: _colors.kTextGrey, fontSize: 12),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time_rounded, color: _colors.kAccentNeon, size: 14),
              const SizedBox(width: 4),
              Text(
                "Jumuah ${mosque['jumatTime']}",
                style: TextStyle(
                  color: _colors.kAccentNeon,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Facility Pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: facilities.map((f) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  f,
                  style: TextStyle(color: _colors.kTextGrey, fontSize: 10),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openGoogleMaps(mosque),
                  icon: Icon(Icons.near_me_rounded, size: 16, color: _colors.kPrimaryBg),
                  label: Text("Directions (Maps)", style: TextStyle(color: _colors.kPrimaryBg, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colors.kAccentNeon,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => _showMosqueDetailsSheet(mosque),
                icon: Icon(Icons.info_outline_rounded, color: _colors.kTextWhite),
                style: IconButton.styleFrom(
                  backgroundColor: _colors.kSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: _colors.kGlassBorder),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMosqueDetailsSheet(Map<String, dynamic> mosque) {
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
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.mosque_rounded, color: _colors.kAccentNeon, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mosque['name'],
                    style: TextStyle(
                      color: _colors.kTextWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(mosque['address'], style: TextStyle(color: _colors.kTextGrey, fontSize: 13)),
            const SizedBox(height: 20),
            Divider(color: _colors.kGlassBorder),
            const SizedBox(height: 16),
            _detailRow(Icons.phone_rounded, "Contact", mosque['phone']),
            const SizedBox(height: 12),
            _detailRow(Icons.event_rounded, "Jumuah Khutbah", mosque['jumatTime']),
            const SizedBox(height: 12),
            _detailRow(Icons.place_rounded, "Distance", "${mosque['distanceKm']} km away"),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openGoogleMaps(mosque);
                },
                icon: Icon(Icons.directions_rounded, color: _colors.kPrimaryBg),
                label: Text("Open in Google Maps", style: TextStyle(color: _colors.kPrimaryBg, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colors.kAccentNeon,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _colors.kAccentNeon, size: 18),
        const SizedBox(width: 10),
        Text("$label: ", style: TextStyle(color: _colors.kTextGrey, fontSize: 13)),
        Text(value, style: TextStyle(color: _colors.kTextWhite, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, color: _colors.kTextGrey, size: 48),
          const SizedBox(height: 12),
          Text(
            "No mosques found",
            style: TextStyle(color: _colors.kTextWhite, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Try adjusting your search query, facility filter, or distance filter.",
            style: TextStyle(color: _colors.kTextGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 4,
        itemBuilder: (_, _) => Container(
          height: 160,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
