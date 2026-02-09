import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'earnings_api_service.g.dart';

@RestApi()
abstract class EarningsApiService {
  factory EarningsApiService(Dio dio, {String? baseUrl}) = _EarningsApiService;

  @GET('/driver/earnings')
  Future<HttpResponse<dynamic>> getEarnings(
    @Query('date') String? date,  
  );
}
