import 'package:breez_food_driver/features/orders/data/models/orders_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'driver_order_details_state.dart';
import '../../data/repo/orders_repo.dart';

class DriverOrderDetailsCubit extends Cubit<DriverOrderDetailsState> {
  final OrdersRepository repo;
  DriverOrderDetailsCubit(this.repo)
    : super(const DriverOrderDetailsState.idle());

  Future<void> load(int orderId) async {
    emit(const DriverOrderDetailsState.loading());
    final res = await repo.orderDetailsToDriver(orderId);

    if (!res.isOk) {
      emit(DriverOrderDetailsState.error(res.message ?? "common.failed"));
      return;
    }

    final data = (res.data as Map?)?.cast<String, dynamic>() ?? {};
    emit(DriverOrderDetailsState.success(DriverOrderDetails.fromJson(data)));
  }
}
