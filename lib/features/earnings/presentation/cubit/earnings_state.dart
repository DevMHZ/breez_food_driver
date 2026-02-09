import 'package:breez_food_driver/features/earnings/data/models/earnings_models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'earnings_state.freezed.dart';

@freezed
class EarningsState with _$EarningsState {
  const factory EarningsState.idle() = _Idle;
  const factory EarningsState.loading() = _Loading;
  const factory EarningsState.success(EarningsResponse model) = _Success;
  const factory EarningsState.error(String message) = _Error;
}
