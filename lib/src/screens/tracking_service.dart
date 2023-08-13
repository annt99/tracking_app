import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tracking_app/db/tracking_dao.dart';
import 'package:tracking_app/model/tracking_location_model.dart';
import 'package:background_location/background_location.dart' as BgLocation;
import 'package:tracking_app/src/utils/utils.dart';

class TrackingService {
  static final TrackingService _instance = TrackingService._();
  static TrackingService get instance => _instance;

  TrackingService._(); // Private constructor for singleton

  bool _isTracking = false;

  Set<TrackingLocation> locations = {};
  final TrackingDao _trackingDao = TrackingDao();

  bool get isTracking => _isTracking;

  Future<void> getAllLocation(Function? callBack) async {
    final _locations = await _trackingDao.getAllTrackingLocations();
    locations.addAll(_locations);
    if (callBack != null) {
      callBack();
    }
  }

  start(Function? callBack) async {
    _isTracking = true;
    await BgLocation.BackgroundLocation.setAndroidNotification(
      title: 'Background service is running',
      message: 'Background location in progress',
      icon: '@mipmap/ic_launcher',
    );
    await BgLocation.BackgroundLocation.startLocationService();
    BgLocation.BackgroundLocation.getLocationUpdates((location) async {
      print('test location');
      addLocation(location.latitude ?? 0, location.longitude ?? 0, null);
      if (callBack != null) {
        callBack();
      }
    });
  }

  stop() async {
    _isTracking = false;
    await BgLocation.BackgroundLocation.stopLocationService();
  }

  Future<void> addLocation(double lat, double lng, Function? callBack) async {
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
    }
    if (callBack != null) {
      callBack();
    }
  }
}
