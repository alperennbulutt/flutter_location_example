import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationsWorker {
  final Function(LocationData locationData) callback;
  Location location = Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionStatus;
  LocationData? locationData;
  final BuildContext context;
  LocationsWorker({Key? key, required this.callback, required this.context});

  Future<bool> _handleLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();

    if (!_serviceEnabled!) {
      debugPrint("");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    _permissionStatus = await location.hasPermission();
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await location.requestPermission();
      if (_permissionStatus == PermissionStatus.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (_permissionStatus == PermissionStatus.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, open the settings & enable location permissions to use this feature.')));
      return false;
    }
    return true;
  }

  getCurrentPosition() async {
    print("fetching location...");
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await location.getLocation().then((LocationData mLocationData) {
      locationData = mLocationData;
      callback(mLocationData);
      print("location fetched !!!");
      //_getAddressFromLatLng(_locationData);
    }).catchError((e) {
      print("SomeErrorCameUp : $e");
    });
  }

  initLocation() {
    getCurrentPosition();
  }
}
