import 'package:breez_food_driver/features/driver_status/presentation/cubit/driver_status_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:breez_food_driver/features/driver_status/data/repo/driver_status_repo.dart';
class DriverStatusCubit extends Cubit<DriverStatusState> {
  final DriverStatusRepository repo;
  DriverStatusCubit(this.repo) : super(const DriverStatusState.initial());

  Future<bool?> toggle() async {
    emit(const DriverStatusState.loading());

    final res = await repo.changeStatus();
    if (!res.ok) {
      emit(DriverStatusState.error(res.message ?? "خطأ"));
      return null;
    }

    final data = res.data;
    final bool isOnline = (data is Map) ? (data["is_online"] == true) : false;

    emit(DriverStatusState.success(isOnline: isOnline, message: "Status updated"));
    return isOnline;
  }

  Future<bool?> setOnline(bool desired, {required bool current}) async {
    if (current == desired) {
      emit(DriverStatusState.success(isOnline: current));
      return current;
    }
    return toggle();
  }
}
