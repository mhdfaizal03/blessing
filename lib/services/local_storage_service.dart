import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyLat = 'last_lat';
  static const String _keyLng = 'last_lng';
  static const String _keyLastFetchDate = 'last_fetch_date';
  static const String _keyAddress = 'last_address';
  static const String _keyLastSurah = 'last_surah';
  static const String _keyLastAyah = 'last_ayah';
  static const String _keyPrayerLogPrefix = 'prayer_log_';
  static const String _keyTotalPrayers = 'total_prayers_count';
  static const String _keyLastStreakDate = 'last_streak_date';
  static const String _keyCurrentStreak = 'current_streak';
  static const String _keyAzanEnabledPrefix = 'azan_enabled_';

  /// Save location data and current timestamp
  Future<void> saveLocationData({
    required double lat,
    required double lng,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyLat, lat);
    await prefs.setDouble(_keyLng, lng);
    await prefs.setString(_keyAddress, address);
    await prefs.setString(_keyLastFetchDate, DateTime.now().toIso8601String());
  }

  /// Get cached location
  Future<Map<String, dynamic>?> getCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_keyLat);
    final lng = prefs.getDouble(_keyLng);
    final addr = prefs.getString(_keyAddress);

    if (lat != null && lng != null && addr != null) {
      return {'lat': lat, 'lng': lng, 'address': addr};
    }
    return null;
  }

  /// Check if data needs to be reloaded (if last fetch was on a different day)
  Future<bool> needsReload() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetchStr = prefs.getString(_keyLastFetchDate);

    if (lastFetchStr == null) return true;

    final lastFetchDate = DateTime.parse(lastFetchStr);
    final now = DateTime.now();

    // If it's a different day, we need a reload
    return lastFetchDate.year != now.year ||
        lastFetchDate.month != now.month ||
        lastFetchDate.day != now.day;
  }

  /// Save last read/played Surah and Ayah
  Future<void> saveLastRead(int surahNumber, int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastSurah, surahNumber);
    await prefs.setInt(_keyLastAyah, ayahNumber);
  }

  /// Get last read/played Surah and Ayah
  Future<Map<String, int>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final surah = prefs.getInt(_keyLastSurah);
    final ayah = prefs.getInt(_keyLastAyah);

    if (surah != null && ayah != null) {
      return {'surah': surah, 'ayah': ayah};
    }
    return null;
  }

  /// Toggle prayer log
  Future<bool> togglePrayerLog(DateTime date, String prayerName) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final key = '$_keyPrayerLogPrefix${dateStr}_$prayerName';

    final currentStatus = prefs.getBool(key) ?? false;
    final newStatus = !currentStatus;
    await prefs.setBool(key, newStatus);

    // Update total count
    int total = prefs.getInt(_keyTotalPrayers) ?? 0;
    if (newStatus) {
      total++;
    } else {
      total = (total > 0) ? total - 1 : 0;
    }
    await prefs.setInt(_keyTotalPrayers, total);

    // Update streak (Simplified: check if all 5 prayers of today are done)
    if (newStatus) {
      await _updateStreak(date);
    }

    return newStatus;
  }

  /// Check if prayer is logged
  Future<bool> isPrayerLogged(DateTime date, String prayerName) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final key = '$_keyPrayerLogPrefix${dateStr}_$prayerName';
    return prefs.getBool(key) ?? false;
  }

  /// Check if any prayer is logged for a date
  Future<bool> isAnyPrayerLogged(DateTime date) async {
    final prayers = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
    for (var p in prayers) {
      if (await isPrayerLogged(date, p)) return true;
    }
    return false;
  }

  /// Get total logged prayers
  Future<int> getTotalLoggedPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalPrayers) ?? 0;
  }

  /// Get current streak
  Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentStreak) ?? 0;
  }

  /// Set Azan enabled status
  Future<void> setAzanEnabled(String prayerName, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyAzanEnabledPrefix$prayerName', enabled);
  }

  /// Get Azan enabled status
  Future<bool> isAzanEnabled(String prayerName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyAzanEnabledPrefix$prayerName') ?? false;
  }

  /// Private helper to update streak
  Future<void> _updateStreak(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final prayers = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];

    bool allDone = true;
    for (var p in prayers) {
      if (!(await isPrayerLogged(date, p))) {
        allDone = false;
        break;
      }
    }

    if (allDone) {
      final lastStreakStr = prefs.getString(_keyLastStreakDate);
      final todayStr = DateFormat('yyyy-MM-dd').format(date);

      if (lastStreakStr != todayStr) {
        int streak = prefs.getInt(_keyCurrentStreak) ?? 0;

        if (lastStreakStr != null) {
          final lastDate = DateTime.parse(lastStreakStr);
          final yesterday = date.subtract(const Duration(days: 1));

          if (lastDate.year == yesterday.year &&
              lastDate.month == yesterday.month &&
              lastDate.day == yesterday.day) {
            streak++;
          } else {
            streak = 1;
          }
        } else {
          streak = 1;
        }

        await prefs.setInt(_keyCurrentStreak, streak);
        await prefs.setString(_keyLastStreakDate, todayStr);
      }
    }
  }
}
