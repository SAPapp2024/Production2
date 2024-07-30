import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:location/location.dart';

@injectable
class LocationService {
  Future<LatLng> getSingleLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Future.error("Permissions not granted");
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return Future.error("Permissions not granted");
      }
    }
    locationData = await location.getLocation();
    if (locationData.latitude != null && locationData.longitude != null) {
      return LatLng(locationData.latitude!, locationData.longitude!);
    } else {
      return Future.error("Location not getting all values");
    }
  }
}