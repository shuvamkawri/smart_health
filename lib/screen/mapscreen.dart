import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final double initialLat;
  final double initialLng;

  // Constructor with named parameters
  MapScreen({required this.initialLat, required this.initialLng});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Screen'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(initialLat, initialLng),
          zoom: 13.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('marker_1'),
            position: LatLng(initialLat, initialLng),
            icon: BitmapDescriptor.defaultMarker,
          ),
        },
        onTap: (LatLng latLng) {
          // Handle map tap events if needed
        },
        onMapCreated: (GoogleMapController controller) {
          // No need to add the dummy street map overlay anymore
        },
      ),
    );
  }
}
