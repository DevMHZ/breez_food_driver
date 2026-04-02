import 'package:breez_food_driver/core/services/price_formatter.dart';
import 'package:breez_food_driver/features/earnings/data/repo/earnings_repo.dart';
import 'package:breez_food_driver/features/earnings/presentation/cubit/earnings_orders_cubit.dart';
import 'package:breez_food_driver/features/earnings/presentation/cubit/earnings_orders_state.dart';
import 'package:breez_food_driver/features/earnings/presentation/ui/widgets/earnings_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class EarningsOrdersScreen extends StatelessWidget {
  final EarningsRepository repository;
  final DateTime selectedDate;

  const EarningsOrdersScreen({
    super.key,
    required this.repository,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          EarningsOrdersCubit(repository)..load(date: _apiDate(selectedDate)),
      child: _EarningsOrdersView(selectedDate: selectedDate),
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

class _EarningsOrdersView extends StatelessWidget {
  final DateTime selectedDate;

  const _EarningsOrdersView({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return EarningsShell(
      title: 'إجمالي أرباح اليوم',
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: BlocBuilder<EarningsOrdersCubit, EarningsOrdersState>(
            builder: (context, state) {
              if (state.isLoading && state.data == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.errorMessage.isNotEmpty && state.data == null) {
                return EarningsErrorView(
                  message: state.errorMessage,
                  onRetry: () => context.read<EarningsOrdersCubit>().load(
                    date: _apiDate(selectedDate),
                  ),
                );
              }

              final data = state.data;
              if (data == null) {
                return const EarningsEmptyView(
                  title: 'لا توجد طلبات',
                  subtitle: 'لا توجد طلبات لهذا اليوم',
                );
              }

              final orders = context.read<EarningsOrdersCubit>().filteredOrders;

              return Column(
                children: [
                  EarningsSegmentedFilter(
                    items: [
                      EarningsFilterChipModel(
                        label: 'الكل',
                        selected: state.filter == EarningsOrdersFilter.all,
                        onTap: () => context
                            .read<EarningsOrdersCubit>()
                            .changeFilter(EarningsOrdersFilter.all),
                      ),
                      EarningsFilterChipModel(
                        label: 'عادي',
                        selected: state.filter == EarningsOrdersFilter.regular,
                        onTap: () => context
                            .read<EarningsOrdersCubit>()
                            .changeFilter(EarningsOrdersFilter.regular),
                      ),
                      EarningsFilterChipModel(
                        label: 'VIP',
                        selected: state.filter == EarningsOrdersFilter.vip,
                        onTap: () => context
                            .read<EarningsOrdersCubit>()
                            .changeFilter(EarningsOrdersFilter.vip),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  EarningsCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: _FilterStatBlock(
                            label: 'إجمالي الطلبات',
                            value: '${data.stats.totalCount}',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 38.h,
                          color: Colors.white24,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _FilterStatBlock(
                            label: 'إجمالي الأرباح',
                            value: context.syp(data.stats.totalEarnings),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: orders.isEmpty
                        ? const EarningsEmptyView(
                            title: 'لا توجد طلبات',
                            subtitle: 'لا توجد طلبات لهذا اليوم',
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: orders.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return EarningsOrderCard(
                                orderNumber: order.orderNumber,
                                isVip: order.isVip,
                                restaurantName: order.restaurantName,
                                restaurantLogoUrl: order.restaurantLogoUrl,
                                distanceKm: order.distanceKm,
                                customerAmount: order.customerAmount,
                                driverEarning: order.driverEarning,
                                companyFromRestaurant:
                                    order.companyFromRestaurant,
                                vipPrice: order.vipPrice,
                                deliveryTo: order.deliveryTo,
                                customerImageUrl: order.customerImageUrl,
                                createdAt: _formatDate(order.createdAt),
                                deliveredAt: _formatDate(order.deliveredAt),
                                note: order.note,
                              );
                            },
                          ),
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

  String _formatDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';

    DateTime? parsed;

    try {
      parsed = DateTime.parse(value).toLocal();
    } catch (_) {}

    parsed ??= () {
      try {
        return DateFormat('dd/MM/yyyy HH:mm', 'en').parseStrict(value);
      } catch (_) {
        return null;
      }
    }();

    if (parsed == null) {
      return '\u200E$value';
    }

    return '\u200E${DateFormat('dd/MM/yyyy - HH:mm', 'en').format(parsed)}';
  }
}

class _FilterStatBlock extends StatelessWidget {
  final String label;
  final String value;

  const _FilterStatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 12.sp),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
