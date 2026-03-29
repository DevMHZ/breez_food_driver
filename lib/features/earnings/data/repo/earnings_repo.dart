import 'package:breez_food_driver/core/network/api_result.dart';
import 'package:breez_food_driver/features/earnings/data/api/earnings_api_service.dart';
import 'package:breez_food_driver/features/earnings/data/models/earnings_models.dart';
import 'package:dio/dio.dart';

class EarningsRepository {
  final EarningsApiService api;

  EarningsRepository(this.api);

  Future<AppResponse> getOverview({String? date}) async {
    try {
      final response = await api.getOverview(date);
      final model = EarningsOverviewResponse.fromJson(_safeMap(response.data));

      if (!model.status) {
        return AppResponse.fail(
          message: model.message.isNotEmpty
              ? model.message
              : 'فشل جلب ملخص المكاسب',
        );
      }

      return AppResponse.ok(
        data: model,
        message: model.message,
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: 'فشل جلب ملخص المكاسب');
    }
  }

  Future<AppResponse> getOrders({String? date}) async {
    try {
      final response = await api.getOrders(date);
      final model = EarningsOrdersResponse.fromJson(_safeMap(response.data));

      if (!model.status) {
        return AppResponse.fail(
          message: model.message.isNotEmpty
              ? model.message
              : 'فشل جلب أرباح الطلبات',
        );
      }

      return AppResponse.ok(
        data: model,
        message: model.message,
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: 'فشل جلب أرباح الطلبات');
    }
  }

  Future<AppResponse> getFinancialDetails({String? date}) async {
    try {
      final response = await api.getFinancialDetails(date);
      final model = EarningsFinancialDetailsResponse.fromJson(
        _safeMap(response.data),
      );

      if (!model.status) {
        return AppResponse.fail(
          message: model.message.isNotEmpty
              ? model.message
              : 'فشل جلب التفاصيل المالية',
        );
      }

      return AppResponse.ok(
        data: model,
        message: model.message,
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: 'فشل جلب التفاصيل المالية');
    }
  }
}

Map<String, dynamic> _safeMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return data.cast<String, dynamic>();
  return <String, dynamic>{};
}
