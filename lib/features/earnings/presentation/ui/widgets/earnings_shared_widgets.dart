import 'package:breez_food_driver/core/services/price_formatter.dart';
import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as nt;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class EarningsShell extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;

  const EarningsShell({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: action == null
            ? null
            : [
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 12.w),
                  child: action,
                ),
              ],
      ),
      body: child,
    );
  }
}

class EarningsDatePickerChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const EarningsDatePickerChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white70,
              size: 18.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EarningsToggleTab extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const EarningsToggleTab({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: selected ? AppTheme.primary : Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 68.w,
              height: 2.6.h,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EarningsCard extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Widget child;
  final VoidCallback? onTap;

  const EarningsCard({
    super.key,
    this.padding,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: child,
    );

    if (onTap == null) return body;

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: body,
    );
  }
}

class EarningsStatCard extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;
  final String label;
  final String value;
  final String? subValue;
  final VoidCallback? onTap;
  final bool compact;

  const EarningsStatCard({
    super.key,
    this.icon,
    this.svgAsset,
    required this.label,
    required this.value,
    this.subValue,
    this.onTap,
    this.compact = false,
  }) : assert(icon != null || svgAsset != null);

  @override
  Widget build(BuildContext context) {
    return EarningsCard(
      onTap: onTap,
      child:
      // Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     _BadgeIcon(icon: icon, svgAsset: svgAsset),
      //     SizedBox(height: compact ? 10.h : 16.h),
      //     Text(
      //       label,
      //       style: TextStyle(
      //         color: Colors.white70,
      //         fontSize: compact ? 12.sp : 13.sp,
      //         fontWeight: FontWeight.w500,
      //       ),
      //     ),
      //     SizedBox(height: 6.h),
      //     Text(
      //       value,
      //       style: TextStyle(
      //         color: Colors.white,
      //         fontSize: compact ? 18.sp : 21.sp,
      //         fontWeight: FontWeight.w700,
      //       ),
      //     ),
      //     if (subValue != null && subValue!.trim().isNotEmpty) ...[
      //       SizedBox(height: 4.h),
      //       Text(
      //         subValue!,
      //         style: TextStyle(color: Colors.white54, fontSize: 11.sp),
      //       ),
      //     ],
      //   ],
      // ),
      Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 النص (العنوان)
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            _BadgeIcon(icon: icon, svgAsset: svgAsset),

          ],
              ),
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

class EarningsCountCard extends StatelessWidget {
  final String iconAsset;
  final String label;
  final int count;

  const EarningsCountCard({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return EarningsCard(
      child: Column(
        children: [
          _BadgeSvgIcon(assetPath: iconAsset),
          SizedBox(height: 10.h),
          Text(
            '$count',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}

class _BadgeSvgIcon extends StatelessWidget {
  final String assetPath;

  const _BadgeSvgIcon({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(assetPath, fit: BoxFit.contain),
    );
  }
}

class EarningsSectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const EarningsSectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(color: Colors.white54, fontSize: 12.sp),
          ),
      ],
    );
  }
}

class EarningsHourlyChart extends StatelessWidget {
  final List<ChartBarUiModel> points;

  const EarningsHourlyChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return EarningsCard(
        child: SizedBox(
          height: 180.h,
          child: Center(
            child: Text(
              'لا يوجد داتا كافية'.tr(),
              style: TextStyle(color: Colors.white54, fontSize: 12.sp),
            ),
          ),
        ),
      );
    }

    final maxAmount = points.fold<double>(
      0,
      (max, item) => item.amount > max ? item.amount : max,
    );

