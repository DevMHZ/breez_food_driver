import 'package:dio/dio.dart';
import 'package:breez_food_driver/core/network/api_result.dart';
import '../../../orders/data/api/offers_api_service.dart';

class OffersRepository {
  final OffersApiService api;
  OffersRepository(this.api);

  Future<AppResponse> current() async {
    try {
      final res = await api.current();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل العرض الحالي");
    }
  }

  Future<AppResponse> ack(String orderId) async {
    try {
      final res = await api.ack(orderId);
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل ACK");
    }
  }

  Future<AppResponse> accept(String orderId) async {
    try {
      final res = await api.accept(orderId);
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل قبول الطلب");
    }
  }

  Future<AppResponse> decline(String orderId) async {
    try {
      final res = await api.decline(orderId);
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل رفض الطلب");
    }
  }
}
