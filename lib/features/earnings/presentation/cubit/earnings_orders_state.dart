import 'package:breez_food_driver/features/earnings/data/models/earnings_models.dart';

enum EarningsOrdersFilter { all, regular, vip }

class EarningsOrdersState {
  final bool isLoading;
  final String errorMessage;
  final EarningsOrdersData? data;
  final EarningsOrdersFilter filter;

  const EarningsOrdersState({
    required this.isLoading,
    required this.errorMessage,
    required this.data,
    required this.filter,
  });

  const EarningsOrdersState.initial()
      : isLoading = false,
        errorMessage = '',
        data = null,
        filter = EarningsOrdersFilter.all;

  EarningsOrdersState copyWith({
    bool? isLoading,
    String? errorMessage,
    EarningsOrdersData? data,
    EarningsOrdersFilter? filter,
    bool clearError = false,
  }) {
    return EarningsOrdersState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
      data: data ?? this.data,
      filter: filter ?? this.filter,
    );
  }
}
