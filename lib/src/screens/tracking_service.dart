import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tracking_app/db/tracking_dao.dart';
import 'package:tracking_app/model/tracking_location_model.dart';
import 'package:background_location/background_location.dart' as BgLocation;
import 'package:tracking_app/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackingService extends ChangeNotifier {
  static final TrackingService _instance = TrackingService._();
  static TrackingService get instance => _instance;

  TrackingService._(); // Private constructor for singleton

  bool _isTracking = false;

  final StreamController<Set<TrackingLocation>> _locationsController =
      StreamController<Set<TrackingLocation>>.broadcast();

  Stream<Set<TrackingLocation>> get locationStream =>
      _locationsController.stream;

  Set<TrackingLocation> locations = {};

  final TrackingDao _trackingDao = TrackingDao();

  bool get isTracking => _isTracking;

  Future<void> getAllLocation() async {
    final _locations = await _trackingDao.getAllTrackingLocations();
    locations.addAll(_locations);
    _locationsController.add(locations);
  }

  start() async {
    _isTracking = true;
    await saveTrackingState(_isTracking);
    await BgLocation.BackgroundLocation.setAndroidNotification(
      title: 'Background service is running',
      message: 'Background location in progress',
      icon: '@mipmap/ic_launcher',
    );
    await BgLocation.BackgroundLocation.startLocationService();
    BgLocation.BackgroundLocation.getLocationUpdates((location) async {
      print('test location');
      addLocation(location.latitude ?? 0, location.longitude ?? 0);
    });
  }

  stop() async {
    _isTracking = false;
    await saveTrackingState(_isTracking);
    await BgLocation.BackgroundLocation.stopLocationService();
  }

  Future<void> maskLocation(double lat, double lng) async {
    print('test mask location');
    final String address = await Utils.getAddressFromPosition(lat, lng);
    final time = DateTime.now().millisecondsSinceEpoch;
    final trackingLocation = TrackingLocation(
        id: time,
        lat: lat,
        lng: lng,
        address: address,
        group: Utils.getDate(time));
    locations.add(trackingLocation);
    await _trackingDao.saveLocation(trackingLocation);
    _locationsController.add(locations);
  }

  Future<void> addLocation(double lat, double lng) async {
    double minDistanceThreshold = 100.0;

    if (locations.isNotEmpty) {
      if (lat != locations.last.lat && lng != locations.last.lng) {
        double distance = Geolocator.distanceBetween(
            locations.last.lat, locations.last.lng, lat, lng);
        print('test distance : $distance');

        if (distance > minDistanceThreshold) {
          final String address = await Utils.getAddressFromPosition(lat, lng);
          final time = DateTime.now().millisecondsSinceEpoch;
          final trackingLocation = TrackingLocation(
              id: time,
              lat: lat,
              lng: lng,
              address: address,
              group: Utils.getDate(time));
          if (!locations.contains(trackingLocation)) {
            locations.add(trackingLocation);
            await _trackingDao.saveLocation(trackingLocation);
            _locationsController.add(locations);
          }
        }
      }
    } else {
      print('test distance 1');
      final String address = await Utils.getAddressFromPosition(lat, lng);
      final time = DateTime.now().millisecondsSinceEpoch;
      final trackingLocation = TrackingLocation(
          id: time,
          lat: lat,
          lng: lng,
          address: address,
          group: Utils.getDate(time));
      locations.add(trackingLocation);
      await _trackingDao.saveLocation(trackingLocation);
      _locationsController.add(locations);
    }
  }

  Future<void> saveTrackingState(bool isTracking) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isTracking', isTracking);
  }

  Future<bool> getTrackingState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getBool('isTracking') ?? false;
    if (result) {
      start();
    } else {
      stop();
    }
    return result;
  }
}
