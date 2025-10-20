import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<LocationPermission> ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // We only return deniedForever here to indicate the user must enable GPS
      return LocationPermission.deniedForever;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }
}


