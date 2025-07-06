import 'package:location/location.dart';

class LocationService {
  final Location location = Location();
  bool _initialized = false;

  /// ต้องเรียกก่อน getLatitude/getLongitude!
  Future<void> initialize() async {
    while (true) {
      // 1. Check service
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) continue; // วนขอใหม่จนกว่าจะเปิด
      }
      // 2. Check permission
      PermissionStatus permission = await location.hasPermission();
      if (permission != PermissionStatus.granted) {
        permission = await location.requestPermission();
        if (permission != PermissionStatus.granted)
          continue; // วนขอใหม่จนกว่าจะอนุญาต
      }
      // 3. Success
      _initialized = true;
      break;
    }
  }

  Future<double> getLatitude() async {
    if (!_initialized) {
      throw Exception(
          'LocationService not initialized! Call initialize() first.');
    }
    while (true) {
      try {
        final loc = await location.getLocation();
        if (loc.latitude != null) return loc.latitude!;
      } catch (_) {}
      // วนขอจนกว่าจะได้ค่า
    }
  }

  Future<double> getLongitude() async {
    if (!_initialized) {
      throw Exception(
          'LocationService not initialized! Call initialize() first.');
    }
    while (true) {
      try {
        final loc = await location.getLocation();
        if (loc.longitude != null) return loc.longitude!;
      } catch (_) {}
      // วนขอจนกว่าจะได้ค่า
    }
  }
}
