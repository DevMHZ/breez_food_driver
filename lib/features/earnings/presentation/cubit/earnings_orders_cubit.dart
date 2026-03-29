import 'package:breez_food_driver/features/earnings/data/models/earnings_models.dart';
import 'package:breez_food_driver/features/earnings/data/repo/earnings_repo.dart';
import 'package:breez_food_driver/features/earnings/presentation/cubit/earnings_orders_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EarningsOrdersCubit extends Cubit<EarningsOrdersState> {
  final EarningsRepository repo;

  int _requestId = 0;

  EarningsOrdersCubit(this.repo) : super(const EarningsOrdersState.initial());

  Future<void> load({String? date}) async {
    final currentRequestId = ++_requestId;

    emit(state.copyWith(
      isLoading: true,
      clearError: true,
    ));

    final res = await repo.getOrders(date: date);

    if (currentRequestId != _requestId) return;

    if (!res.ok || res.data is! EarningsOrdersResponse) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: res.message ?? 'فشل جلب أرباح الطلبات',
      ));
      return;
    }

    final model = res.data as EarningsOrdersResponse;

    emit(state.copyWith(
      isLoading: false,
      clearError: true,
      data: model.data,
    ));
  }

  void changeFilter(EarningsOrdersFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  List<EarningsOrderItem> get filteredOrders {
    final allOrders = state.data?.orders ?? const <EarningsOrderItem>[];

    switch (state.filter) {
      case EarningsOrdersFilter.all:
        return allOrders;
      case EarningsOrdersFilter.regular:
        return allOrders.where((order) => !order.isVip).toList();
      case EarningsOrdersFilter.vip:
        return allOrders.where((order) => order.isVip).toList();
    }
  }
}
