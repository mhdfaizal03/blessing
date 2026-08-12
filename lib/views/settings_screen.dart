import 'package:blessing/services/notification_service.dart';
import 'package:blessing/services/prayer_time_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Prayer Notification Toggles
  bool _fajrNotif = true;
  bool _dhuhrNotif = true;
  bool _asrNotif = true;
  bool _maghribNotif = true;
  bool _ishaNotif = true;
  bool _sunriseNotif = false;

  // Calculation Settings
  String _calculationMethod = 'Muslim World League (MWL)';
  String _madhab = 'Standard (Shafi, Maliki, Hanbali)';
  String _highLatitude = 'Middle of the Night';
  String _adhanSound = 'Makkah Al-Mukarramah';

  // Manual Prayer Offsets (in minutes)
  int _fajrOffset = 0;
  int _dhuhrOffset = 0;
  int _asrOffset = 0;
  int _maghribOffset = 0;
  int _ishaOffset = 0;

  // General & Location
  bool _autoDetectLocation = true;
  String _currentLocationName = 'Locating...';
  bool _isLocating = false;

  final List<String> _calcMethods = [
    'Muslim World League (MWL)',
    'ISNA (North America)',
    'Umm al-Qura (Makkah)',
    'Egyptian General Authority',
    'University of Islamic Sciences, Karachi',
    'Gulf Region Authority',
    'Moonsighting Committee Worldwide',
  ];

  final List<String> _madhabOptions = [
    'Standard (Shafi, Maliki, Hanbali)',
    'Hanafi (Later Asr)',
  ];

  final List<String> _highLatitudeOptions = [
    'Middle of the Night',
    'One Seventh',
    'Angle Based',
  ];

  final List<String> _adhanSounds = [
    'Makkah Al-Mukarramah',
    'Al-Madinah Al-Munawwarah',
    'Al-Aqsa Mosque',
    'Mishary Rashid Al-Afasy',
    'Soft Beep / Chime',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchCurrentLocation();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _fajrNotif = prefs.getBool('notif_fajr') ?? true;
      _dhuhrNotif = prefs.getBool('notif_dhuhr') ?? true;
      _asrNotif = prefs.getBool('notif_asr') ?? true;
      _maghribNotif = prefs.getBool('notif_maghrib') ?? true;
      _ishaNotif = prefs.getBool('notif_isha') ?? true;
      _sunriseNotif = prefs.getBool('notif_sunrise') ?? false;

      _calculationMethod = prefs.getString('calc_method') ?? _calcMethods[0];
      _madhab = prefs.getString('madhab') ?? _madhabOptions[0];
      _highLatitude = prefs.getString('high_lat') ?? _highLatitudeOptions[0];
      _adhanSound = prefs.getString('adhan_sound') ?? _adhanSounds[0];

      _fajrOffset = prefs.getInt('offset_fajr') ?? 0;
      _dhuhrOffset = prefs.getInt('offset_dhuhr') ?? 0;
      _asrOffset = prefs.getInt('offset_asr') ?? 0;
      _maghribOffset = prefs.getInt('offset_maghrib') ?? 0;
      _ishaOffset = prefs.getInt('offset_isha') ?? 0;

      _autoDetectLocation = prefs.getBool('auto_location') ?? true;
    });
  }

  Future<void> _saveBool(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);

    if (key.startsWith('notif_')) {
      try {
        final pos = await Geolocator.getLastKnownPosition();
        if (pos != null) {
          final pt = await PrayerTimeService().getPrayerTimes(pos.latitude, pos.longitude);
          await NotificationService().syncPrayerNotifications(pt);
        }
      } catch (_) {}
    }
  }

  Future<void> _saveString(String key, String val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, val);
  }

  Future<void> _saveInt(String key, int val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, val);
  }

  Future<void> _fetchCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 6),
          ),
        );
        if (!mounted) return;
        setState(() {
          _currentLocationName = '${pos.latitude.toStringAsFixed(3)}° N, ${pos.longitude.toStringAsFixed(3)}° E';
          _isLocating = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _currentLocationName = 'Location Permission Denied';
          _isLocating = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currentLocationName = 'Default Location Set (Makkah)';
        _isLocating = false;
      });
    }
  }

  void _showSelectionBottomSheet({
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final item = options[index];
                      final isSelected = item == selectedValue;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withValues(alpha: 0.15)
                              : const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? primaryColor : Colors.white10,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            onTap: () {
                              onSelected(item);
                              Navigator.pop(ctx);
                            },
                            title: Text(
                              item,
                              style: GoogleFonts.outfit(
                                color: isSelected ? primaryColor : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle_rounded, color: primaryColor, size: 20)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings & Calculation',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Prayer Notifications & Azan Alerts
            _buildSectionHeader('AZAN ALERTS & NOTIFICATIONS', Icons.notifications_active_rounded, primaryColor),
            const SizedBox(height: 12),
            _buildCard(
              children: [
                _buildSwitchTile('Fajr Prayer Azan', _fajrNotif, (val) {
                  setState(() => _fajrNotif = val);
                  _saveBool('notif_fajr', val);
                }),
                _buildDivider(),
                _buildSwitchTile('Dhuhr Prayer Azan', _dhuhrNotif, (val) {
                  setState(() => _dhuhrNotif = val);
                  _saveBool('notif_dhuhr', val);
                }),
                _buildDivider(),
                _buildSwitchTile('Asr Prayer Azan', _asrNotif, (val) {
                  setState(() => _asrNotif = val);
                  _saveBool('notif_asr', val);
                }),
                _buildDivider(),
                _buildSwitchTile('Maghrib Prayer Azan', _maghribNotif, (val) {
                  setState(() => _maghribNotif = val);
                  _saveBool('notif_maghrib', val);
                }),
                _buildDivider(),
                _buildSwitchTile('Isha Prayer Azan', _ishaNotif, (val) {
                  setState(() => _ishaNotif = val);
                  _saveBool('notif_isha', val);
                }),
                _buildDivider(),
                _buildSwitchTile('Sunrise Notification', _sunriseNotif, (val) {
                  setState(() => _sunriseNotif = val);
                  _saveBool('notif_sunrise', val);
                }),
              ],
            ),

            const SizedBox(height: 24),

            // Section 2: Calculation Authority & Jurisprudence
            _buildSectionHeader('PRAYER CALCULATION METHODS', Icons.tune_rounded, primaryColor),
            const SizedBox(height: 12),
            _buildCard(
              children: [
                _buildAlignedSelectionTile(
                  label: 'Calculation Authority',
                  selectedValue: _calculationMethod,
                  onTap: () {
                    _showSelectionBottomSheet(
                      title: 'Select Calculation Authority',
                      options: _calcMethods,
                      selectedValue: _calculationMethod,
                      onSelected: (val) {
                        setState(() => _calculationMethod = val);
                        _saveString('calc_method', val);
                      },
                    );
                  },
                ),
                _buildDivider(),
                _buildAlignedSelectionTile(
                  label: 'Asr Juristic Method (Madhab)',
                  selectedValue: _madhab,
                  onTap: () {
                    _showSelectionBottomSheet(
                      title: 'Select Asr Juristic Method',
                      options: _madhabOptions,
                      selectedValue: _madhab,
                      onSelected: (val) {
                        setState(() => _madhab = val);
                        _saveString('madhab', val);
                      },
                    );
                  },
                ),
                _buildDivider(),
                _buildAlignedSelectionTile(
                  label: 'High Latitude Rule',
                  selectedValue: _highLatitude,
                  onTap: () {
                    _showSelectionBottomSheet(
                      title: 'Select High Latitude Rule',
                      options: _highLatitudeOptions,
                      selectedValue: _highLatitude,
                      onSelected: (val) {
                        setState(() => _highLatitude = val);
                        _saveString('high_lat', val);
                      },
                    );
                  },
                ),
                _buildDivider(),
                _buildAlignedSelectionTile(
                  label: 'Azan Reciter & Sound',
                  selectedValue: _adhanSound,
                  onTap: () {
                    _showSelectionBottomSheet(
                      title: 'Select Azan Sound',
                      options: _adhanSounds,
                      selectedValue: _adhanSound,
                      onSelected: (val) {
                        setState(() => _adhanSound = val);
                        _saveString('adhan_sound', val);
                      },
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section 3: Manual Time Offsets (Fine-tuning)
            _buildSectionHeader('PRAYER TIME OFFSETS (MINUTES)', Icons.more_time_rounded, primaryColor),
            const SizedBox(height: 12),
            _buildCard(
              children: [
                _buildOffsetStepper('Fajr Offset', _fajrOffset, (newVal) {
                  setState(() => _fajrOffset = newVal);
                  _saveInt('offset_fajr', newVal);
                }),
                _buildDivider(),
                _buildOffsetStepper('Dhuhr Offset', _dhuhrOffset, (newVal) {
                  setState(() => _dhuhrOffset = newVal);
                  _saveInt('offset_dhuhr', newVal);
                }),
                _buildDivider(),
                _buildOffsetStepper('Asr Offset', _asrOffset, (newVal) {
                  setState(() => _asrOffset = newVal);
                  _saveInt('offset_asr', newVal);
                }),
                _buildDivider(),
                _buildOffsetStepper('Maghrib Offset', _maghribOffset, (newVal) {
                  setState(() => _maghribOffset = newVal);
                  _saveInt('offset_maghrib', newVal);
                }),
                _buildDivider(),
                _buildOffsetStepper('Isha Offset', _ishaOffset, (newVal) {
                  setState(() => _ishaOffset = newVal);
                  _saveInt('offset_isha', newVal);
                }),
              ],
            ),

            const SizedBox(height: 24),

            // Section 4: Geolocation & Location Services
            _buildSectionHeader('LOCATION & GPS SERVICES', Icons.my_location_rounded, primaryColor),
            const SizedBox(height: 12),
            _buildCard(
              children: [
                _buildSwitchTile('Auto-Detect GPS Location', _autoDetectLocation, (val) {
                  setState(() => _autoDetectLocation = val);
                  _saveBool('auto_location', val);
                }),
                _buildDivider(),
                ListTile(
                  title: Text(
                    'Current GPS Coordinates',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: Text(
                    _currentLocationName,
                    style: GoogleFonts.outfit(color: primaryColor, fontSize: 13),
                  ),
                  trailing: _isLocating
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                        )
                      : IconButton(
                          icon: Icon(Icons.refresh_rounded, color: primaryColor),
                          onPressed: _fetchCurrentLocation,
                        ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section 5: App Info
            _buildSectionHeader('ABOUT BLESSING APP', Icons.info_outline_rounded, primaryColor),
            const SizedBox(height: 12),
            _buildCard(
              children: [
                ListTile(
                  title: Text('App Version', style: GoogleFonts.outfit(color: Colors.white, fontSize: 15)),
                  subtitle: Text('v2.5.0 Premium Emerald Edition', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
                  trailing: Icon(Icons.verified_rounded, color: primaryColor, size: 20),
                ),
                _buildDivider(),
                ListTile(
                  title: Text('Developer & Credits', style: GoogleFonts.outfit(color: Colors.white, fontSize: 15)),
                  subtitle: Text('Blessing Islamic Suite • Built with Flutter', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Material(
      color: const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    final primaryColor = Theme.of(context).primaryColor;
    return SwitchListTile(
      activeThumbColor: primaryColor,
      title: Text(
        title,
        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildAlignedSelectionTile({
    required String label,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedValue,
                    style: GoogleFonts.outfit(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: primaryColor.withValues(alpha: 0.7), size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffsetStepper(String title, int currentValue, ValueChanged<int> onChanged) {
    final primaryColor = Theme.of(context).primaryColor;
    final displayStr = currentValue > 0 ? "+$currentValue min" : "$currentValue min";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.remove_rounded, color: Colors.white70, size: 18),
                  onPressed: () => onChanged(currentValue - 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    displayStr,
                    style: GoogleFonts.outfit(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add_rounded, color: Colors.white70, size: 18),
                  onPressed: () => onChanged(currentValue + 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.white.withValues(alpha: 0.05), indent: 16, endIndent: 16);
  }
}
