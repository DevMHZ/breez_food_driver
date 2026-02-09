import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeMapView extends StatelessWidget {
  final CameraPosition initialCameraPosition;
  final ValueChanged<GoogleMapController> onMapCreated;

  final Set<Marker> markers;
  final EdgeInsets padding;
  final VoidCallback? onUserPan;

  const HomeMapView({
    super.key,
    required this.initialCameraPosition,
    required this.onMapCreated,
    this.markers = const {},
    this.padding = EdgeInsets.zero,
    this.onUserPan,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: initialCameraPosition,
      onMapCreated: onMapCreated,

      myLocationEnabled: false,
      myLocationButtonEnabled: false,

      zoomControlsEnabled: false,
      mapToolbarEnabled: false,

      buildingsEnabled: false,
      indoorViewEnabled: false,
      trafficEnabled: true,

      padding: padding,
      markers: markers,

      onCameraMoveStarted: () => onUserPan?.call(),
    );
  }
}
