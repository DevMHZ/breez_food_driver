import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'offers_api_service.g.dart';

@RestApi()
abstract class OffersApiService {
  factory OffersApiService(Dio dio, {String? baseUrl}) = _OffersApiService;

  @GET('/offers/current')
  Future<HttpResponse<dynamic>> current();

@POST('/offers/{orderId}/ack')
Future<HttpResponse<dynamic>> ack(@Path('orderId') String orderId);

@POST('/offers/{orderId}/accept')
Future<HttpResponse<dynamic>> accept(@Path('orderId') String orderId);

@POST('/offers/{orderId}/decline')
Future<HttpResponse<dynamic>> decline(@Path('orderId') String orderId);

}
