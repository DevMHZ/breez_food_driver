import 'package:breez_food_driver/features/terms/data/api/terms_api_service.dart';
import 'package:dio/dio.dart';
import 'package:breez_food_driver/core/network/api_result.dart';
import 'package:breez_food_driver/core/network/api_result.dart'
    show AppResponseHandler;
import 'package:breez_food_driver/features/terms/data/api/terms_api_service.dart';

class TermsRepository {
  final TermsApiService api;
  TermsRepository(this.api);

  Future<AppResponse> getTerms() async {
    try {
      final res = await api.getTerms();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل الشروط والأحكام");
    }
  }
}
