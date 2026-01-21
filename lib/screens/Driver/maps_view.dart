import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class MapsViewState {
  // permission and psition
  Future<void> openGoogleMaps() async {
    try {
      final LocationPermission hasPermission =
          await Geolocator.checkPermission();
      if (hasPermission == LocationPermission.denied ||
          hasPermission == LocationPermission.deniedForever) {
        final permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Fluttertoast.showToast(msg: 'Cant Proceed without permission');
          return;
        }
      
        return;
      }
      //position
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
      );
      final latitude = position.latitude;
      final longitude = position.longitude;
      final Uri googleMapsUri = Uri.parse(
        'geo:$latitude,$longitude?q=$latitude,$longitude(Current+Location)',
      );

      final canLaunch = await canLaunchUrl(googleMapsUri);
      if (canLaunch == true) {
        Fluttertoast.showToast(msg: 'Opening Google Maps');
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      }
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
    }
  }
}
