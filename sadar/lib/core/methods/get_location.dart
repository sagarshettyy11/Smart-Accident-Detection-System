import 'package:geolocator/geolocator.dart';

Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
  );

  return await Geolocator.getCurrentPosition(
    locationSettings: locationSettings,
  );
}


