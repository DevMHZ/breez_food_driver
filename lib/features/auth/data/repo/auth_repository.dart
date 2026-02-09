import 'package:breez_food_driver/core/network/api_result.dart';
import 'package:breez_food_driver/core/network/dio_factory.dart';
import 'package:breez_food_driver/core/services/shared_perfrences_key.dart';
import 'package:breez_food_driver/features/auth/data/api/auth_api_service.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final AuthApiService api;
  AuthRepository(this.api);

  Future<AppResponse> login({
    required String email,
    required String password,
    String? token, // ✅ FCM token
  }) async {
    try {
      final body = <String, dynamic>{
        "email": email.trim(),
        "password": password,
        // ✅ ابعت التوكن فقط إذا موجود ومش فاضي
        if (token != null && token.trim().isNotEmpty) "token": token.trim(),
      };

      final res = await api.login(body);

      final data = res.data;

      final authToken = (data is Map) ? data["token"]?.toString() : null;
      final user = (data is Map)
          ? (data["user"] as Map?)?.cast<String, dynamic>()
          : null;

      if (authToken == null || authToken.isEmpty) {
        return AppResponse.fail(message: "لم يتم استلام رمز الدخول (token)");
      }

      await AuthStorageHelper.saveToken(authToken);
      DioFactory.setToken(authToken);

      final userIdRaw = user?["id"];
      final int? userId = (userIdRaw is int)
          ? userIdRaw
          : int.tryParse(userIdRaw?.toString() ?? "");

      if (userId != null) {
        await AuthStorageHelper.saveUserId(userId);
      } else {
        // ignore: avoid_print
        print("⚠️ user_id is null (not saved)");
      }

      final role = user?["type"]?.toString();
      if (role != null && role.isNotEmpty) {
        await AuthStorageHelper.saveUserRole(role);
      }

      final lat = user?["latitude"]?.toString();
      final lon = user?["longitude"]?.toString();
      if (lat != null && lat.isNotEmpty && lon != null && lon.isNotEmpty) {
        await AuthStorageHelper.saveUserLocation(lat: lat, lon: lon);
      }

      await AuthStorageHelper.clearGuestMode();

      return AppResponse.ok(
        message:
            (data is Map ? data["message"] : null)?.toString() ??
            "تم تسجيل الدخول",
        data: data,
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (e) {
      return AppResponse.fail(message: "فشل تسجيل الدخول: $e");
    }
  }

  Future<AppResponse> logout() async {
    try {
      final res = await api.logout();

      await AuthStorageHelper.removeToken();
      await AuthStorageHelper.removeUserRole();
      await AuthStorageHelper.removeUserLocation();
      await AuthStorageHelper.clearGuestMode();
      await AuthStorageHelper.removeUserId();

      DioFactory.clearToken();

      return AppResponse.ok(
        message: (res.data is Map)
            ? (res.data["message"]?.toString() ?? "Logged out successfully")
            : "Logged out successfully",
        data: res.data,
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (e) {
      return AppResponse.fail(message: "فشل تسجيل الخروج: $e");
    }
  }
}
