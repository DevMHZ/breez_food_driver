import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'earnings_api_service.g.dart';

@RestApi()
abstract class EarningsApiService {
  factory EarningsApiService(Dio dio, {String? baseUrl}) = _EarningsApiService;

  @GET('/driver/earnings')
  Future<HttpResponse<dynamic>> getOverview(
    @Query('date') String? date,
  );

  @GET('/driver/earnings/orders')
  Future<HttpResponse<dynamic>> getOrders(
    @Query('date') String? date,
  );

  @GET('/driver/earnings/financial-details')
  Future<HttpResponse<dynamic>> getFinancialDetails(
    @Query('date') String? date,
  );
}
