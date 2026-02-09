import 'package:breez_food_driver/core/network/api_result.dart';
import 'package:breez_food_driver/features/driver_status/data/api/driver_status_api_service.dart';
import 'package:dio/dio.dart';


class DriverStatusRepository {
  final DriverStatusApiService api;
  DriverStatusRepository(this.api);

  Future<AppResponse> changeStatus() async {
    try {
      final res = await api.changeStatus(); // GET /driver/changeStatus
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تغيير الحالة");
    }
  }
}
