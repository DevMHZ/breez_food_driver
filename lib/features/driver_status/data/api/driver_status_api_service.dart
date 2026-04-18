import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'driver_status_api_service.g.dart';

@RestApi()
abstract class DriverStatusApiService {
  factory DriverStatusApiService(Dio dio, {String? baseUrl}) =
      _DriverStatusApiService;

  @GET('/driver/changeStatus')
  Future<HttpResponse<dynamic>> changeStatus();
}
