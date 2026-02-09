import 'package:breez_food_driver/core/network/dio_factory.dart';
import 'package:breez_food_driver/core/network/dio_factory.dart';
import 'package:breez_food_driver/features/driver_location/data/api/driver_location_api_service.dart';
import 'package:breez_food_driver/features/driver_location/data/repo/driver_location_repo.dart';
import 'package:breez_food_driver/features/driver_location/presentation/cubit/driver_location_cubit.dart';
import 'package:breez_food_driver/features/driver_status/data/api/driver_status_api_service.dart';
import 'package:breez_food_driver/features/driver_status/data/repo/driver_status_repo.dart';
import 'package:breez_food_driver/features/driver_status/presentation/cubit/driver_status_cubit.dart';
import 'package:breez_food_driver/features/help_center/data/api/help_center_api_service.dart';
import 'package:breez_food_driver/features/help_center/data/repo/help_center_repo.dart';
import 'package:breez_food_driver/features/help_center/presentation/cubit/help_center_cubit.dart';
import 'package:breez_food_driver/features/orders/data/repo/orders_repo.dart';
import 'package:breez_food_driver/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:breez_food_driver/features/profile/data/api/profile_api_service.dart';
import 'package:breez_food_driver/features/profile/data/repo/profile_repository.dart';
import 'package:breez_food_driver/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:breez_food_driver/features/terms/data/api/terms_api_service.dart';
import 'package:breez_food_driver/features/terms/data/repo/terms_repository.dart';
import 'package:breez_food_driver/features/terms/presentation/cubit/terms_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:breez_food_driver/features/auth/data/api/auth_api_service.dart';
import 'package:breez_food_driver/features/auth/data/repo/auth_repository.dart';
import 'package:breez_food_driver/features/auth/presentation/cubit/auth_flow_cubit.dart';
import 'package:breez_food_driver/features/orders/data/api/offers_api_service.dart';
import 'package:breez_food_driver/features/offers/data/repo/offers_repo.dart';
import 'package:breez_food_driver/features/offers/presentation/cubit/offers_cubit.dart';
import 'package:breez_food_driver/features/earnings/data/api/earnings_api_service.dart';
import 'package:breez_food_driver/features/earnings/data/repo/earnings_repo.dart';
import 'package:breez_food_driver/features/earnings/presentation/cubit/earnings_cubit.dart';

