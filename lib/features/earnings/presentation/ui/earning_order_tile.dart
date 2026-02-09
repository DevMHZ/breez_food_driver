import 'package:breez_food_driver/core/services/price_formatter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:flutter/material.dart' as mt;

class EarningOrderTile extends StatelessWidget {
  final String restaurantName;
  final String? restaurantLogoUrl;

  final double orderAmount;
  final double deliveryFee;
  final double total; // ✅ pass ready if you want (or compute)

  final String date;
  final bool isExpanded;
  final VoidCallback onTap;

  // ✅ order meta
  final int orderId;
  final String status;
  final int? customerCode;
  final String paymentMethod;
  final String paymentStatus;
  final String? notes;

  // ✅ timeline
  final List<EarningTimelineUi> timeline;

  // ✅ items
  final List<EarningItemUi> items;

  const EarningOrderTile({
    super.key,
    required this.restaurantName,
    this.restaurantLogoUrl,
    required this.orderAmount,
    required this.deliveryFee,
    double? total,
    required this.date,
    required this.isExpanded,
    required this.onTap,

    required this.orderId,
    required this.status,
    this.customerCode,
    required this.paymentMethod,
    required this.paymentStatus,
    this.notes,

    this.timeline = const [],
    this.items = const [],
  }) : total = total ?? (orderAmount + deliveryFee);

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF3F3F3F),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white60,
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),

                // ✅ logo
                _LogoBox(url: restaurantLogoUrl),
                SizedBox(width: 10.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurantName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '#$orderId • $date',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.syp(total),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${'earnings.delivery_fee'.tr()}: ${context.syp(deliveryFee)}',
                      style: TextStyle(color: Colors.white60, fontSize: 10.sp),
                    ),
                  ],
                ),
              ],
            ),

            if (isExpanded) ...[
              SizedBox(height: 10.h),
              Divider(color: Colors.white12, height: 1.h),
              SizedBox(height: 10.h),

              // ✅ meta
              _metaLine(context, label: 'earnings.status'.tr(), value: status),
              if (customerCode != null)
                _metaLine(
                  context,
                  label: 'tracking.customer_code_title'.tr(),
                  value: '$customerCode',
                ),
              _metaLine(
                context,
                label: 'tracking.payment'.tr(),
                value: '$paymentMethod • $paymentStatus',
              ),
              if ((notes ?? '').trim().isNotEmpty)
                _metaLine(
                  context,
                  label: isRTL ? 'ملاحظات' : 'Notes',
                  value: notes!.trim(),
                ),

              SizedBox(height: 10.h),

              // ✅ timeline chips
              if (timeline.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'tracking.timeline'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: timeline.map((t) {
                    final time = (t.time ?? '').trim();
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        '${t.label}${time.isEmpty ? "" : " • $time"}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 12.h),
              ],

              // ✅ items list
              if (items.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'tracking.items'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Column(children: items.map((it) => _ItemRow(it: it)).toList()),
                SizedBox(height: 10.h),
              ],

              // ✅ totals like before
              _row('earnings.order_amount'.tr(), context.syp(orderAmount)),
              SizedBox(height: 8.h),
              _row('earnings.delivery_fee'.tr(), context.syp(deliveryFee)),
              SizedBox(height: 10.h),
              _row('earnings.total'.tr(), context.syp(total), isTotal: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metaLine(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: TextStyle(color: Colors.white54, fontSize: 11.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 11.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.white70,
            fontSize: isTotal ? 12.sp : 11.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.white70,
            fontSize: isTotal ? 12.sp : 11.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// =================== Helpers UI Models ===================

class EarningItemUi {
  final String nameAr;
  final String nameEn;
  final int qty;
  final bool spicy;
  final String imageUrl;
  final double totalPrice;
  final int deliveryTime;

  const EarningItemUi({
    required this.nameAr,
    required this.nameEn,
    required this.qty,
    required this.spicy,
    required this.imageUrl,
    required this.totalPrice,
    required this.deliveryTime,
  });
}

class EarningTimelineUi {
  final String label; // already translated/pretty
  final String? time;

  const EarningTimelineUi({required this.label, this.time});
}

// =================== Widgets ===================

class _LogoBox extends StatelessWidget {
  final String? url;
  const _LogoBox({this.url});

  @override
  Widget build(BuildContext context) {
    final u = (url ?? '').trim();
    if (u.isEmpty) {
      return Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.white12),
        ),
        child: const Icon(Icons.store, color: Colors.white70, size: 20),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Image.network(
        u,
        width: 44.w,
        height: 44.w,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 44.w,
          height: 44.w,
          color: Colors.white10,
          child: const Icon(Icons.store, color: Colors.white70, size: 20),
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final EarningItemUi it;
  const _ItemRow({required this.it});

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == mt.TextDirection.rtl;
    final name = isRTL
        ? (it.nameAr.trim().isNotEmpty ? it.nameAr : it.nameEn)
        : (it.nameEn.trim().isNotEmpty ? it.nameEn : it.nameAr);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: (it.imageUrl.trim().isEmpty)
                ? Container(
                    width: 52.w,
                    height: 52.w,
                    color: Colors.white10,
                    child: const Icon(Icons.fastfood, color: Colors.white70),
                  )
                : Image.network(
                    it.imageUrl,
                    width: 52.w,
                    height: 52.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 52.w,
                      height: 52.w,
                      color: Colors.white10,
                      child: const Icon(Icons.fastfood, color: Colors.white70),
                    ),
                  ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'x${it.qty} • ${it.spicy ? "🌶️" : "—"} • ${it.deliveryTime} ${'common.min'.tr()}',
                  style: TextStyle(color: Colors.white60, fontSize: 11.sp),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            context.syp(it.totalPrice),
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
