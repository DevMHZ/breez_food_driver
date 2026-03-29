import 'package:breez_food_driver/features/earnings/data/models/earnings_models.dart';

class EarningsFinancialDetailsState {
  final bool isLoading;
  final String errorMessage;
  final EarningsFinancialDetailsData? data;

  const EarningsFinancialDetailsState({
    required this.isLoading,
    required this.errorMessage,
    required this.data,
  });

  const EarningsFinancialDetailsState.initial()
      : isLoading = false,
        errorMessage = '',
        data = null;

  EarningsFinancialDetailsState copyWith({
    bool? isLoading,
    String? errorMessage,
    EarningsFinancialDetailsData? data,
    bool clearError = false,
  }) {
    return EarningsFinancialDetailsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
      data: data ?? this.data,
    );
  }
}
