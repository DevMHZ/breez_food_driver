import 'package:breez_food_driver/core/services/price_formatter.dart';
import 'package:breez_food_driver/features/earnings/data/models/earnings_models.dart';
import 'package:breez_food_driver/features/earnings/data/repo/earnings_repo.dart';
import 'package:breez_food_driver/features/earnings/presentation/cubit/earnings_cubit.dart';
import 'package:breez_food_driver/features/earnings/presentation/cubit/earnings_financial_details_cubit.dart';
import 'package:breez_food_driver/features/earnings/presentation/cubit/earnings_financial_details_state.dart';
import 'package:breez_food_driver/features/earnings/presentation/cubit/earnings_state.dart';
import 'package:breez_food_driver/features/earnings/presentation/ui/earning_orders_screen.dart';
import 'package:breez_food_driver/features/earnings/presentation/ui/widgets/earnings_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class EarningsMainScreen extends StatelessWidget {
  final EarningsRepository repository;

  const EarningsMainScreen({super.key, required this.repository});

  static Route<dynamic> route({required EarningsRepository repository}) {
    return MaterialPageRoute(
      builder: (_) => EarningsMainScreen(repository: repository),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => EarningsCubit(repository)),
        BlocProvider(create: (_) => EarningsFinancialDetailsCubit(repository)),
      ],
      child: _EarningsMainView(repository: repository),
    );
  }
}

enum _EarningsMainTab { driver, company }

class _EarningsMainView extends StatefulWidget {
  final EarningsRepository repository;

  const _EarningsMainView({required this.repository});

  @override
  State<_EarningsMainView> createState() => _EarningsMainViewState();
}

