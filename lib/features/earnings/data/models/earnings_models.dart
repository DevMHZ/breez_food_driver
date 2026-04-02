class EarningsOverviewResponse {
  final bool status;
  final String message;
  final EarningsOverviewData? data;

  const EarningsOverviewResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EarningsOverviewResponse.fromJson(Map<String, dynamic> json) {
    return EarningsOverviewResponse(
      status: _b(json['status']),
      message: _s(json['message']),
      data: json['data'] is Map<String, dynamic>
          ? EarningsOverviewData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class EarningsOverviewData {
  final String date;
  final double currentBalance;
  final double todayEarnings;
  final EarningsOrdersStats ordersStats;
  final double totalDistance;
  final List<EarningsByHourPoint> earningsByHour;

  const EarningsOverviewData({
    required this.date,
    required this.currentBalance,
    required this.todayEarnings,
    required this.ordersStats,
    required this.totalDistance,
    required this.earningsByHour,
  });

  factory EarningsOverviewData.fromJson(Map<String, dynamic> json) {
    return EarningsOverviewData(
      date: _s(json['date']),
      currentBalance: _d(json['current_balance']),
      todayEarnings: _d(json['today_earnings']),
      ordersStats: EarningsOrdersStats.fromJson(_m(json['orders_stats'])),
      totalDistance: _d(json['total_distance']),
      earningsByHour: EarningsByHourPoint.parseList(json['earnings_by_hour']),
    );
  }
}

class EarningsByHourPoint {
  final int hour;
  final String label;
  final double amount;
  final int ordersCount;

  const EarningsByHourPoint({
    required this.hour,
    required this.label,
    required this.amount,
    required this.ordersCount,
  });

  factory EarningsByHourPoint.fromJson(
    Map<String, dynamic> json, {
    String? fallbackHourKey,
  }) {
    final rawHour = _firstNonEmpty([
      json['hour'],
      json['time'],
      json['label'],
      json['hour_label'],
      fallbackHourKey,
    ]);

    final parsedHour = _parseHour(rawHour);

    return EarningsByHourPoint(
      hour: parsedHour,
      label: _formatHourLabel(parsedHour),
      amount: _d(
        _pickFirst(json, const [
          'amount',
          'value',
          'earning',
          'earnings',
          'total',
        ]),
      ),
      ordersCount: _i(
        _pickFirst(json, const ['orders_count', 'count', 'orders']),
      ),
    );
  }

  static List<EarningsByHourPoint> parseList(dynamic raw) {
    final items = <EarningsByHourPoint>[];

    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          items.add(
            EarningsByHourPoint.fromJson(
              value,
              fallbackHourKey: key.toString(),
            ),
          );
        } else if (value is Map) {
          items.add(
            EarningsByHourPoint.fromJson(
              value.cast<String, dynamic>(),
              fallbackHourKey: key.toString(),
            ),
          );
        }
      });
    } else if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          items.add(EarningsByHourPoint.fromJson(item));
        } else if (item is Map) {
          items.add(EarningsByHourPoint.fromJson(item.cast<String, dynamic>()));
        }
      }
    }

    items.sort((a, b) => a.hour.compareTo(b.hour));

    final mapByHour = <int, EarningsByHourPoint>{
      for (final item in items) item.hour: item,
    };

    return List.generate(24, (hour) {
      return mapByHour[hour] ??
          EarningsByHourPoint(
            hour: hour,
            label: _formatHourLabel(hour),
            amount: 0,
            ordersCount: 0,
          );
    });
  }

  static int _parseHour(String value) {
    final match = RegExp(r'^(\d{1,2})').firstMatch(value.trim());
    final parsed = int.tryParse(match?.group(1) ?? '') ?? 0;
    return parsed.clamp(0, 23);
  }

  static String _formatHourLabel(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }
}

class EarningsOrdersResponse {
  final bool status;
  final String message;
  final EarningsOrdersData? data;

