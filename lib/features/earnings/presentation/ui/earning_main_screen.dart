import 'package:breez_food_driver/core/services/price_formatter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:breez_food_driver/features/earnings/presentation/cubit/earnings_cubit.dart';
import 'package:breez_food_driver/features/earnings/presentation/cubit/earnings_state.dart';
import 'package:breez_food_driver/features/earnings/presentation/ui/earning_order_tile.dart';

class EarningMainScreen extends StatefulWidget {
  const EarningMainScreen({super.key});

  @override
  State<EarningMainScreen> createState() => _EarningMainScreenState();
}

class _EarningMainScreenState extends State<EarningMainScreen> {
  DateTime _selectedDate = DateTime.now();
  int? _expandedOrderId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EarningsCubit>().load(); // today by default
    });
  }

  String _apiDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),

      builder: (context, child) {
        final isAr = context.locale.languageCode == 'ar';

        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: AppTheme.background,

            colorScheme: ColorScheme.dark(
              primary: AppTheme.primary, // لون اليوم/التحديد
              onPrimary: Colors.white, // لون النص فوق التحديد
              surface: const Color(0xFF2C2C2C), // خلفية الديالوج
              onSurface: Colors.white, // أرقام الأيام + النصوص
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary, // OK / CANCEL
                textStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            datePickerTheme: DatePickerThemeData(
              backgroundColor: const Color(0xFF2C2C2C),
              headerBackgroundColor: const Color(0xFF2C2C2C),
              headerForegroundColor: Colors.white,

              dayForegroundColor: WidgetStateProperty.all(Colors.white),
              weekdayStyle: TextStyle(color: Colors.white70, fontSize: 12.sp),
              dayStyle: TextStyle(color: Colors.white, fontSize: 12.sp),

              todayBorder: BorderSide(color: AppTheme.primary, width: 1.2),
              todayForegroundColor: WidgetStateProperty.all(AppTheme.primary),

              // selected day
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.primary;
                }
                return null;
              }),
              dayOverlayColor: WidgetStateProperty.all(
                Colors.white.withOpacity(0.06),
              ),

              // year picker
              yearForegroundColor: WidgetStateProperty.all(Colors.white),
              yearStyle: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ),
          child: Directionality(
            textDirection: isAr ? mt.TextDirection.rtl : mt.TextDirection.ltr,
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _expandedOrderId = null;
      });

      final isToday = _isSameDay(picked, DateTime.now());
      context.read<EarningsCubit>().load(
        date: isToday ? null : _apiDate(picked),
      );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.day == b.day && a.month == b.month && a.year == b.year;

  void _toggleExpansion(int orderId) {
    setState(() {
      _expandedOrderId = (_expandedOrderId == orderId) ? null : orderId;
    });
  }

  String _shortCreatedAt(String iso) {
    if (iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      final hh = d.hour.toString().padLeft(2, '0');
      final mm = d.minute.toString().padLeft(2, '0');
      final dd = d.day.toString().padLeft(2, '0');
      final mo = d.month.toString().padLeft(2, '0');
      return '$hh:$mm  $dd/$mo/${d.year}';
    } catch (_) {
      return iso;
    }
  }

  String _monthShort(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  String _formatHeaderDate(DateTime date) {
    final day = date.day;
    final month = _monthShort(date.month);
    final year = date.year;
    return '$day $month, $year';
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDay(_selectedDate, DateTime.now());

    final selectedDayText = isToday
        ? 'earnings.today'.tr()
        : '${_selectedDate.day} ${_monthShort(_selectedDate.month)}';

    return Directionality(
      textDirection: context.locale.languageCode == 'ar'
          ? mt.TextDirection.rtl
          : mt.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppTheme.background,

        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0, // ✅ يمنع لون/ظل عند السكرول
          backgroundColor: AppTheme.background,
          surfaceTintColor: Colors.transparent, // ✅ يمنع الـ tint تبع Material3
          shadowColor: Colors.transparent, // ✅ بدون ظل
          foregroundColor: Colors.white, // ✅ لون الأيقونات/النص
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'earnings.title'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                margin: EdgeInsets.only(right: 12.w, left: 12.w),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white70,
                      size: 18.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      selectedDayText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        body: BlocBuilder<EarningsCubit, EarningsState>(
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (msg) => _ErrorView(
                message: msg,
                onRetry: () => context.read<EarningsCubit>().load(
                  date: isToday ? null : _apiDate(_selectedDate),
                ),
              ),
              success: (model) {
                final data = model.data;
                if (data == null) {
                  return _ErrorView(
                    message: "No data",
                    onRetry: () => context.read<EarningsCubit>().load(
                      date: isToday ? null : _apiDate(_selectedDate),
                    ),
                  );
                }

                final b = data.balances;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'earnings.today_is'.tr()} ${_formatHeaderDate(_selectedDate)}',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 15,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _BigStatTile(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'earnings.total_balance'.tr(),
                        value: context.syp(b.total),
                        rightTitle: 'earnings.company'.tr(),
                        rightValue: context.syp(b.company),
                      ),

                      SizedBox(height: 10.h),

                      // 2) Two small tiles row (order / delivery)
                      Row(
                        children: [
                          Expanded(
                            child: _SmallStatTile(
                              icon: Icons.receipt_long,
                              title: 'earnings.order_balance'.tr(),
                              value: context.syp(b.order),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _SmallStatTile(
                              icon: Icons.delivery_dining,
                              title: 'earnings.delivery_balance'.tr(),
                              value: context.syp(b.delivery),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // 3) Two small tiles row (online / distance)
                      Row(
                        children: [
                          Expanded(
                            child: _SmallStatTile(
                              icon: Icons.access_time,
                              title: 'earnings.online_time'.tr(),
                              value: data.onlineTime.formatted,
                              trendText: null,
                              trendUp: null,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _SmallStatTile(
                              icon: Icons.route,
                              title: 'earnings.distance'.tr(),
                              value:
                                  '${data.distance.km.toStringAsFixed(1)} km',
                              trendText: null,
                              trendUp: null,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Orders title
                      Text(
                        'earnings.orders'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      if (data.orders.isEmpty)
                        Text(
                          'earnings.no_orders'.tr(),
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12.sp,
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.orders.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, i) {
                            final wrap = data.orders[i];
                            final order = wrap.order;
                            final restaurant = wrap.restaurant;

                            final isExpanded = _expandedOrderId == order.id;

                            return EarningOrderTile(
                              restaurantName:
                                  wrap.restaurant?.name ?? "Restaurant",
                              restaurantLogoUrl: wrap
                                  .restaurant
                                  ?.logoUrl, // ✅ من الموديل اللي عدلناه

                              orderAmount: order.itemsTotal,
                              deliveryFee: order.deliveryFee,
                              date: _shortCreatedAt(order.createdAt),

                              isExpanded: isExpanded,
                              onTap: () => _toggleExpansion(order.id),

                              orderId: order.id,
                              status: order.status,
                              customerCode: order.orderCustomerCode,
                              paymentMethod: order.paymentMethod,
                              paymentStatus: order.paymentStatus,
                              notes: order.notes,

                              timeline: wrap.timeline.map((t) {
                                // ✅ حول key لاسم مترجم
                                final label = 'order_status.${t.key}'
                                    .tr(); // pending/preparing/inway/delivered...
                                return EarningTimelineUi(
                                  label: label,
                                  time: t.time,
                                );
                              }).toList(),

                              items: wrap.items.map((it) {
                                return EarningItemUi(
                                  nameAr: it.nameAr,
                                  nameEn: it.nameEn,
                                  qty: it.quantity,
                                  spicy: it.withSpicy == 1,
                                  imageUrl:
                                      it.imageUrl, // ✅ من OrderItemMini getter
                                  totalPrice: it.totalPrice,
                                  deliveryTime: it.deliveryTime,
                                );
                              }).toList(),
                            );
                          },
                        ),

                      SizedBox(height: 12.h),
                    ],
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

// =================== Widgets ===================

class _BigStatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  // Right side like screenshot (Company label/value)
  final String? rightTitle;
  final String? rightValue;

  const _BigStatTile({
    required this.icon,
    required this.title,
    required this.value,
    this.rightTitle,
    this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF3F3F3F),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          _IconBadge(icon: icon),
          SizedBox(width: 10.w),

          // Left block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
                SizedBox(height: 4.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (rightTitle != null && rightValue != null) ...[
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rightTitle!,
                  style: TextStyle(color: Colors.white60, fontSize: 11.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  rightValue!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SmallStatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  final String? trendText; // مثل الصورة: "01hr" أو "-15%" أو "50m"
  final bool? trendUp;

  const _SmallStatTile({
    required this.icon,
    required this.title,
    required this.value,
    this.trendText,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    Color? trendColor;
    IconData? trendIcon;

    if (trendText != null && trendText!.trim().isNotEmpty) {
      if (trendUp == true) {
        trendColor = Colors.greenAccent;
        trendIcon = Icons.arrow_drop_up;
      } else if (trendUp == false) {
        trendColor = Colors.redAccent;
        trendIcon = Icons.arrow_drop_down;
      } else {
        trendColor = Colors.white60;
      }
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      height: 92.h,
      decoration: BoxDecoration(
        color: Color(0xFF3F3F3F),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(icon: icon, size: 30),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11.sp,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (trendText != null && trendText!.trim().isNotEmpty) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                if (trendIcon != null)
                  Icon(trendIcon, color: trendColor, size: 18.sp),
                Text(
                  trendText!,
                  style: TextStyle(
                    color: trendColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final double size;

  const _IconBadge({required this.icon, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Icon(icon, color: AppTheme.primary, size: (size * 0.55).sp),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: TextStyle(color: Colors.white70, fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: onRetry,
              child: Text("common.retry".tr()),
            ),
          ],
        ),
      ),
    );
  }
}
