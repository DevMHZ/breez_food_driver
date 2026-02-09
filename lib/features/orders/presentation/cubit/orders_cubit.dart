import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:breez_food_driver/features/orders/data/repo/orders_repo.dart';
import 'order_status_state.dart';

class OrderStatusCubit extends Cubit<OrderStatusState> {
  final OrdersRepository repo;
  OrderStatusCubit(this.repo) : super(const OrderStatusState.idle());

  Future<bool> sendOrderToKitchen(int orderId) async {
    emit(OrderStatusState.loading(orderId: orderId));

    final res = await repo.sendOrderToKitchen(orderId);

    if (!res.ok) {
      emit(
        OrderStatusState.error(
          orderId: orderId,
          message: res.message ?? "errors.operation_failed",
        ),
      );
      return false;
    }

    emit(
      OrderStatusState.success(
        orderId: orderId,
        message: "tracking.sent_to_kitchen",
      ),
    );
    return true;
  }

  Future<bool> changeToInWay(int orderId) async {
    emit(OrderStatusState.loading(orderId: orderId));

    final res = await repo.changeToInWay(orderId);

    if (!res.ok) {
      emit(
        OrderStatusState.error(
          orderId: orderId,
          message: res.message ?? "errors.operation_failed",
        ),
      );
      return false;
    }

    emit(
      OrderStatusState.success(
        orderId: orderId,
        message: "tracking.changed_to_inway",
      ),
    );
    return true;
  }

  Future<bool> changeToDelivered({
    required int orderId,
    required String code,
  }) async {
    emit(OrderStatusState.loading(orderId: orderId));

    final res = await repo.changeToDelivered(orderId: orderId, code: code);

    if (!res.ok) {
      emit(
        OrderStatusState.error(
          orderId: orderId,
          message: res.message ?? "errors.operation_failed",
        ),
      );
      return false;
    }

    emit(
      OrderStatusState.success(
        orderId: orderId,
        message: "tracking.delivered_success",
      ),
    );
    return true;
  }

  Future<bool> sendEmergency({
    required int orderId,
    required String reason,
  }) async {
    emit(OrderStatusState.loading(orderId: orderId));

    final res = await repo.emergency(orderId: orderId, reason: reason);

    if (!res.ok) {
      emit(
        OrderStatusState.error(
          orderId: orderId,
          message: res.message ?? "errors.emergency_failed",
        ),
      );
      return false;
    }

    emit(
      OrderStatusState.success(
        orderId: orderId,
        message: "tracking.emergency_sent",
      ),
    );
    return true;
  }

  void reset() => emit(const OrderStatusState.idle());
}
