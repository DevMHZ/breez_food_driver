import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'driver_location_api_service.g.dart';

@RestApi()
abstract class DriverLocationApiService {
  factory DriverLocationApiService(Dio dio, {String? baseUrl}) =
      _DriverLocationApiService;

  @POST('/driver/location')
  Future<HttpResponse<dynamic>> sendLocation(
    @Body() Map<String, dynamic> body,
  );
}
