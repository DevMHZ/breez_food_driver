import 'package:breez_food_driver/features/earnings/data/models/earnings_models.dart';
import 'package:dio/dio.dart';
import 'package:breez_food_driver/core/network/api_result.dart';
import 'package:breez_food_driver/features/earnings/data/api/earnings_api_service.dart';

class EarningsRepository {
  final EarningsApiService api;
  EarningsRepository(this.api);

  Future<AppResponse> getEarnings({String? date}) async {
    try {
      final res = await api.getEarnings(date);

      final model = EarningsResponse.fromJson(
        (res.data as Map).cast<String, dynamic>(),
      );

      return AppResponse.ok(data: model);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل جلب الأرباح");
    }
  }
}
