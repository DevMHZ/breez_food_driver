import 'dart:async';

import 'package:breez_food_driver/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:breez_food_driver/core/di/di.dart';

import 'home_bottom_bar.dart';
import 'home_map_view.dart';

class HomeBodyStack extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Completer<GoogleMapController> mapController;
  final CameraPosition initialCameraPosition;
  final VoidCallback onTestSound;

  final Set<Marker> markers;
  final VoidCallback onRecenter;
  final VoidCallback onUserPan;
  final bool followMe;

  final bool isOnline;
  final bool hasOffer;

  final bool isChangingStatus;
  final VoidCallback onToggleOnline;
  final bool isConnected; // الانترنت موجود؟
  final bool isSearching; // pusher connected؟

  final void Function(GoogleMapController controller)? onMapCreated;

  const HomeBodyStack({
    super.key,
    required this.scaffoldKey,
    required this.mapController,
    required this.initialCameraPosition,
    required this.markers,
    required this.onRecenter,
    required this.onUserPan,
    required this.followMe,
    required this.isOnline,
    required this.hasOffer,
    required this.isChangingStatus,
    required this.onToggleOnline,
    required this.onTestSound,
    required this.isConnected, // ✅ جديد
    required this.isSearching, // ✅ جديد
    this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => getIt<ProfileCubit>()..load(),
      child: Stack(
        children: [
          Positioned.fill(
            child: HomeMapView(
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (controller) {
                if (!mapController.isCompleted) {
                  mapController.complete(controller);
                }
                onMapCreated?.call(controller);
              },
              markers: markers,
              padding: const EdgeInsets.only(bottom: 110),
              onUserPan: onUserPan,
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: HomeBottomBar(
              isOnline: isOnline,
              hasOffer: hasOffer,
              isBusy: isChangingStatus,
              onToggle: onToggleOnline,
              onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
              isConnected: isConnected,
              isSearching: isSearching,
            ),
          ),
        ],
      ),
    );
  }
}
