import 'package:breez_food_driver/core/di/di.dart';
import 'package:breez_food_driver/core/network/dio_factory.dart';
import 'package:breez_food_driver/core/services/shared_perfrences_key.dart';
import 'package:breez_food_driver/features/driver_location/presentation/cubit/driver_location_cubit.dart';
import 'package:breez_food_driver/features/orders/data/api/offers_api_service.dart'
    hide OffersApiService;
import 'package:breez_food_driver/features/orders/data/api/offers_api_service.dart';
import 'package:breez_food_driver/features/offers/data/repo/offers_repo.dart';
import 'package:breez_food_driver/features/offers/presentation/cubit/offers_cubit.dart';
import 'package:breez_food_driver/features/auth/presentation/ui/login_page.dart';
import 'package:breez_food_driver/features/driver_status/presentation/cubit/driver_status_cubit.dart';
import 'package:breez_food_driver/features/home_map/presentation/ui/home_map_screen.dart';
import 'package:breez_food_driver/features/orders/data/api/orders_api_service.dart';
import 'package:breez_food_driver/features/orders/data/repo/orders_repo.dart';
import 'package:breez_food_driver/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final hasToken = await AuthStorageHelper.hasToken();

    if (!mounted) return;

    if (hasToken) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<DriverStatusCubit>()),
              BlocProvider(
                create: (_) => getIt<DriverLocationCubit>(),
              ), // ✅ هذا المهم
              BlocProvider(create: (_) => getIt<OfferCubit>()),
              BlocProvider(create: (_) => getIt<OrderStatusCubit>()),
            ],
            child: const HomeMapScreen(),
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
