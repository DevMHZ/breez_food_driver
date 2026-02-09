import 'package:freezed_annotation/freezed_annotation.dart';

part 'offers_state.freezed.dart';

@freezed
class OfferState with _$OfferState {
  const factory OfferState.idle() = _Idle;

  const factory OfferState.received({
    required Map<String, dynamic> offer,
  }) = _Received;

  const factory OfferState.actionLoading({
    required Map<String, dynamic> offer,
  }) = _ActionLoading;

  const factory OfferState.accepted({
    required Map<String, dynamic> offer,
  }) = _Accepted;

  const factory OfferState.error({
    required String message,
    Map<String, dynamic>? offer,
  }) = _Error;
}
