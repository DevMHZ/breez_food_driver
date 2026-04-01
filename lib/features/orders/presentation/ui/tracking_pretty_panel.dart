import 'package:breez_food_driver/core/services/price_formatter.dart';
import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackingPrettyPanel extends StatelessWidget {
  final bool showCustomerInfo;
  final bool showOrderSection;
  final int orderId;
  final String statusText;
  final bool restaurantCalled;
  final bool primaryLoading;
  final bool detailsLoading;
  final String? detailsError;

  final Map<String, dynamic> order;
  final Map<String, dynamic> restaurant;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> appetizers;

  final LatLng? pickup;
  final LatLng? dropoff;

  final VoidCallback onRetry;

  final List<String> restaurantPhones;
  final VoidCallback? onCallRestaurant1;
  final VoidCallback? onCallRestaurant2;

  final Future<void> Function(LatLng? target) onNavigateTo;

  final String primaryBtnText;
  final bool primaryBtnEnabled;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onEmergencyPressed;

  final Map<String, dynamic>? customer;

  const TrackingPrettyPanel({
    super.key,
    required this.showCustomerInfo,
    required this.orderId,
    required this.statusText,
    required this.restaurantCalled,
    required this.primaryLoading,
    required this.detailsLoading,
    required this.detailsError,
    required this.order,
    required this.restaurant,
    required this.items,
    required this.appetizers,
    required this.pickup,
    required this.dropoff,
    required this.onRetry,
    required this.restaurantPhones,
    required this.onCallRestaurant1,
    required this.onCallRestaurant2,
    required this.onNavigateTo,
    required this.primaryBtnText,
    required this.primaryBtnEnabled,
    required this.onPrimaryPressed,
    required this.onEmergencyPressed,
    this.customer,
    required this.showOrderSection,
  });

  bool _isZeroish(dynamic v) {
    if (v == null) return true;
    if (v is num) return v == 0;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return true;
    final n = num.tryParse(s);
    return n == null || n == 0;
  }

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('${v ?? ''}'.trim()) ?? 0;
  }

  String _v(dynamic x, {String empty = 'لا يوجد'}) {
    if (x == null) return empty;
    final s = x.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return empty;
    return s;
  }

  String _rawText(dynamic x) {
    if (x == null) return '';
    final s = x.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return '';
    return s;
  }

  bool _isMissingText(String s) {
    final t = s.trim();
    return t.isEmpty || t == '—' || t == 'لا يوجد';
  }

  bool _hasPhone(String p) {
    final t = p.trim();
    return t.isNotEmpty && t != '—' && t.toLowerCase() != 'null';
  }

  Widget _gap(double h) => SizedBox(height: h);

  String _itemName(Map<String, dynamic> it) {
    final ar = _rawText(it['name_ar']);
    if (ar.isNotEmpty) return ar;

    final name = _rawText(it['name']);
    if (name.isNotEmpty) return name;

    final en = _rawText(it['name_en']);
    if (en.isNotEmpty) return en;

    return 'وجبة';
  }

  String _itemNote(Map<String, dynamic> it) {
    final raw =
        it['notes'] ??
        it['note'] ??
        it['special_notes'] ??
        it['comment'] ??
        it['instructions'] ??
        it['item_note'] ??
        it['meal_note'] ??
        it['meal_notes'];

    return _v(raw, empty: 'لا يوجد');
  }

  bool _itemHasPrice(Map<String, dynamic> it) {
    const keys = [
      'price_for_driver',
      'price',
      'unit_price',
      'item_price',
      'total_price',
      'item_total',
      'amount',
    ];

    for (final key in keys) {
      if (!_isZeroish(it[key])) return true;
    }
    return false;
  }

  double _itemPrice(Map<String, dynamic> it) {
    return _toDouble(
      it['price_for_driver'] ??
          it['price'] ??
          it['unit_price'] ??
          it['item_price'] ??
          it['total_price'] ??
          it['item_total'] ??
          it['amount'],
    );
  }

  List<String> _collectTexts(dynamic value) {
    if (value == null) return [];

    if (value is String) {
      final s = value.trim();
      if (s.isEmpty || s.toLowerCase() == 'null') return [];
      return [s];
    }

    if (value is num || value is bool) {
      return [value.toString()];
    }

    if (value is List) {
      final result = <String>[];
      for (final item in value) {
        result.addAll(_collectTexts(item));
      }
      return result;
    }

    if (value is Map) {
      const preferredKeys = [
        'name_ar',
        'name_en',
        'name',
        'title',
        'label',
        'value',
      ];

      final preferred = <String>[];
      for (final key in preferredKeys) {
        preferred.addAll(_collectTexts(value[key]));
      }
      if (preferred.isNotEmpty) return preferred;

      final result = <String>[];
      for (final entry in value.entries) {
        result.addAll(_collectTexts(entry.value));
      }
      return result;
    }

    return [value.toString()];
  }

  String _itemDetails(Map<String, dynamic> it) {
    final parts = <String>[];

    final qty =
        it['quantity'] ??
        it['qty'] ??
        it['count'] ??
        it['amount_count'] ??
        it['pieces'];

    if (!_isZeroish(qty)) {
      parts.add('الكمية: ${_v(qty)}');
    }

    for (final key in [
      'details',
      'description',
      'item_details',
      'size',
      'variant',
      'variant_name',
      'type',
    ]) {
      final value = _rawText(it[key]);
      if (value.isNotEmpty) {
        parts.add(value);
      }
    }

    for (final key in [
      'options',
      'addons',
      'extras',
      'attributes',
      'selected_options',
      'toppings',
      'choices',
    ]) {
      final texts = _collectTexts(
        it[key],
      ).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      if (texts.isNotEmpty) {
        final unique = <String>[];
        for (final t in texts) {
          if (!unique.contains(t)) {
            unique.add(t);
          }
        }
        parts.add(unique.join('، '));
      }
    }

    final uniqueParts = <String>[];
    for (final p in parts) {
      final cleaned = p.trim();
      if (cleaned.isEmpty) continue;
      if (!uniqueParts.contains(cleaned)) {
        uniqueParts.add(cleaned);
      }
    }

    return uniqueParts.isEmpty ? 'لا يوجد' : uniqueParts.join('\n');
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final pricing = (order['pricing'] as Map?)?.cast<String, dynamic>() ?? {};

    final totalAny =
        pricing['total_for_driver'] ??
        pricing['total'] ??
        pricing['total_price'];

    final feeAny =
        pricing['delivery_fee'] ??
        pricing['delivery_fee_after'] ??
        pricing['delivery_fee_before'];

    final itemsAny =
        pricing['items_price_for_driver'] ??
        pricing['items_total'] ??
        pricing['items_price'];

    final total = _toDouble(totalAny);
    final fee = _toDouble(feeAny);
    final itemsTotal = _toDouble(itemsAny);

    final restaurantName = _v(restaurant['name'], empty: 'المطعم');

    final orderNote = _v(order['notes'], empty: 'لا يوجد');
    final addressNote = _v(order['address_text'], empty: 'لا يوجد');

    final p1 = restaurantPhones.isNotEmpty ? restaurantPhones[0] : '';
    final p2 = restaurantPhones.length > 1 ? restaurantPhones[1] : '';

    final isInWayMode = !showOrderSection;

    final c = customer ?? const <String, dynamic>{};
    final first = _rawText(c['first_name']);
    final last = _rawText(c['last_name']);
    final fullName = '$first $last'.trim();
    final customerName = fullName.isEmpty ? 'الزبون' : fullName;
    final customerPhone = _v(c['phone'], empty: 'لا يوجد');

    final shouldShowCustomerSection =
        showCustomerInfo ||
        !_isMissingText(customerPhone) ||
        !_isZeroish(itemsTotal) ||
        !_isZeroish(fee) ||
        !_isZeroish(total) ||
        !_isMissingText(addressNote) ||
        customerName != 'الزبون';

    const bottomBarH = 84.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: bottomBarH),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isInWayMode) ...[
                      _RestaurantHeaderCard(
                        name: restaurantName,
                        statusText: statusText,
                        restaurantCalled: restaurantCalled,
                        phone1: _hasPhone(p1) ? p1 : null,
                        phone2: _hasPhone(p2) ? p2 : null,
                        onCall1: onCallRestaurant1,
                        onCall2: onCallRestaurant2,
                      ),
                      _gap(10),
                      ExpandedSection(
                        title: 'الطلب',
                        child: Column(
                          children: [
                            if (items.isNotEmpty)
                              ...items.map(
                                (it) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _MealOrderCard(
                                    title: _itemName(it),
                                    priceText: _itemHasPrice(it)
                                        ? context.syp(_itemPrice(it))
                                        : 'لا يوجد',
                                    detailsText: _itemDetails(it),
                                    noteText: _itemNote(it),
                                  ),
                                ),
                              )
                            else
                              _emptyHint('ليس هناك عناصر'),

                            if (appetizers.isNotEmpty) ...[
                              if (items.isNotEmpty) const SizedBox(height: 2),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'المقبلات',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...appetizers.map(
                                (it) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _MealOrderCard(
                                    title: _itemName(it),
                                    priceText: _itemHasPrice(it)
                                        ? context.syp(_itemPrice(it))
                                        : 'لا يوجد',
                                    detailsText: _itemDetails(it),
                                    noteText: _itemNote(it),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 2),
                            _LabelValueBlock(
                              label: 'ملاحظة الطلب',
                              value: orderNote,
                              icon: Icons.receipt_long_rounded,
                            ),
                          ],
                        ),
                      ),
                      _gap(10),
                    ],

                    if (shouldShowCustomerSection) ...[
                      ExpandedSection(
                        title: 'الزبون',
                        child: _CustomerSummaryCard(
                          name: customerName,
                          phone: customerPhone,
                          itemsPrice: !_isZeroish(itemsTotal)
                              ? context.syp(itemsTotal)
                              : 'لا يوجد',
                          deliveryPrice: !_isZeroish(fee)
                              ? context.syp(fee)
                              : 'لا يوجد',
                          totalPrice: !_isZeroish(total)
                              ? context.syp(total)
                              : 'لا يوجد',
                          locationNote: addressNote,
                          onCall: _isMissingText(customerPhone)
                              ? null
                              : () => _callPhone(customerPhone),
                        ),
                      ),
                    ],

                    if (detailsLoading) ...[
                      _gap(10),
                      Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'يتم التحميل',
                            style: TextStyle(
                              color: Colors.white.withOpacity(.85),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if ((detailsError ?? '').trim().isNotEmpty) ...[
                      _gap(10),
                      _ErrorBox(text: detailsError!.trim(), onRetry: onRetry),
                    ],

                    _gap(10),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomActionBar(
                primaryText: primaryBtnText,
                primaryEnabled: primaryBtnEnabled,
                primaryLoading: primaryLoading,
                onPrimary: onPrimaryPressed,
                onEmergency: onEmergencyPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyHint(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.55),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RestaurantHeaderCard extends StatelessWidget {
  final String name;
  final String statusText;
  final bool restaurantCalled;
  final String? phone1;
  final String? phone2;
  final VoidCallback? onCall1;
  final VoidCallback? onCall2;

  const _RestaurantHeaderCard({
    required this.name,
    required this.statusText,
    required this.restaurantCalled,
    required this.phone1,
    required this.phone2,
    required this.onCall1,
    required this.onCall2,
  });

  @override
  Widget build(BuildContext context) {
    final has1 = phone1 != null && phone1!.trim().isNotEmpty;
    final has2 = phone2 != null && phone2!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              if (restaurantCalled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white.withOpacity(.9),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'تم الاتصال',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.9),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            statusText,
            style: TextStyle(
              color: Colors.white.withOpacity(.75),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          if (has1 || has2) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (has1) ...[
                  _miniActionBtn(
                    icon: Icons.call_rounded,
                    label: '1',
                    onTap: onCall1,
                  ),
                  const SizedBox(width: 8),
                ],
                if (has2) ...[
                  _miniActionBtn(
                    icon: Icons.call_rounded,
                    label: '2',
                    onTap: onCall2,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MealOrderCard extends StatelessWidget {
  final String title;
  final String priceText;
  final String detailsText;
  final String noteText;

  const _MealOrderCard({
    required this.title,
    required this.priceText,
    required this.detailsText,
    required this.noteText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                priceText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _LabelValueBlock(
            label: 'تفاصيل',
            value: detailsText,
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 8),
          _LabelValueBlock(
            label: 'ملاحظات الوجبة',
            value: noteText,
            icon: Icons.sticky_note_2_outlined,
          ),
        ],
      ),
    );
  }
}

class _CustomerSummaryCard extends StatelessWidget {
  final String name;
  final String phone;
  final String itemsPrice;
  final String deliveryPrice;
  final String totalPrice;
  final String locationNote;
  final VoidCallback? onCall;

  const _CustomerSummaryCard({
    required this.name,
    required this.phone,
    required this.itemsPrice,
    required this.deliveryPrice,
    required this.totalPrice,
    required this.locationNote,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = phone.trim().isNotEmpty && phone.trim() != 'لا يوجد';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        phone,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: hasPhone ? onCall : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: hasPhone
                        ? AppTheme.primary.withOpacity(0.18)
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                  child: Icon(
                    Icons.call,
                    color: hasPhone ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          const SizedBox(height: 12),
          _LabelValueBlock(
            label: 'ملاحظات اللوكيشن',
            value: locationNote,
            icon: Icons.location_on_rounded,
          ),
          const SizedBox(height: 12),
          _PriceRow(title: 'سعر الوجبة', value: itemsPrice),
          const SizedBox(height: 8),
          _PriceRow(title: 'سعر التوصيل', value: deliveryPrice),
          const SizedBox(height: 8),
          _PriceRow(title: 'المجموع', value: totalPrice, highlighted: true),
        ],
      ),
    );
  }
}

class _LabelValueBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _LabelValueBlock({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.white.withOpacity(.9)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.78),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.95),
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String title;
  final String value;
  final bool highlighted;

  const _PriceRow({
    required this.title,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? Colors.white : Colors.white.withOpacity(.88);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: highlighted
            ? AppTheme.primary.withOpacity(0.16)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? AppTheme.primary.withOpacity(0.34)
              : Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final String primaryText;
  final bool primaryEnabled;
  final bool primaryLoading;
  final VoidCallback onPrimary;
  final VoidCallback onEmergency;

  const _BottomActionBar({
    required this.primaryText,
    required this.primaryEnabled,
    required this.primaryLoading,
    required this.onPrimary,
    required this.onEmergency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.78),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.10))),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: (primaryEnabled && !primaryLoading) ? onPrimary : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: Colors.white12,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (primaryLoading) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      primaryText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: primaryEnabled ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _miniActionBtn(
            icon: Icons.warning_amber_rounded,
            label: '',
            danger: true,
            onTap: onEmergency,
          ),
        ],
      ),
    );
  }
}

Widget _miniActionBtn({
  required IconData icon,
  required String label,
  required VoidCallback? onTap,
  bool danger = false,
}) {
  final enabled = onTap != null;

  return InkWell(
    onTap: enabled ? onTap : null,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: danger
            ? Colors.redAccent.withOpacity(0.14)
            : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: danger
              ? Colors.redAccent.withOpacity(0.35)
              : Colors.white.withOpacity(0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: enabled
                ? (danger ? Colors.redAccent : Colors.white)
                : Colors.white38,
            size: 20,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.white38,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class ExpandedSection extends StatelessWidget {
  final String title;
  final Widget child;

  const ExpandedSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(.80),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;

  const _ErrorBox({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withOpacity(.24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: onRetry,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
