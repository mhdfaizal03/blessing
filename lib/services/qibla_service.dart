import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class QiblaService {
  static const double makkahLat = 21.422487;
  static const double makkahLon = 39.826206;

  /// get location status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// request permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  /// Get address string from coordinates
  Future<String> getAddressDisplay(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.locality}, ${place.country}";
      }
    } catch (e) {
      // Handle error
    }
    return "Unknown Location";
  }

  /// Calculate Qibla bearing from current location
  double calculateQibla(double lat, double lon) {
    double phiK = makkahLat * math.pi / 180.0;
    double lambdaK = makkahLon * math.pi / 180.0;
    double phi = lat * math.pi / 180.0;
    double lambda = lon * math.pi / 180.0;
    double psi =
        180.0 /
        math.pi *
        math.atan2(
          math.sin(lambdaK - lambda),
          math.cos(phi) * math.tan(phiK) -
              math.sin(phi) * math.cos(lambdaK - lambda),
        );
    return psi;
  }

  /// Calculate distance to Makkah in km
  double calculateDistance(double lat, double lon) {
    return Geolocator.distanceBetween(lat, lon, makkahLat, makkahLon) / 1000;
  }

  /// Stream of compass events
  Stream<CompassEvent>? get compassStream => FlutterCompass.events;
}
