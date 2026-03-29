import 'package:breez_food_driver/core/services/price_formatter.dart';
import 'package:breez_food_driver/features/earnings/data/repo/earnings_repo.dart';
import 'package:breez_food_driver/features/earnings/presentation/cubit/earnings_financial_details_cubit.dart';
import 'package:breez_food_driver/features/earnings/presentation/cubit/earnings_financial_details_state.dart';
import 'package:breez_food_driver/features/earnings/presentation/ui/widgets/earnings_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EarningsFinancialDetailsScreen extends StatelessWidget {
  final EarningsRepository repository;
  final DateTime selectedDate;

  const EarningsFinancialDetailsScreen({
    super.key,
    required this.repository,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          EarningsFinancialDetailsCubit(repository)
            ..load(date: _apiDate(selectedDate)),
      child: _EarningsFinancialDetailsView(selectedDate: selectedDate),
    );
  }

  String? _apiDate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        now.year == date.year && now.month == date.month && now.day == date.day;
    if (isToday) return null;
    return '${date.year}-${date.month}-${date.day}';
  }
}

class _EarningsFinancialDetailsView extends StatelessWidget {
  final DateTime selectedDate;

  const _EarningsFinancialDetailsView({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return EarningsShell(
      title: 'شركة Breeze',
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child:
              BlocBuilder<
                EarningsFinancialDetailsCubit,
                EarningsFinancialDetailsState
              >(
                builder: (context, state) {
                  if (state.isLoading && state.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.errorMessage.isNotEmpty && state.data == null) {
                    return EarningsErrorView(
                      message: state.errorMessage,
                      onRetry: () => context
                          .read<EarningsFinancialDetailsCubit>()
                          .load(date: _apiDate(selectedDate)),
                    );
                  }

                  final data = state.data;
                  if (data == null) {
                    return const EarningsEmptyView(
                      title: 'لا توجد بيانات',
                      subtitle: 'لا توجد بيانات مالية لهذا اليوم',
                    );
                  }

                  return ListView(
                    children: [
                      EarningsStatCard(
                        svgAsset: 'assets/b_driver/icon_cash.svg',
                        label: 'رصيد السائق الحالي',
                        value: context.syp(data.currentBalance),
                      ),
                      SizedBox(height: 10.h),
                      EarningsStatCard(
                        icon: Icons.payments_outlined,
                        label: 'الإجمالي العام',
                        value: context.syp(data.amountsByType.grandTotal),
                      ),
                    ],
                  );
                },
              ),
        ),
      ),
    );
  }

  String? _apiDate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        now.year == date.year && now.month == date.month && now.day == date.day;
    if (isToday) return null;
    return '${date.year}-${date.month}-${date.day}';
  }
}
