import 'package:dio/dio.dart';
import 'package:breez_food_driver/core/network/api_result.dart';
import '../api/orders_api_service.dart';

class OrdersRepository {
  final OrdersApiService api;
  OrdersRepository(this.api);

  Future<AppResponse> sendOrderToKitchen(int orderId) async {
    try {
      final res = await api.sendOrderToKitchen({"order_id": orderId});
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل إرسال الطلب للمطبخ");
    }
  }

  Future<AppResponse> changeToInWay(int orderId) async {
    try {
      final res = await api.changeToInWay({"order_id": orderId});
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تغيير الحالة إلى InWay");
    }
  }

  Future<AppResponse> orderDetailsToDriver(int orderId) async {
    try {
      final res = await api.orderDetailsToDriver({"id": orderId});
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "common.unexpected_error");
    }
  }

  Future<AppResponse> changeToDelivered({
    required int orderId,
    required String code,
  }) async {
    try {
      final res = await api.changeToDelivered({
        "order_id": orderId,
        "code": code,
      });
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تغيير الحالة إلى Delivered");
    }
  }

  // ✅ NEW
  Future<AppResponse> emergency({
    required int orderId,
    required String reason,
  }) async {
    try {
      final res = await api.emergency({
        "order_id": orderId,
        "reason": reason,
      });
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "common.unexpected_error");
    }
  }
}
