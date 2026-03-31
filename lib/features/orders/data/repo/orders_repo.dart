import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:breez_food_driver/core/network/api_result.dart';
import '../api/orders_api_service.dart';

class OrdersRepository {
  final OrdersApiService api;
  OrdersRepository(this.api);

  AppResponse _mapSuccess(HttpResponse<dynamic> res, {String? fallbackMessage}) {
    final raw = res.data;

    if (raw is Map<String, dynamic>) {
      return AppResponse.ok(
        data: raw['data'] ?? raw,
        message: (raw['message'] ?? fallbackMessage)?.toString(),
      );
    }

    return AppResponse.ok(
      data: raw,
      message: fallbackMessage,
    );
  }

  Future<AppResponse> sendOrderToKitchen(int orderId) async {
    try {
      final res = await api.sendOrderToKitchen({"order_id": orderId});
      return _mapSuccess(
        res,
        fallbackMessage: "تم إرسال الطلب إلى المطبخ",
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل إرسال الطلب للمطبخ");
    }
  }

  Future<AppResponse> changeToInWay(int orderId) async {
    try {
      final res = await api.changeToInWay({"order_id": orderId});
      return _mapSuccess(
        res,
        fallbackMessage: "تم تغيير الحالة إلى بالطريق",
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تغيير الحالة إلى InWay");
    }
  }

  Future<AppResponse> orderDetailsToDriver(int orderId) async {
    try {
      final res = await api.orderDetailsToDriver({"id": orderId});
      return _mapSuccess(res);
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
      return _mapSuccess(
        res,
        fallbackMessage: "تم تغيير الحالة إلى تم التسليم",
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تغيير الحالة إلى Delivered");
    }
  }

  Future<AppResponse> emergency({
    required int orderId,
    required String reason,
  }) async {
    try {
      final res = await api.emergency({
        "order_id": orderId,
        "reason": reason,
      });
      return _mapSuccess(
        res,
        fallbackMessage: "تم إرسال البلاغ",
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "common.unexpected_error");
    }
  }
}