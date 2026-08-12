import 'package:blessing/constands/colors.dart';
import 'package:blessing/core/widgets/custom_widgets.dart';
import 'package:blessing/services/notification_service.dart';
import 'package:blessing/services/prayer_time_service.dart';
import 'package:blessing/views/theme_settings_screen.dart';
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
  final Color primaryGreen = const Color(0xFF00FF66);
  final AppColors colors = AppColors();

  // Settings State
  bool _autoLocation = true;
  String _currentCity = "Kozhikode, India";
  String _calcMethod = "Muslim World League";
  String _asrMadhab = "Standard (Shafi, Maliki, Hanbali)";
  String _fontSize = "100%";
  bool _adhanNotifications = true;
  String _quranReciter = "Mishary Rashid Alafasy";

  final List<String> _calcMethods = [
    'Muslim World League',
    'ISNA (North America)',
    'Umm al-Qura (Makkah)',
    'Egyptian General Authority',
    'University of Islamic Sciences, Karachi',
  ];

  final List<String> _madhabOptions = [
    'Standard (Shafi, Maliki, Hanbali)',
    'Hanafi (Later Asr)',
  ];

  final List<String> _fontSizes = [
    '80%',
    '90%',
    '100%',
    '110%',
    '120%',
  ];

  final List<String> _reciters = [
    'Mishary Rashid Alafasy',
    'Abdul Basit Abdul Samad',
    'Saad Al-Ghamdi',
    'Mahmoud Khalil Al-Hussary',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _autoLocation = prefs.getBool('auto_location') ?? true;
      _currentCity = prefs.getString('user_city') ?? "Kozhikode, India";
      _calcMethod = prefs.getString('calc_method') ?? _calcMethods[0];
      _asrMadhab = prefs.getString('madhab') ?? _madhabOptions[0];
      _fontSize = prefs.getString('font_size') ?? "100%";
      _adhanNotifications = prefs.getBool('adhan_notifs') ?? true;
      _quranReciter = prefs.getString('quran_reciter') ?? _reciters[0];
    });
  }

  Future<void> _saveBool(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  Future<void> _saveString(String key, String val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, val);
  }

  void _showSelectionModal({
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E1420),
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
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final item = options[index];
                      final isSelected = item == selectedValue;

                      return ListTile(
                        onTap: () {
                          onSelected(item);
                          Navigator.pop(ctx);
                        },
                        title: Text(
                          item,
                          style: GoogleFonts.outfit(
                            color: isSelected ? primaryGreen : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded, color: primaryGreen)
                            : null,
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
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Center(
          child: CustomCircleIconButton(
            icon: Icons.keyboard_arrow_left_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Settings',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // BRAND BANNER
              Text(
                "PrayerToday",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Nurture your spiritual growth",
                style: GoogleFonts.outfit(
                  color: primaryGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),

              // ACCOUNT & LOCATION
              _buildCategoryHeader("ACCOUNT & LOCATION"),
              _buildGroupedCard([
                _buildTile(
                  icon: Icons.person_rounded,
                  title: "Profile Details",
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  onTap: () {},
                ),
                _buildTile(
                  icon: Icons.location_on_rounded,
                  title: "Automatic Location",
                  trailing: Switch(
                    value: _autoLocation,
                    onChanged: (val) {
                      setState(() => _autoLocation = val);
                      _saveBool('auto_location', val);
                    },
                    activeThumbColor: primaryGreen,
                    activeTrackColor: primaryGreen.withValues(alpha: 0.3),
                  ),
                ),
                _buildTile(
                  icon: Icons.map_rounded,
                  title: "Manual City Selection",
                  subtitle: _currentCity,
                  trailing: const Icon(Icons.edit_outlined, color: Colors.white54, size: 18),
                  onTap: () {},
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 24),

              // PRAYER CALCULATION
              _buildCategoryHeader("PRAYER CALCULATION"),
              _buildGroupedCard([
                _buildTile(
                  icon: Icons.calculate_rounded,
                  title: "Calculation Method",
                  subtitle: _calcMethod,
                  trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
                  onTap: () {
                    _showSelectionModal(
                      title: "Calculation Method",
                      options: _calcMethods,
                      selectedValue: _calcMethod,
                      onSelected: (val) {
                        setState(() => _calcMethod = val);
                        _saveString('calc_method', val);
                      },
                    );
                  },
                ),
                _buildTile(
                  icon: Icons.alt_route_rounded,
                  title: "Asr Madhab",
                  subtitle: _asrMadhab,
                  trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
                  onTap: () {
                    _showSelectionModal(
                      title: "Asr Madhab",
                      options: _madhabOptions,
                      selectedValue: _asrMadhab,
                      onSelected: (val) {
                        setState(() => _asrMadhab = val);
                        _saveString('madhab', val);
                      },
                    );
                  },
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 24),

              // DISPLAY & THEME
              _buildCategoryHeader("DISPLAY & THEME"),
              _buildGroupedCard([
                _buildTile(
                  icon: Icons.palette_rounded,
                  title: "App Theme",
                  subtitle: "Customize colors & presets",
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ThemeSettingsScreen()),
                    );
                  },
                ),
                _buildTile(
                  icon: Icons.text_fields_rounded,
                  title: "Global Font Size",
                  subtitle: "Adjust text size for Duas & Quran: $_fontSize",
                  trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
                  onTap: () {
                    _showSelectionModal(
                      title: "Global Font Size",
                      options: _fontSizes,
                      selectedValue: _fontSize,
                      onSelected: (val) {
                        setState(() => _fontSize = val);
                        _saveString('font_size', val);
                      },
                    );
                  },
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 24),

              // AUDIO & ADHAN
              _buildCategoryHeader("AUDIO & ADHAN"),
              _buildGroupedCard([
                _buildTile(
                  icon: Icons.notifications_rounded,
                  title: "Adhan Notifications",
                  trailing: Switch(
                    value: _adhanNotifications,
                    onChanged: (val) {
                      setState(() => _adhanNotifications = val);
                      _saveBool('adhan_notifs', val);
                    },
                    activeThumbColor: primaryGreen,
                    activeTrackColor: primaryGreen.withValues(alpha: 0.3),
                  ),
                ),
                _buildTile(
                  icon: Icons.record_voice_over_rounded,
                  title: "Quran Reciter",
                  subtitle: _quranReciter,
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  onTap: () {
                    _showSelectionModal(
                      title: "Quran Reciter",
                      options: _reciters,
                      selectedValue: _quranReciter,
                      onSelected: (val) {
                        setState(() => _quranReciter = val);
                        _saveString('quran_reciter', val);
                      },
                    );
                  },
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 24),

              // SYSTEM & SYNC
              _buildCategoryHeader("SYSTEM & SYNC"),
              _buildGroupedCard([
                _buildTile(
                  icon: Icons.sync_rounded,
                  title: "Reload All Data",
                  subtitle: "Sync prayer times and settings",
                  trailing: const Icon(Icons.refresh_rounded, color: Colors.white54),
                  onTap: () async {
                    final pos = await Geolocator.getLastKnownPosition();
                    if (pos != null) {
                      final pt = await PrayerTimeService().getPrayerTimes(pos.latitude, pos.longitude);
                      await NotificationService().syncPrayerNotifications(pt);
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Data reloaded & synced"),
                        backgroundColor: const Color(0xFF131924),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
                _buildTile(
                  icon: Icons.folder_outlined,
                  title: "Offline Data",
                  subtitle: "Manage downloaded content",
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  onTap: () {},
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 32),

              // LOG IN / REGISTER BUTTON MATCHING SCREENSHOT
              Center(
                child: SizedBox(
                  width: 240,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Authentication coming soon"),
                          backgroundColor: const Color(0xFF131924),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login_rounded, color: Colors.black, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Log In / Register",
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // FOOTER APP VERSION
              Center(
                child: Column(
                  children: [
                    Text(
                      "PrayerToday App v2.4.0 (120)",
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Peace be upon you",
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildGroupedCard(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131924),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(children: tiles),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryGreen, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: trailing,
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 18,
            endIndent: 18,
            color: Colors.white.withValues(alpha: 0.04),
          ),
      ],
    );
  }
}