  const EarningsOrdersResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EarningsOrdersResponse.fromJson(Map<String, dynamic> json) {
    return EarningsOrdersResponse(
      status: _b(json['status']),
      message: _s(json['message']),
      data: json['data'] is Map<String, dynamic>
          ? EarningsOrdersData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class EarningsOrdersData {
  final String date;
  final String filterType;
  final EarningsOrdersFilterStats stats;
  final List<EarningsOrderItem> orders;

  const EarningsOrdersData({
    required this.date,
    required this.filterType,
    required this.stats,
    required this.orders,
  });

  factory EarningsOrdersData.fromJson(Map<String, dynamic> json) {
    return EarningsOrdersData(
      date: _s(json['date']),
      filterType: _s(json['filter_type']),
      stats: EarningsOrdersFilterStats.fromJson(_m(json['stats'])),
      orders: _l(
        json['orders'],
      ).map((e) => EarningsOrderItem.fromJson(_m(e))).toList(),
    );
  }
}

class EarningsOrdersFilterStats {
  final int totalCount;
  final int regularCount;
  final int vipCount;
  final double totalEarnings;

  const EarningsOrdersFilterStats({
    required this.totalCount,
    required this.regularCount,
    required this.vipCount,
    required this.totalEarnings,
  });

  factory EarningsOrdersFilterStats.fromJson(Map<String, dynamic> json) {
    return EarningsOrdersFilterStats(
      totalCount: _i(json['total_count']),
      regularCount: _i(json['regular_count']),
      vipCount: _i(json['vip_count']),
      totalEarnings: _d(json['total_earnings']),
    );
  }
}

class EarningsOrderTimestamps {
  final String createdAt;
  final String deliveredAt;

  const EarningsOrderTimestamps({
    required this.createdAt,
    required this.deliveredAt,
  });

  const EarningsOrderTimestamps.empty()
      : createdAt = '',
        deliveredAt = '';

  bool get hasCreatedAt => createdAt.trim().isNotEmpty;
  bool get hasDeliveredAt => deliveredAt.trim().isNotEmpty;

  factory EarningsOrderTimestamps.fromJson(
    Map<String, dynamic> json, {
    String fallbackCreatedAt = '',
    String fallbackDeliveredAt = '',
  }) {
    if (json.isEmpty &&
        fallbackCreatedAt.trim().isEmpty &&
        fallbackDeliveredAt.trim().isEmpty) {
      return const EarningsOrderTimestamps.empty();
    }

    return EarningsOrderTimestamps(
      createdAt: _firstNonEmpty([
        json['created_at'],
        json['createdAt'],
        json['created'],
        fallbackCreatedAt,
      ]),
      deliveredAt: _firstNonEmpty([
        json['delivered_at'],
        json['deliveredAt'],
        json['delivered'],
        fallbackDeliveredAt,
      ]),
    );
  }
}

class EarningsOrderItem {
  final int id;
  final String orderNumber;
  final String restaurantName;
  final String restaurantLogo;
  final double distanceKm;
  final double customerAmount;
  final double driverEarning;
  final double companyFromRestaurant;
  final double vipPrice;
  final bool isVip;
  final String deliveryTo;
  final String customerImage;
  final String note;
  final EarningsOrderTimestamps timestamps;

  const EarningsOrderItem({
    required this.id,
    required this.orderNumber,
    required this.restaurantName,
    required this.restaurantLogo,
    required this.distanceKm,
    required this.customerAmount,
    required this.driverEarning,
    required this.companyFromRestaurant,
    required this.vipPrice,
    required this.isVip,
    required this.deliveryTo,
    required this.customerImage,
    required this.note,
    required this.timestamps,
  });

  String get restaurantLogoUrl => _fullUrl(restaurantLogo);
  String get customerImageUrl => _fullUrl(customerImage);

  String get createdAt => timestamps.createdAt;
  String get deliveredAt => timestamps.deliveredAt;

  bool get hasCreatedAt => timestamps.hasCreatedAt;
  bool get hasDeliveredAt => timestamps.hasDeliveredAt;

  factory EarningsOrderItem.fromJson(Map<String, dynamic> json) {
    final order = _nestedMap(json, 'order');
    final restaurant = _nestedMap(json, 'restaurant');
    final customer = _nestedMap(json, 'customer');
    final delivery = _nestedMap(json, 'delivery');
    final amounts = _nestedMap(json, 'amounts');
    final timestampsJson = _nestedMap(json, 'timestamps');

    final vipValue = _d(
      _pickFirstDeep(json, amounts, const [
        'vip_price',
        'vip_amount',
        'vip_total',
        'vip_fee',
      ]),
    );

    return EarningsOrderItem(
      id: _i(_pickFirstDeep(json, order, const ['id', 'order_id'])),
      orderNumber: _firstNonEmpty([
        _pickFirstDeep(json, order, const [
          'order_number',
          'order_customer_code',
          'customer_code',
          'code',
          'number',
        ]),
        _i(_pickFirstDeep(json, order, const ['id', 'order_id'])).toString(),
      ]),
      restaurantName: _firstNonEmpty([
        _pickFirstDeep(json, restaurant, const ['restaurant_name', 'name']),
      ]),
      restaurantLogo: _firstNonEmpty([
        _pickFirstDeep(json, restaurant, const [
          'restaurant_logo',
          'logo',
          'image',
        ]),
      ]),
      distanceKm: _d(
        _pickFirstDeep(json, order, const [
          'distance_km',
          'distance',
          'km',
        ]),
      ),
      customerAmount: _d(
        _pickFirstDeep(json, amounts, const [
          'customer_amount',
          'amount_from_customer',
          'amount_collected',
          'cash_from_customer',
          'order_total',
          'customer_paid',
        ]),
      ),
      driverEarning: _d(
        _pickFirstDeep(json, amounts, const [
          'driver_earning',
          'driver_profit',
          'driver_total',
          'delivery_fee',
          'driver_amount',
        ]),
      ),
      companyFromRestaurant: _d(
        _pickFirstDeep(json, amounts, const [
          'company_from_restaurant',
          'restaurant_commission',
          'company_restaurant_commission',
          'company_share_from_restaurant',
          'app_commission_food',
        ]),
      ),
      vipPrice: vipValue,
      isVip: _isVip(json, order) || vipValue > 0,
      deliveryTo: _firstNonEmpty([
        _pickFirstDeep(json, delivery, const [
          'delivery_to',
          'delivery_address',
          'address_label',
        ]),
        _pickFirstDeep(json, customer, const ['name', 'full_name']),
      ]),
      customerImage: _firstNonEmpty([
        _pickFirstDeep(json, customer, const [
          'image',
          'avatar',
          'profile_image',
        ]),
      ]),
      note: _firstNonEmpty([
        json['note'],
        json['notes'],
        order['note'],
        order['notes'],
      ]),
      timestamps: EarningsOrderTimestamps.fromJson(
        timestampsJson,
        fallbackCreatedAt: _firstNonEmpty([
          _pickFirstDeep(json, order, const ['created_at', 'date', 'time']),
          json['created_at'],
        ]),
        fallbackDeliveredAt: _firstNonEmpty([
          _pickFirstDeep(json, order, const ['delivered_at']),
          json['delivered_at'],
        ]),
      ),
    );
  }
}

class EarningsFinancialDetailsResponse {
  final bool status;
  final String message;
  final EarningsFinancialDetailsData? data;

  const EarningsFinancialDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EarningsFinancialDetailsResponse.fromJson(Map<String, dynamic> json) {
    return EarningsFinancialDetailsResponse(
      status: _b(json['status']),
      message: _s(json['message']),
      data: json['data'] is Map<String, dynamic>
          ? EarningsFinancialDetailsData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class EarningsFinancialDetailsData {
  final String date;
  final double currentBalance;
  final EarningsOrdersStats ordersStats;
  final EarningsAmountsByType amountsByType;
  final EarningsDriverTotals earnings;
  final EarningsCommissions commissions;
  final EarningsAdminFees adminFees;
  final EarningsTransactions transactions;

  const EarningsFinancialDetailsData({
    required this.date,
    required this.currentBalance,
    required this.ordersStats,
    required this.amountsByType,
    required this.earnings,
    required this.commissions,
    required this.adminFees,
    required this.transactions,
  });

  factory EarningsFinancialDetailsData.fromJson(Map<String, dynamic> json) {
    return EarningsFinancialDetailsData(
      date: _s(json['date']),
      currentBalance: _d(json['current_balance']),
      ordersStats: EarningsOrdersStats.fromJson(_m(json['orders_stats'])),
      amountsByType: EarningsAmountsByType.fromJson(
        _m(json['amounts_by_type']),
      ),
      earnings: EarningsDriverTotals.fromJson(_m(json['earnings'])),
      commissions: EarningsCommissions.fromJson(_m(json['commissions'])),
      adminFees: EarningsAdminFees.fromJson(_m(json['admin_fees'])),
      transactions: EarningsTransactions.fromJson(_m(json['transactions'])),
    );
  }
}

class EarningsOrdersStats {
  final int total;
  final int regular;
  final int vip;

  const EarningsOrdersStats({
    required this.total,
    required this.regular,
    required this.vip,
  });

  factory EarningsOrdersStats.fromJson(Map<String, dynamic> json) {
    return EarningsOrdersStats(
      total: _i(json['total']),
      regular: _i(json['regular']),
      vip: _i(json['vip']),
    );
  }
}
class EarningsAmountsByType {
  final double regularTotal;
  final double vipTotal;
  final double grandTotal;

  const EarningsAmountsByType({
    required this.regularTotal,
    required this.vipTotal,
    required this.grandTotal,
  });

  factory EarningsAmountsByType.fromJson(Map<String, dynamic> json) {
    return EarningsAmountsByType(
      regularTotal: _d(json['regular_total']),
      vipTotal: _d(json['vip_total']),
      grandTotal: _d(json['grand_total']),
    );
  }
}

class EarningsDriverTotals {
  final double driverTotal;

  const EarningsDriverTotals({required this.driverTotal});

  factory EarningsDriverTotals.fromJson(Map<String, dynamic> json) {
    return EarningsDriverTotals(driverTotal: _d(json['driver_total']));
  }
}

class EarningsCommissions {
  final double companyFromRestaurants;
  final double companyFromDrivers;

  const EarningsCommissions({
    required this.companyFromRestaurants,
    required this.companyFromDrivers,
  });

  factory EarningsCommissions.fromJson(Map<String, dynamic> json) {
    return EarningsCommissions(
      companyFromRestaurants: _d(json['company_from_restaurants']),
      companyFromDrivers: _d(json['company_from_drivers']),
    );
  }
}

class EarningsAdminFees {
  final double fromRegular;
  final double fromVip;

  const EarningsAdminFees({required this.fromRegular, required this.fromVip});

  factory EarningsAdminFees.fromJson(Map<String, dynamic> json) {
    return EarningsAdminFees(
      fromRegular: _d(json['from_regular']),
      fromVip: _d(json['from_vip']),
    );
  }
}

class EarningsTransactions {
  final double pendingAmount;
  final double paidAmount;
  final double remaining;

  const EarningsTransactions({
    required this.pendingAmount,
    required this.paidAmount,
    required this.remaining,
  });

  factory EarningsTransactions.fromJson(Map<String, dynamic> json) {
    return EarningsTransactions(
      pendingAmount: _d(json['pending_amount']),
      paidAmount: _d(json['paid_amount']),
      remaining: _d(json['remaining']),
    );
  }
}

const String kBreezeBaseUrl = 'https://breezefood.cloud';

String _fullUrl(String? path) {
  final clean = _s(path).trim();
  if (clean.isEmpty) return '';
  if (clean.startsWith('http://') || clean.startsWith('https://')) {
    return clean;
  }
  if (clean.startsWith('/')) {
    return '$kBreezeBaseUrl$clean';
  }
  return '$kBreezeBaseUrl/$clean';
}

bool _b(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = _s(value).toLowerCase();
  return text == 'true' || text == '1' || text == 'yes';
}

double _d(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(_s(value).replaceAll(',', '')) ?? 0.0;
}

int _i(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(_s(value)) ?? 0;
}

String _s(dynamic value) => value?.toString() ?? '';

Map<String, dynamic> _m(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return <String, dynamic>{};
}

List<dynamic> _l(dynamic value) => value is List ? value : const <dynamic>[];

String _firstNonEmpty(List<dynamic> values) {
  for (final value in values) {
    final text = _s(value).trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

dynamic _pickFirst(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key) && json[key] != null) {
      return json[key];
    }
  }
  return null;
}

dynamic _pickFirstDeep(
  Map<String, dynamic> primary,
  Map<String, dynamic> secondary,
  List<String> keys,
) {
  final primaryValue = _pickFirst(primary, keys);
  if (primaryValue != null && _s(primaryValue).isNotEmpty) return primaryValue;
  return _pickFirst(secondary, keys);
}

Map<String, dynamic> _nestedMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  return _m(value);
}

bool _isVip(Map<String, dynamic> json, Map<String, dynamic> order) {
  final raw = _pickFirstDeep(json, order, const [
    'is_vip',
    'vip',
    'order_type',
    'type',
    'category',
  ]);

  if (raw is bool) return raw;
  if (raw is num) return raw == 1;

  final text = _s(raw).toLowerCase();
  return text == 'vip';
}
