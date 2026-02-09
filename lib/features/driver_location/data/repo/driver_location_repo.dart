import 'package:dio/dio.dart';
import 'package:breez_food_driver/core/network/api_result.dart';
import 'package:breez_food_driver/features/driver_location/data/api/driver_location_api_service.dart';

class DriverLocationRepository {
  final DriverLocationApiService api;
  DriverLocationRepository(this.api);

  Future<AppResponse> sendLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final res = await api.sendLocation({
        "latitude": latitude,
        "longitude": longitude,
      });

      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل إرسال الموقع");
    }
  }
}
