import 'package:breez_food_driver/features/orders/data/models/orders_models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_order_details_state.freezed.dart';

@freezed
class DriverOrderDetailsState with _$DriverOrderDetailsState {
  const factory DriverOrderDetailsState.idle() = _Idle;
  const factory DriverOrderDetailsState.loading() = _Loading;
  const factory DriverOrderDetailsState.success(DriverOrderDetails details) = _Success;
  const factory DriverOrderDetailsState.error(String messageKey) = _Error;
}
