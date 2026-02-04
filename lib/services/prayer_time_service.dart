import 'package:adhan/adhan.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';

class PrayerTimeService {
  /// Get Prayer Times for a specific location
  Future<PrayerTimes> getPrayerTimes(double latitude, double longitude) async {
    final myCoordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes.today(myCoordinates, params);
    return prayerTimes;
  }

  /// Get Prayer Times for a specific date
  Future<PrayerTimes> getPrayerTimesForDate(
    double latitude,
    double longitude,
    DateTime date,
  ) async {
    final myCoordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes(
      myCoordinates,
      DateComponents.from(date),
      params,
    );
    return prayerTimes;
  }

  /// Get Readable Name for Prayer
  String getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return "Fajr";
      case Prayer.sunrise:
        return "Sunrise";
      case Prayer.dhuhr:
        return "Dhuhr";
      case Prayer.asr:
        return "Asr";
      case Prayer.maghrib:
        return "Maghrib";
      case Prayer.isha:
        return "Isha";
      default:
        return "None";
    }
  }

  /// Get Next Prayer
  Prayer getNextPrayer(PrayerTimes prayerTimes) {
    return prayerTimes.nextPrayer();
  }

  /// Get Current Prayer
  Prayer getCurrentPrayer(PrayerTimes prayerTimes) {
    return prayerTimes.currentPrayer();
  }

  /// Get Address from Coordinates
  Future<String> getAddress(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.locality}, ${place.country}";
      }
      return "Unknown Location";
    } catch (e) {
      return "Location Error";
    }
  }

  /// Check if it is Ramadan
  bool isRamadan() {
    final dijriDate = HijriCalendar.now();
    return dijriDate.hMonth == 9;
  }

  /// Format Date
  String getFormattedDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }
}