    return EarningsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EarningsSectionTitle(title: 'الأرباح بالساعات'),
          SizedBox(height: 16.h),
          SizedBox(
            height: 220.h,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: points.map((point) {
                  final normalized = maxAmount <= 0
                      ? 0.0
                      : (point.amount / maxAmount);

                  final barHeight = point.amount <= 0
                      ? 8.h
                      : (110.h * normalized).clamp(18.h, 110.h).toDouble();

                  return Padding(
                    padding: EdgeInsetsDirectional.only(end: 10.w),
                    child: SizedBox(
                      width: 54.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FittedBox(
                            child: Text(
                              point.amount > 0 ? point.valueLabel : '0',
                              maxLines: 1,
                              style: TextStyle(
                                color: point.highlighted
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 28.w,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: point.highlighted
                                  ? AppTheme.primary
                                  : Colors.white38,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            point.label,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${point.ordersCount} طلب',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartBarUiModel {
  final String label;
  final double amount;
  final String valueLabel;
  final int ordersCount;
  final bool highlighted;

  const ChartBarUiModel({
    required this.label,
    required this.amount,
    required this.valueLabel,
    required this.ordersCount,
    this.highlighted = false,
  });
}

class EarningsSegmentedFilter extends StatelessWidget {
  final List<EarningsFilterChipModel> items;

  const EarningsSegmentedFilter({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: InkWell(
              borderRadius: BorderRadius.circular(22.r),
              onTap: item.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: item.selected
                      ? AppTheme.primary
                      : const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Center(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class EarningsFilterChipModel {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const EarningsFilterChipModel({
    required this.label,
    required this.selected,
    required this.onTap,
  });
}

class EarningsOrderCard extends StatelessWidget {
  final String orderNumber;
  final bool isVip;
  final String deliveredAt;
  final String restaurantName;
  final String restaurantLogoUrl;
  final double distanceKm;
  final double customerAmount;
  final double driverEarning;
  final double companyFromRestaurant;
  final double vipPrice;
  final String deliveryTo;
  final String customerImageUrl;
  final String createdAt;
  final String note;

  const EarningsOrderCard({
    required this.deliveredAt,
    super.key,
    required this.orderNumber,
    required this.isVip,
    required this.restaurantName,
    required this.restaurantLogoUrl,
    required this.distanceKm,
    required this.customerAmount,
    required this.driverEarning,
    required this.companyFromRestaurant,
    required this.vipPrice,
    required this.deliveryTo,
    required this.customerImageUrl,
    required this.createdAt,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return EarningsCard(
      child: Column(
        children: [
          Row(
            textDirection: nt.TextDirection.ltr,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'earnings.order_number'.tr(),
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '#$orderNumber',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (isVip) ...[
                SizedBox(width: 10.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Text(
                    'VIP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _OrderMeta(
                  label: 'earnings.restaurant'.tr(),
                  value: restaurantName.isEmpty
                      ? 'earnings.unknown_restaurant'.tr()
                      : restaurantName,
                  icon: Icons.storefront_outlined,
                  imageUrl: restaurantLogoUrl,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _OrderMeta(
                  label: 'earnings.distance'.tr(),
                  value: '${distanceKm.toStringAsFixed(1)} KM',
                  icon: Icons.route_rounded,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  title: 'earnings.customer_amount'.tr(),
                  value: context.syp(customerAmount),
                ),
              ),
              SizedBox(width: 10.w),
              Container(width: 1, height: 34.h, color: Colors.white24),
              SizedBox(width: 10.w),
              Expanded(
                child: _MetricBox(
                  title: 'earnings.driver_earning'.tr(),
                  value: context.syp(driverEarning),
                  highlight: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  title: 'earnings.company_from_restaurant'.tr(),
                  value: context.syp(companyFromRestaurant),
                ),
              ),
              if (isVip) ...[
                SizedBox(width: 10.w),
                Container(width: 1, height: 34.h, color: Colors.white24),
                SizedBox(width: 10.w),
                Expanded(
                  child: _MetricBox(
                    title: 'earnings.vip_price'.tr(),
                    value: context.syp(vipPrice),
                    highlight: true,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2F2F2F),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                if (customerImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18.r),
                    child: Image.network(
                      customerImageUrl,
                      width: 36.w,
                      height: 36.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _AvatarPlaceholder(),
                    ),
                  )
                else
                  _AvatarPlaceholder(),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    deliveryTo.isEmpty
                        ? 'earnings.delivery_unknown'.tr()
                        : '${'earnings.delivery_to'.tr()}\n$deliveryTo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: Colors.white54,
                size: 15.sp,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  createdAt,
                  style: TextStyle(color: Colors.white60, fontSize: 11.sp),
                ),
              ),
            ],
          ),
          if (note.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              note,
              style: TextStyle(color: Colors.white60, fontSize: 11.sp),
            ),
          ],
        ],
      ),
    );
  }
}

class EarningsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const EarningsErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.white70,
              size: 34.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13.sp),
            ),
            SizedBox(height: 14.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class EarningsEmptyView extends StatelessWidget {
  final String title;
  final String subtitle;

  const EarningsEmptyView({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, color: Colors.white54, size: 34.sp),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;

  const _BadgeIcon({this.icon, this.svgAsset})
    : assert(icon != null || svgAsset != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: svgAsset != null
            ? SvgPicture.asset(
                svgAsset!,
                width: 16.w,
                height: 16.w,
                colorFilter: const ColorFilter.mode(
                  AppTheme.primary,
                  BlendMode.srcIn,
                ),
              )
            : Icon(icon, color: AppTheme.primary, size: 16.sp),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String title;
  final String value;
  final bool highlight;

  const _MetricBox({
    required this.title,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF2F2F2F),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white70, fontSize: 11.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: highlight ? AppTheme.primary : Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderMeta extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String imageUrl;

  const _OrderMeta({
    required this.label,
    required this.value,
    required this.icon,
    this.imageUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: const Color(0xFF2F2F2F),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(icon, color: AppTheme.primary, size: 18.sp),
                  ),
                )
              : Icon(icon, color: AppTheme.primary, size: 18.sp),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.white70, fontSize: 11.sp),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Icon(Icons.person_rounded, color: Colors.white70, size: 18.sp),
    );
  }
}
