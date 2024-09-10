import 'dart:async';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';  // Use geocoding for reverse geocoding

late LocationData _currentPosition;
String _address = "";
late GoogleMapController mapController;
late Marker marker;
Location location = Location();
late CameraPosition _cameraPosition =
    CameraPosition(target: LatLng(0, 0), zoom: 10.0);

LatLng _initialcameraposition = LatLng(0.5937, 0.9629);

Future<String> getLoc() async {

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  // Check if the location service is enabled
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return "null";
    }
  }

  // Check if the app has permission to access location
  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return "null";
    }
  }

  String details = "";

  // Get the current location
  _currentPosition = await location.getLocation();

  DateTime now = DateTime.now();
  details += DateFormat('EEE d MMM kk:mm:ss ').format(now);

  // Set the initial camera position based on the current location
  _initialcameraposition = LatLng(
      _currentPosition.latitude ?? 0.0, _currentPosition.longitude ?? 0.0);

  // Reverse geocode to get the address from coordinates
  await _getAddress(_currentPosition.latitude!, _currentPosition.longitude!)
      .then((placemarks) {
    if (placemarks.isNotEmpty) {
      // Build the address string from placemark data
      Placemark place = placemarks[0];
      _address = "${place.street}, ${place.locality}, ${place.country}";
    } else {
      _address = "Unknown Location";
    }
  });

  // Add the location details to the string
  details += "{}";
  details += "${_currentPosition.latitude?.toString() ?? "Unknown Latitude"}, "
      "${_currentPosition.longitude?.toString() ?? "Unknown Longitude"}";
  details += "{}";
  details += _address;

  return details;
}

// Function to get address using geocoding package
Future<List<Placemark>> _getAddress(double lat, double lng) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
 
