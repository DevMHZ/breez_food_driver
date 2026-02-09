
class EarningsResponse {
  final bool status;
  final EarningsData? data;

  EarningsResponse({required this.status, required this.data});

  factory EarningsResponse.fromJson(Map<String, dynamic> json) {
    return EarningsResponse(
      status: json['status'] == true,
      data: json['data'] == null ? null : EarningsData.fromJson(json['data']),
    );
  }
}

class EarningsData {
  final String date; // "2026-01-25"
  final Balances balances;
  final OnlineTime onlineTime;
  final Distance distance;
  final List<EarningsOrderWrap> orders;

  EarningsData({
    required this.date,
    required this.balances,
    required this.onlineTime,
    required this.distance,
    required this.orders,
  });

  factory EarningsData.fromJson(Map<String, dynamic> json) {
    return EarningsData(
      date: (json['date'] ?? '') as String,
      balances: Balances.fromJson(json['balances'] ?? {}),
      onlineTime: OnlineTime.fromJson(json['online_time'] ?? {}),
      distance: Distance.fromJson(json['distance'] ?? {}),
      orders: (json['orders'] as List? ?? [])
          .map((e) => EarningsOrderWrap.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Balances {
  final double order;
  final double delivery;
  final double total;
  final double company;

  Balances({
    required this.order,
    required this.delivery,
    required this.total,
    required this.company,
  });

  factory Balances.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) => (v is num) ? v.toDouble() : 0.0;

    return Balances(
      order: d(json['order']),
      delivery: d(json['delivery']),
      total: d(json['total']),
      company: d(json['company']),
    );
  }
}

class OnlineTime {
  final int seconds;
  final String formatted; // "00h 00m"

  OnlineTime({required this.seconds, required this.formatted});

  factory OnlineTime.fromJson(Map<String, dynamic> json) {
    return OnlineTime(
      seconds: (json['seconds'] is num) ? (json['seconds'] as num).toInt() : 0,
      formatted: (json['formatted'] ?? '00h 00m') as String,
    );
  }
}

class Distance {
  final double km;

  Distance({required this.km});

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(km: (json['km'] is num) ? (json['km'] as num).toDouble() : 0);
  }
}

class EarningsOrderWrap {
  final OrderMini order;
  final DriverMini driver;
  final RestaurantMini? restaurant; // ✅ optional
  final List<TimelineItem> timeline; // ✅ optional (بس رح نخليها لست فاضية)
  final List<OrderItemMini> items;

  EarningsOrderWrap({
    required this.order,
    required this.driver,
    required this.restaurant,
    required this.timeline,
    required this.items,
  });

  factory EarningsOrderWrap.fromJson(Map<String, dynamic> json) {
    final restMap = json['restaurant'];
    return EarningsOrderWrap(
      order: OrderMini.fromJson(_m(json['order'])),
      driver: DriverMini.fromJson(_m(json['driver'])),
      restaurant: restMap is Map ? RestaurantMini.fromJson(_m(restMap)) : null,
      timeline: _l(json['timeline'])
          .map((e) => TimelineItem.fromJson(_m(e)))
          .toList(),
      items: _l(json['items'])
          .map((e) => OrderItemMini.fromJson(_m(e)))
          .toList(),
    );
  }
}


class OrderMini {
  final int id;
  final String status;
  final int orderCustomerCode;
  final double itemsTotal;
  final double deliveryFee;
  final double totalPrice;
  final String paymentMethod;
  final String paymentStatus;
  final String? notes;
  final String createdAt; // "2026-01-25T21:03:45+00:00"

  OrderMini({
    required this.id,
    required this.status,
    required this.orderCustomerCode,
    required this.itemsTotal,
    required this.deliveryFee,
    required this.totalPrice,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.notes,
    required this.createdAt,
  });

  factory OrderMini.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) => (v is num) ? v.toDouble() : 0.0;

    return OrderMini(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      status: (json['status'] ?? '') as String,
      orderCustomerCode: (json['order_customer_code'] is num)
          ? (json['order_customer_code'] as num).toInt()
          : 0,
      itemsTotal: d(json['items_total']),
      deliveryFee: d(json['delivery_fee']),
      totalPrice: d(json['total_price']),
      paymentMethod: (json['payment_method'] ?? '') as String,
      paymentStatus: (json['payment_status'] ?? '') as String,
      notes: json['notes'] as String?,
      createdAt: (json['created_at'] ?? '') as String,
    );
  }
}

class DriverMini {
  final int id;
  final String name;
  final String phone;
  final String profileImage;

  DriverMini({
    required this.id,
    required this.name,
    required this.phone,
    required this.profileImage,
  });

  String get profileImageUrl => _fullUrl(profileImage);

  factory DriverMini.fromJson(Map<String, dynamic> json) {
    return DriverMini(
      id: _i(json['id']),
      name: _s(json['name']),
      phone: _s(json['phone']),
      profileImage: _s(json['profile_image']),
    );
  }
}

class RestaurantMini {
  final int id;
  final String name;
  final String logo;

  RestaurantMini({required this.id, required this.name, required this.logo});

  String get logoUrl => _fullUrl(logo);

  factory RestaurantMini.fromJson(Map<String, dynamic> json) {
    return RestaurantMini(
      id: _i(json['id']),
      name: _s(json['name']),
      logo: _s(json['logo']),
    );
  }
}




class TimelineItem {
  final String key;
  final String? time;

  TimelineItem({required this.key, required this.time});

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      key: (json['key'] ?? '') as String,
      time: json['time'] as String?,
    );
  }
}

class OrderItemMini {
  final int id;
  final int menuItemId;
  final String nameAr;
  final String nameEn;
  final int quantity;
  final int withSpicy;
  final double totalPrice;
  final String image;
  final int deliveryTime;

  OrderItemMini({
    required this.id,
    required this.menuItemId,
    required this.nameAr,
    required this.nameEn,
    required this.quantity,
    required this.withSpicy,
    required this.totalPrice,
    required this.image,
    required this.deliveryTime,
  });

  String get imageUrl => _fullUrl(image);

  factory OrderItemMini.fromJson(Map<String, dynamic> json) {
    return OrderItemMini(
      id: _i(json['id']),
      menuItemId: _i(json['menu_item_id']),
      nameAr: _s(json['name_ar']),
      nameEn: _s(json['name_en']),
      quantity: _i(json['quantity']),
      withSpicy: _i(json['with_spicy']), // ✅ نفس اللي بالريسبونس
      totalPrice: _d(json['total_price']),
      image: _s(json['image']),
      deliveryTime: _i(json['delivery_time']),
    );
  }
}

const String kBaseUrl = "https://breezefood.cloud";

String _fullUrl(String? path) {
  final p = (path ?? "").trim();
  if (p.isEmpty) return "";
  if (p.startsWith("http://") || p.startsWith("https://")) return p;
  if (p.startsWith("/")) return "$kBaseUrl$p";
  return "$kBaseUrl/$p";
}

double _d(dynamic v) => (v is num) ? v.toDouble() : double.tryParse("$v") ?? 0.0;
int _i(dynamic v) => (v is num) ? v.toInt() : int.tryParse("$v") ?? 0;
String _s(dynamic v) => (v ?? "").toString();
Map<String, dynamic> _m(dynamic v) => (v is Map) ? v.cast<String, dynamic>() : <String, dynamic>{};
List _l(dynamic v) => (v is List) ? v : const [];