import 'package:breez_food_driver/features/orders/data/api/orders_api_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDi() async {
  await Hive.initFlutter();
  await Hive.openBox("settings");
  await Hive.openBox<String>("token");

  // =========================
  // Dio (Singleton واحد فقط)
  // =========================
  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(() => DioFactory.getDio());
  }

  // ✅ استعمل نفس الـ Dio المسجل بكل شيء
  final dio = getIt<Dio>();

  // =========================
  // Auth
  // =========================
  if (!getIt.isRegistered<AuthApiService>()) {
    getIt.registerLazySingleton<AuthApiService>(() => AuthApiService(dio));
  }
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepository(getIt<AuthApiService>()),
    );
  }
  if (!getIt.isRegistered<AuthFlowCubit>()) {
    getIt.registerFactory<AuthFlowCubit>(
      () => AuthFlowCubit(getIt<AuthRepository>()),
    );
  }

  // =========================
  // Terms / DriverStatus / Profile ...
  // (خلي تسجيلاتك مثل ما هي بس تأكد تستخدم getIt<Dio>())
  // =========================

  if (!getIt.isRegistered<TermsApiService>()) {
    getIt.registerLazySingleton<TermsApiService>(() => TermsApiService(dio));
  }

  if (!getIt.isRegistered<DriverStatusApiService>()) {
    getIt.registerLazySingleton<DriverStatusApiService>(
      () => DriverStatusApiService(dio),
    );
  }

  if (!getIt.isRegistered<ProfileApiService>()) {
    getIt.registerLazySingleton<ProfileApiService>(
      () => ProfileApiService(dio),
    );
  }

  if (!getIt.isRegistered<DriverStatusRepository>()) {
    getIt.registerLazySingleton<DriverStatusRepository>(
      () => DriverStatusRepository(getIt<DriverStatusApiService>()),
    );
  }

  if (!getIt.isRegistered<ProfileRepository>()) {
    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepository(getIt<ProfileApiService>()),
    );
  }

  getIt.registerFactory<DriverStatusCubit>(
    () => DriverStatusCubit(getIt<DriverStatusRepository>()),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt<ProfileRepository>()),
  );

  if (!getIt.isRegistered<TermsRepository>()) {
    getIt.registerLazySingleton<TermsRepository>(
      () => TermsRepository(getIt<TermsApiService>()),
    );
  }
  getIt.registerFactory<TermsCubit>(() => TermsCubit(getIt<TermsRepository>()));

  // =========================
  // Offers
  // =========================
  if (!getIt.isRegistered<OffersApiService>()) {
    getIt.registerLazySingleton<OffersApiService>(() => OffersApiService(dio));
  }

  if (!getIt.isRegistered<OffersRepository>()) {
    getIt.registerLazySingleton<OffersRepository>(
      () => OffersRepository(getIt<OffersApiService>()),
    );
  }

  getIt.registerFactory<OfferCubit>(
    () => OfferCubit(getIt<OffersRepository>()),
  );

  // =========================
  // Orders
  // =========================
  if (!getIt.isRegistered<OrdersApiService>()) {
    getIt.registerLazySingleton<OrdersApiService>(() => OrdersApiService(dio));
  }

  if (!getIt.isRegistered<OrdersRepository>()) {
    getIt.registerLazySingleton<OrdersRepository>(
      () => OrdersRepository(getIt<OrdersApiService>()),
    );
  }

  // =========================
  // ✅ Driver Location (الجديد)
  // =========================
  if (!getIt.isRegistered<DriverLocationApiService>()) {
    getIt.registerLazySingleton<DriverLocationApiService>(
      () => DriverLocationApiService(dio),
    );
  }

  if (!getIt.isRegistered<DriverLocationRepository>()) {
    getIt.registerLazySingleton<DriverLocationRepository>(
      () => DriverLocationRepository(getIt<DriverLocationApiService>()),
    );
  }

  getIt.registerFactory<DriverLocationCubit>(
    () => DriverLocationCubit(getIt<DriverLocationRepository>()),
  );

  // =========================
  // OrderStatusCubit
  // =========================
  getIt.registerFactory<OrderStatusCubit>(
    () => OrderStatusCubit(getIt<OrdersRepository>()),
  );
  // =========================
  // Help Center
  // =========================
  if (!getIt.isRegistered<HelpCenterApiService>()) {
    getIt.registerLazySingleton<HelpCenterApiService>(
      () => HelpCenterApiService(dio),
    );
  }

  if (!getIt.isRegistered<HelpCenterRepo>()) {
    getIt.registerLazySingleton<HelpCenterRepo>(
      () => HelpCenterRepo(getIt<HelpCenterApiService>()),
    );
  }

  if (!getIt.isRegistered<HelpCenterCubit>()) {
    getIt.registerFactory<HelpCenterCubit>(
      () => HelpCenterCubit(getIt<HelpCenterRepo>()),
    );
  }
  // =========================
  // Earnings ✅
  // =========================
  if (!getIt.isRegistered<EarningsApiService>()) {
    getIt.registerLazySingleton<EarningsApiService>(
      () => EarningsApiService(dio),
    );
  }

  if (!getIt.isRegistered<EarningsRepository>()) {
    getIt.registerLazySingleton<EarningsRepository>(
      () => EarningsRepository(getIt<EarningsApiService>()),
    );
  }

  if (!getIt.isRegistered<EarningsCubit>()) {
    getIt.registerFactory<EarningsCubit>(
      () => EarningsCubit(getIt<EarningsRepository>()),
    );
  }

  // =========================
  // HelpCenterCubit
  // =========================
}
