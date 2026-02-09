import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:breez_food_driver/features/earnings/data/repo/earnings_repo.dart';
import 'earnings_state.dart';

class EarningsCubit extends Cubit<EarningsState> {
  final EarningsRepository repo;
  EarningsCubit(this.repo) : super(const EarningsState.idle());

  Future<void> load({String? date}) async {
    emit(const EarningsState.loading());

    final res = await repo.getEarnings(date: date);

    if (!res.ok) {
      emit(EarningsState.error(res.message ?? "خطأ غير معروف"));
      return;
    }

    emit(EarningsState.success(res.data));
  }
}
