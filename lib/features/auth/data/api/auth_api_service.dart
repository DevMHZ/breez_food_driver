import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String? baseUrl}) = _AuthApiService;

  @POST("/driver/login")
  Future<HttpResponse<dynamic>> login(@Body() Map<String, dynamic> body);

  @POST("/logout")
  Future<HttpResponse<dynamic>> logout();
}
