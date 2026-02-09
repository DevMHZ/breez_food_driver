import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_status_state.freezed.dart';

@freezed
class OrderStatusState with _$OrderStatusState {
  const factory OrderStatusState.idle() = _Idle;
  const factory OrderStatusState.loading({int? orderId}) = _Loading;

  const factory OrderStatusState.success({
    required int orderId,
    required String message,
  }) = _Success;

  const factory OrderStatusState.error({
    int? orderId,
    required String message,
  }) = _Error;
}
