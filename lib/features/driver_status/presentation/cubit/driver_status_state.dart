import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_status_state.freezed.dart';

@freezed
class DriverStatusState with _$DriverStatusState {
  const factory DriverStatusState.initial() = _Initial;
  const factory DriverStatusState.loading() = _Loading;
  const factory DriverStatusState.error(String message) = _Error;
  const factory DriverStatusState.success({
    required bool isOnline,
    String? message,
  }) = _Success;
}
