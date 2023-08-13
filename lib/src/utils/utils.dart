import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';

class Utils {
  static String getDate(int timeStamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    final f = DateFormat('yyyy-MM-dd hh:mm');
    return f.format(dateTime);
  }

  static Future<String> getAddressFromPosition(double? lat, double? lng) async {
    if (lat == null || lng == null) {
      return 'Address not found';
    }
    final List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    var address = '';
    if (placemarks.isNotEmpty) {
      final Placemark placemark = placemarks[0];
      if (placemark.subThoroughfare != null &&
          placemark.subThoroughfare != '') {
        address = '$address${placemark.subThoroughfare}';
      }
      if (placemark.thoroughfare != null && placemark.thoroughfare != '') {
        address = '$address ${placemark.thoroughfare}, ';
      }
      if (placemark.subLocality != null && placemark.subLocality != '') {
        address = '$address${placemark.subLocality}, ';
      }
      if (placemark.locality != null && placemark.locality != '') {
        address = '$address${placemark.locality}';
      }
      if (placemark.administrativeArea != null &&
          placemark.administrativeArea != '') {
        address = '$address${placemark.administrativeArea}, ';
      }
      if (placemark.country != null && placemark.country != '') {
        address = '$address${placemark.country}';
      }
    } else {
      address = 'Address not found';
    }
    return address;
  }

  static void launchGoogleMaps(
      double latitude, double longitude, String label) async {
    await MapsLauncher.launchCoordinates(latitude, longitude, label);
  }
}
