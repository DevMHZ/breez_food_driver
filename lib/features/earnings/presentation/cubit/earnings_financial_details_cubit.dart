import 'package:breez_food_driver/features/earnings/data/models/earnings_models.dart';
import 'package:breez_food_driver/features/earnings/data/repo/earnings_repo.dart';
import 'package:breez_food_driver/features/earnings/presentation/cubit/earnings_financial_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EarningsFinancialDetailsCubit
    extends Cubit<EarningsFinancialDetailsState> {
  final EarningsRepository repo;

  int _requestId = 0;

  EarningsFinancialDetailsCubit(this.repo)
      : super(const EarningsFinancialDetailsState.initial());

  Future<void> load({String? date}) async {
    final currentRequestId = ++_requestId;

    emit(state.copyWith(
      isLoading: true,
      clearError: true,
    ));

    final res = await repo.getFinancialDetails(date: date);

    if (currentRequestId != _requestId) return;

    if (!res.ok || res.data is! EarningsFinancialDetailsResponse) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: res.message ?? 'فشل جلب التفاصيل المالية',
      ));
      return;
    }

    final model = res.data as EarningsFinancialDetailsResponse;

    emit(state.copyWith(
      isLoading: false,
      clearError: true,
      data: model.data,
    ));
  }
}
