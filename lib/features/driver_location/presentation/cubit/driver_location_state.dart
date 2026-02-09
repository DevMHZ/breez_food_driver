import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:breez_food_driver/features/driver_location/data/repo/driver_location_repo.dart';

part 'driver_location_state.freezed.dart';

@freezed
class DriverLocationState with _$DriverLocationState {
  const factory DriverLocationState.idle({
    @Default(false) bool running,
    String? message,
  }) = _Idle;

  const factory DriverLocationState.sending() = _Sending;
  const factory DriverLocationState.error(String message) = _Error;
}
