import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'orders_api_service.g.dart';

@RestApi()
abstract class OrdersApiService {
  factory OrdersApiService(Dio dio, {String? baseUrl}) = _OrdersApiService;

  @POST("/order/changetoinway")
  Future<HttpResponse<dynamic>> changeToInWay(@Body() Map<String, dynamic> body);

  @POST("/order/changetodelivered")
  Future<HttpResponse<dynamic>> changeToDelivered(@Body() Map<String, dynamic> body);

  @POST("/driver/send-order-to-kitchen")
  Future<HttpResponse<dynamic>> sendOrderToKitchen(@Body() Map<String, dynamic> body);

  @POST("/driver/order-details-to-driver")
  Future<HttpResponse<dynamic>> orderDetailsToDriver(@Body() Map<String, dynamic> body);

  @POST("/driver/emergency")
  Future<HttpResponse<dynamic>> emergency(@Body() Map<String, dynamic> body);
}
