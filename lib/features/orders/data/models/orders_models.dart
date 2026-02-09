class DriverOrderDetails {
  final Map<String, dynamic> order;
  final Map<String, dynamic> restaurant;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> appetizers;
  final Map<String, dynamic> customer; // ✅ جديد
  DriverOrderDetails({
    required this.order,
    required this.restaurant,
    required this.items,
    required this.appetizers,
    required this.customer,
  });
  // ✅ Order Note
  String get orderNote => v(order['notes'], empty: "لا يوجد");

  // ✅ Address Note
  String get addressNote => v(order['address_text'], empty: "لا يوجد");

  // ✅ Meal notes (يجمع ملاحظات الوجبات الموجودة فقط)
  List<String> get itemsNotesLines {
    final out = <String>[];

    for (final it in items) {
      final name = v(it['name_ar'], empty: "").isNotEmpty
          ? v(it['name_ar'], empty: "")
          : v(it['name_en'], empty: "");

      final note =
          it['notes'] ??
          it['note'] ??
          it['special_notes'] ??
          it['comment'] ??
          it['instructions'];

      final noteStr = v(note, empty: "");

      if (noteStr.isNotEmpty && noteStr != "لا يوجد" && noteStr != "لا يوجد") {
        out.add(name.isEmpty ? noteStr : "$name: $noteStr");
      }
    }

    return out;
  }

  String get itemsNotesText {
    final lines = itemsNotesLines;
    return lines.isEmpty ? "لا يوجد" : lines.join("\n");
  }

  String get customerName {
    final first = (customer['first_name'] ?? '').toString().trim();
    final last = (customer['last_name'] ?? '').toString().trim();
    final full = "$first $last".trim();
    return full.isEmpty ? "زبون" : full;
  }

  String get customerPhone => (customer['phone'] ?? '').toString().trim();
  String get status => (order['status'] ?? '').toString().trim();
  factory DriverOrderDetails.fromJson(Map<String, dynamic> json) {
    return DriverOrderDetails(
      customer: (json['customer'] as Map?)?.cast<String, dynamic>() ?? {}, // ✅
      order: (json['order'] as Map?)?.cast<String, dynamic>() ?? {},
      restaurant: (json['restaurant'] as Map?)?.cast<String, dynamic>() ?? {},
      items:
          (json['items'] as List?)
              ?.map((e) => (e as Map).cast<String, dynamic>())
              .toList() ??
          const [],
      appetizers:
          (json['appetizers'] as List?)
              ?.map((e) => (e as Map).cast<String, dynamic>())
              .toList() ??
          const [],
    );
  }

  int get orderId {
    final id = order['id'];
    if (id is num) return id.toInt();
    return int.tryParse("$id") ?? 0;
  }

  String get restaurantName => (restaurant['name'] ?? '').toString().trim();
  String get restaurantPhone => (restaurant['phone'] ?? '').toString().trim();
  String get restaurantPhone2 => (restaurant['phone2'] ?? '').toString().trim();
  bool get hasRestaurantPhone2 => restaurantPhone2.isNotEmpty;
  Map<String, dynamic> get pricing =>
      (order['pricing'] as Map?)?.cast<String, dynamic>() ?? {};
  List<String> get restaurantPhones {
    final out = <String>[];
    final p1 = restaurantPhone;
    final p2 = restaurantPhone2;

    if (p1.isNotEmpty) out.add(p1);
    if (p2.isNotEmpty && p2 != p1) out.add(p2);

    return out;
  }

  double get total {
    final t = pricing['total'];
    if (t is num) return t.toDouble();
    return double.tryParse("$t") ?? 0;
  }

  double get deliveryFee {
    final d = pricing['delivery_fee_after'] ?? pricing['delivery_fee_before'];
    if (d is num) return d.toDouble();
    return double.tryParse("$d") ?? 0;
  }
}

String v(dynamic x, {String empty = "لا يوجد"}) {
  if (x == null) return empty;
  final s = x.toString().trim();
  if (s.isEmpty || s.toLowerCase() == "null") return empty;
  return s;
}

String vn(dynamic x, {String empty = "لا يوجد"}) {
  // للأرقام
  if (x == null) return empty;
  if (x is num) return x.toString();
  final s = x.toString().trim();
  if (s.isEmpty || s.toLowerCase() == "null") return empty;
  return s;
}

String money(dynamic x, {String currency = "SYP", String empty = "لا يوجد"}) {
  if (x == null) return empty;
  if (x is num) return "${x.toStringAsFixed(0)} $currency";
  final n = num.tryParse(x.toString());
  if (n == null) return empty;
  return "${n.toStringAsFixed(0)} $currency";
}
