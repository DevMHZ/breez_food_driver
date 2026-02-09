import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingMap extends StatelessWidget {
  final Completer<GoogleMapController> controller;
  final CameraPosition initial;
  final Set<Marker> markers;
  final Future<void> Function() onCreated;

  const TrackingMap({
    super.key,
    required this.controller,
    required this.initial,
    required this.markers,
    required this.onCreated,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      initialCameraPosition: initial,
      markers: markers,
      onMapCreated: (c) async {
        if (!controller.isCompleted) controller.complete(c);
        await onCreated();
      },
    );
  }
}