class _EarningsMainViewState extends State<_EarningsMainView> {
  late DateTime _selectedDate;
  _EarningsMainTab _tab = _EarningsMainTab.driver;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadAll();
    });
  }

  String? get _apiDate =>
      _isToday(_selectedDate) ? null : DateFormat('yyyy-M-d').format(_selectedDate);

  Future<void> _loadAll() async {
    await context.read<EarningsCubit>().load(date: _apiDate);
    if (!mounted) return;
    await context.read<EarningsFinancialDetailsCubit>().load(date: _apiDate);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  String _dateChipLabel() {
    if (_isToday(_selectedDate)) return 'اليوم';
    return DateFormat('d MMM', 'ar').format(_selectedDate);
  }

  String _fullDateLabel(String rawDate) {
    DateTime date;
    try {
      date = rawDate.trim().isNotEmpty ? DateTime.parse(rawDate) : _selectedDate;
    } catch (_) {
      date = _selectedDate;
    }

    return DateFormat('EEEE، d MMMM yyyy', 'ar').format(date);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      locale: const Locale('ar'),
    );

    if (picked == null) return;

    final normalized = DateTime(picked.year, picked.month, picked.day);
    final isSame =
        normalized.year == _selectedDate.year &&
        normalized.month == _selectedDate.month &&
        normalized.day == _selectedDate.day;

    if (isSame) return;

    setState(() {
      _selectedDate = normalized;
    });

    await _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return EarningsShell(
      title: 'المكاسب',
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: EarningsToggleTab(
                      title: 'السائق',
                      selected: _tab == _EarningsMainTab.driver,
                      onTap: () => setState(() => _tab = _EarningsMainTab.driver),
                    ),
                  ),
                  Expanded(
                    child: EarningsToggleTab(
                      title: 'شركة Breeze',
                      selected: _tab == _EarningsMainTab.company,
                      onTap: () => setState(() => _tab = _EarningsMainTab.company),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Row(
                textDirection: Directionality.of(context),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔹 النصوص (العنوان + التاريخ)
                  Expanded(
                    child: BlocBuilder<EarningsCubit, EarningsState>(
                      builder: (context, state) {
                        final dataDate = state.data?.date ?? '';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الإحصائيات',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _fullDateLabel(dataDate),
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // 🔹 الفلتر (التاريخ)
                  EarningsDatePickerChip(
                    label: _dateChipLabel(),
                    onTap: _pickDate,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: _tab == _EarningsMainTab.driver
                    ? BlocBuilder<EarningsCubit, EarningsState>(
                        builder: (context, state) {
                          if (state.isLoading && state.data == null) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (state.errorMessage.isNotEmpty && state.data == null) {
                            return EarningsErrorView(
                              message: state.errorMessage,
                              onRetry: _loadAll,
                            );
                          }

                          final data = state.data;
                          if (data == null) {
                            return const EarningsEmptyView(
                              title: 'لا توجد بيانات',
                              subtitle: 'لا توجد بيانات متاحة لهذا اليوم',
                            );
                          }

                          return _DriverTabContent(
                            repository: widget.repository,
                            selectedDate: _selectedDate,
                            data: data,
                            isRefreshing: state.isLoading,
                          );
                        },
                      )
                    : BlocBuilder<
                        EarningsFinancialDetailsCubit,
                        EarningsFinancialDetailsState
                      >(
                        builder: (context, state) {
                          if (state.isLoading && state.data == null) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (state.errorMessage.isNotEmpty && state.data == null) {
                            return EarningsErrorView(
                              message: state.errorMessage,
                              onRetry: _loadAll,
                            );
                          }

                          final data = state.data;
                          if (data == null) {
                            return const EarningsEmptyView(
                              title: 'لا توجد بيانات',
                              subtitle: 'لا توجد بيانات متاحة لهذا اليوم',
                            );
                          }

                          return _CompanyTabContent(
                            data: data,
                            isRefreshing: state.isLoading,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverTabContent extends StatelessWidget {
  final EarningsRepository repository;
  final DateTime selectedDate;
  final EarningsOverviewData data;
  final bool isRefreshing;

  const _DriverTabContent({
    required this.repository,
    required this.selectedDate,
    required this.data,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    final maxAmount = data.earningsByHour.fold<double>(
      0,
      (max, item) => item.amount > max ? item.amount : max,
    );

    final points = data.earningsByHour.map((item) {
      return ChartBarUiModel(
        label: item.label,
        amount: item.amount,
        valueLabel: context.syp(item.amount),
        ordersCount: item.ordersCount,
        highlighted: item.amount > 0 && item.amount == maxAmount,
      );
    }).toList();

    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            EarningsStatCard(
              svgAsset: 'assets/b_driver/icon_cash.svg',
              label: 'رصيد السائق الحالي',
              value: context.syp(data.currentBalance),
            ),
            SizedBox(height: 10.h),
            EarningsStatCard(
              svgAsset: 'assets/b_driver/icon_cash.svg',
              label: 'إجمالي أرباح اليوم',
              value: context.syp(data.todayEarnings),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EarningsOrdersScreen(
                      repository: repository,
                      selectedDate: selectedDate,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: EarningsCountCard(
                    iconAsset: 'assets/b_driver/vip_orders.svg',
                    label: 'طلبات مميزة',
                    count: data.ordersStats.vip,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: EarningsCountCard(
                    iconAsset: 'assets/b_driver/regular_orders.svg',
                    label: 'طلبات عادية',
                    count: data.ordersStats.regular,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            EarningsHourlyChart(points: points),
            SizedBox(height: 10.h),
            EarningsCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إجمالي الطلبات',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '${data.ordersStats.total}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 42.h, color: Colors.white24),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المسافة الإجمالية',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '${data.totalDistance.toStringAsFixed(1)} كم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
          ],
        ),
        if (isRefreshing)
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _CompanyTabContent extends StatelessWidget {
  final EarningsFinancialDetailsData data;
  final bool isRefreshing;

  const _CompanyTabContent({
    required this.data,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Row(
              children: [
                Expanded(
                  child: EarningsCard(
                    padding: EdgeInsets.all(16.w),
                    child: _TopAmountBlock(
                      label: 'العهدة الأولية',
                      value: context.syp(data.transactions.paidAmount),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: EarningsCard(
                    padding: EdgeInsets.all(16.w), // 👈 مهم
                    child: _TopAmountBlock(
                      label: 'العهدة المتبقية',
                      value: context.syp(data.transactions.pendingAmount),
                    ),
                  ),
                ),


              ],
            ),


            SizedBox(height: 10.h),
            EarningsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LargeMetricLine(
                    label: 'المستحق للدفع',
                    value: context.syp(data.transactions.pendingAmount),
                  ),
                  SizedBox(height: 10.h),
                  _LargeMetricLine(
                    label: 'تم الدفع للمحاسب',
                    value: context.syp(data.transactions.paidAmount),
                  ),
                  SizedBox(height: 10.h),
                  _LargeMetricLine(
                    label: 'الباقي للمحاسب',
                    value: context.syp(data.transactions.remaining),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            EarningsStatCard(
              icon: Icons.store_mall_directory_outlined,
              label: 'حصة الشركة من المطاعم',
              value: context.syp(data.commissions.companyFromRestaurants),
              compact: true,
            ),
            SizedBox(height: 10.h),
            EarningsStatCard(
              icon: Icons.delivery_dining_outlined,
              label: 'حصة الشركة من السائقين',
              value: context.syp(data.commissions.companyFromDrivers),
              compact: true,
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: EarningsCountCard(
                    iconAsset: 'assets/b_driver/vip_orders.svg',
                    label: 'طلبات مميزة',
                    count: data.ordersStats.vip,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: EarningsCountCard(
                    iconAsset: 'assets/b_driver/regular_orders.svg',

                    label: 'طلبات عادية',
                    count: data.ordersStats.regular,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: EarningsStatCard(
                    icon: Icons.payments_outlined,
                    label: 'إجمالي الطلبات VIP',
                    value: context.syp(data.amountsByType.vipTotal),
                    compact: true,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: EarningsStatCard(
                    icon: Icons.payments_outlined,
                    label: 'إجمالي الطلبات العادية',
                    value: context.syp(data.amountsByType.regularTotal),
                    compact: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: EarningsStatCard(
                    icon: Icons.payments_outlined,
                    label: 'نسبة الإدارة من الطلبات المميزة',
                    value: context.syp(data.adminFees.fromVip),
                    compact: true,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: EarningsStatCard(
                    icon: Icons.payments_outlined,
                    label: 'نسبة الإدارة من الطلبات العادية',
                    value: context.syp(data.adminFees.fromRegular),
                    compact: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // EarningsCard(
            //   child: _LargeMetricLine(
            //     label: 'الإجمالي العام',
            //     value: context.syp(data.amountsByType.grandTotal),
            //   ),
            // ),
            // SizedBox(height: 18.h),
          ],
        ),
        if (isRefreshing)
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _TopAmountBlock extends StatelessWidget {
  final String label;
  final String value;

  const _TopAmountBlock({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.h, // 👈 يوحد ارتفاع الكرتين
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 صف الأيقونة + النص
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.payments_outlined,

                  color: const Color(0xFF00C853),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),

              // 👇 مهم ليلف النص مثل الصورة
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.sp,
                    height: 1.3, // 👈 نفس السطرين بالصورة
                  ),
                ),
              ),
            ],
          ),

          const Spacer(), // 👈 يدفع الرقم للأسفل

          // 🔹 الرقم
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeMetricLine extends StatelessWidget {
  final String label;
  final String value;

  const _LargeMetricLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}