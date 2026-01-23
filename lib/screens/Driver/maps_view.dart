import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsView extends StatefulWidget {
  final double lat, lng;

  const MapsView({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  State<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {
  final LatLng destination = const LatLng(-0.4218363, 36.9518867);

  late GoogleMapController mapController;
  late LatLng currentPosition;

  Marker? movingMarker;
  StreamSubscription<Position>? positionStream;

  String travelTimeText = '';

  @override
  void initState() {
    super.initState();

    // Initial position from previous screen
    currentPosition = LatLng(widget.lat, widget.lng);

    // Initial ETA calculation
    travelTimeText = estimateTravelTime(currentPosition, destination);

    // Listen to location updates
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // meters
      ),
    ).listen((Position position) {
      final newPos = LatLng(position.latitude, position.longitude);

      setState(() {
        currentPosition = newPos;
        travelTimeText = estimateTravelTime(currentPosition, destination);
        movingMarker = Marker(
          markerId: const MarkerId('moving_marker'),
          position: newPos,
          infoWindow: const InfoWindow(title: 'You are here'),
        );
      });

      mapController.animateCamera(
        CameraUpdate.newLatLng(newPos),
      );
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  // -----------------------------
  // ETA CALCULATION (NO API)
  // -----------------------------

  double calculateDistanceKm(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    ) /
        1000; // meters → km
  }

  String estimateTravelTime(LatLng start, LatLng end) {
    final distanceKm = calculateDistanceKm(start, end);

    const double averageSpeedKmH = 35; // city driving
    final timeHours = distanceKm / averageSpeedKmH;
    final timeMinutes = (timeHours * 60).round();

    if (timeMinutes <= 0) return 'Less than 1 min';
    return '$timeMinutes mins';
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    setState(() {
      movingMarker = Marker(
        markerId: const MarkerId('moving_marker'),
        position: currentPosition,
        infoWindow: const InfoWindow(title: 'You are here'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maps View')),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: currentPosition,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('destination'),
                  position: destination,
                  infoWindow: const InfoWindow(title: 'Destination'),
                ),
                if (movingMarker != null) movingMarker!,
              },
            ),

            // ETA overlay
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Estimated time to destination: $travelTimeText',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
