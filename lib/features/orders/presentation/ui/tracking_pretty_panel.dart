import 'package:breez_food_driver/core/services/price_formatter.dart';
import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mt;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ui_bits.dart';
import 'item_card.dart';
import 'appetizer_card.dart';

class TrackingPrettyPanel extends StatelessWidget {
  final bool showCustomerInfo;

  final int orderId;
  final String statusText;

  /// Call status (used only for UI/flow)
  final bool restaurantCalled;

  /// Primary loading
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

  // Restaurant phones
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
  });

  // ---------------- helpers ----------------

  bool _isZeroish(dynamic v) {
    if (v == null) return true;
    if (v is num) return v == 0;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == "null") return true;
    final n = num.tryParse(s);
    return n == null || n == 0;
  }

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse("${v ?? ''}".trim()) ?? 0;
  }

  String _v(dynamic x, {String empty = "—"}) {
    if (x == null) return empty;
    final s = x.toString().trim();
    if (s.isEmpty || s.toLowerCase() == "null") return empty;
    return s;
  }

  String _noteText(dynamic x, {String empty = ""}) {
    final s = _v(x, empty: "").trim();
    return s.isEmpty ? empty : s;
  }

  bool _isEmptyText(String s) {
    final t = s.trim();
    return t.isEmpty || t == "—";
  }

  String _itemNote(Map<String, dynamic> it) {
    final raw =
        it['notes'] ??
        it['note'] ??
        it['special_notes'] ??
        it['comment'] ??
        it['instructions'];
    return _v(raw, empty: "").trim();
  }

  String _itemName(Map<String, dynamic> it) {
    final ar = _v(it['name_ar'], empty: "");
    if (ar.isNotEmpty) return ar;
    return _v(it['name_en'], empty: "");
  }

  String _itemsNotesText() {
    final lines = <String>[];
    for (final it in items) {
      final note = _itemNote(it);
      if (note.isEmpty) continue;

      final name = _itemName(it).trim();
      lines.add(name.isEmpty ? note : "$name: $note");
    }
    return lines.isEmpty ? "" : lines.join("\n");
  }

  Widget _gap(double h) => SizedBox(height: h);

  bool _hasPhone(String p) {
    final t = p.trim();
    return t.isNotEmpty && t != "—" && t.toLowerCase() != "null";
  }

  // ---------------- UI ----------------

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

    final restaurantName = _v(restaurant['name'], empty: "المطعم:");

    // Notes
    final itemsNotes = _itemsNotesText();
    final orderNote = _noteText(order['notes']);
    final addressNote = _noteText(order['address_text']);

    final hasAnyNotes =
        !_isEmptyText(itemsNotes) ||
        !_isEmptyText(orderNote) ||
        !_isEmptyText(addressNote);

    final hasItems = items.isNotEmpty;
    final hasAppetizers = appetizers.isNotEmpty;

    // Customer
    final c = (customer ?? const <String, dynamic>{});
    final first = _v(c['first_name'], empty: "").trim();
    final last = _v(c['last_name'], empty: "").trim();

    final customerName = ("$first $last").trim().isEmpty
        ? "الزبون"
        : ("$first $last").trim();
    final customerPhone = _v(c['phone'], empty: "—").trim();
    final canShowCustomerSection = showCustomerInfo && c.isNotEmpty;

    // Restaurant phones (max 2)
    final p1 = restaurantPhones.isNotEmpty ? restaurantPhones[0] : "";
    final p2 = restaurantPhones.length > 1 ? restaurantPhones[1] : "";

    // ✅ bigger to avoid content hidden behind bottom bar
    const bottomBarH = 92.0;

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
            // ================== CONTENT (scroll area) ==================
            Padding(
              padding: const EdgeInsets.only(bottom: bottomBarH),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Header =====
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurantName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.75),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (restaurantCalled) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.10),
                              ),
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
                                  "الأتصال",
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
                      ],
                    ),

                    _gap(10),

                    if (canShowCustomerSection) ...[
                      ExpandedSection(
                        title: "الزبون",
                        child: CustomerCard(
                          name: customerName,
                          phone: customerPhone,
                          onCall:
                              (customerPhone == "—" || customerPhone.isEmpty)
                              ? null
                              : () =>
                                    launchUrl(Uri.parse("tel:$customerPhone")),
                        ),
                      ),
                      _gap(10),
                    ],

                    // ===== ORDER =====
                    ExpandedSection(
                      title: "الطلب",
                      child: Column(
                        children: [
                          if (hasItems)
                            ExpansionCard(
                              title: "العناصر",
                              icon: Icons.receipt_long_outlined,
                              count: items.length,
                              initiallyExpanded: true,
                              child: Column(
                                children: items
                                    .map((it) => ItemCard(item: it))
                                    .toList(),
                              ),
                            )
                          else
                            _emptyHint("ليس هناك عناصر"),

                          if (hasAppetizers) ...[
                            _gap(10),
                            ExpansionCard(
                              title: "المقبلات",
                              icon: Icons.local_dining_outlined,
                              count: appetizers.length,
                              initiallyExpanded: false,
                              child: Column(
                                children: appetizers
                                    .map((it) => AppetizerCard(item: it))
                                    .toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    _gap(10),

                    // ===== NOTES (meal -> order -> address) =====
                    if (hasAnyNotes) ...[
                      ExpandedSection(
                        title: "الملاحظات",
                        child: NotesCompact(
                          itemsNotes: itemsNotes,
                          orderNote: orderNote,
                          addressNote: addressNote,
                        ),
                      ),
                      _gap(10),
                    ],

                    // ===== PRICES =====
                    if (!_isZeroish(total) || !_isZeroish(fee)) ...[
                      ExpandedSection(
                        title: "المجموع",
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    title: "العناصر",
                                    value: context.syp(itemsTotal),
                                    icon: Icons.receipt_long_outlined,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: StatCard(
                                    title: "التوصيل",
                                    value: context.syp(fee),
                                    icon: Icons.motorcycle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            StatCard(
                              title: "المجموع",
                              value: context.syp(total),
                              icon: Icons.payments_outlined,
                            ),
                          ],
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
                            "يتم التحميل",
                            style: TextStyle(
                              color: Colors.white.withOpacity(.85),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (detailsError != null) ...[
                      _gap(10),
                      ErrorBox(text: detailsError!, onRetry: onRetry),
                    ],

                    _gap(10),
                  ],
                ),
              ),
            ),

            // ================== STICKY BOTTOM BAR ==================
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomActionBar(
                primaryText: primaryBtnText,
                primaryEnabled: primaryBtnEnabled,
                primaryLoading: primaryLoading,
                onPrimary: onPrimaryPressed,
                phone1: _hasPhone(p1) ? p1 : null,
                phone2: _hasPhone(p2) ? p2 : null,
                onCall1: onCallRestaurant1,
                onCall2: onCallRestaurant2,
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

// ========================= Bottom Bar =========================

class _BottomActionBar extends StatelessWidget {
  final String primaryText;
  final bool primaryEnabled;
  final bool primaryLoading;
  final VoidCallback onPrimary;

  final String? phone1;
  final String? phone2;
  final VoidCallback? onCall1;
  final VoidCallback? onCall2;

  final VoidCallback onEmergency;

  const _BottomActionBar({
    required this.primaryText,
    required this.primaryEnabled,
    required this.primaryLoading,
    required this.onPrimary,
    required this.phone1,
    required this.phone2,
    required this.onCall1,
    required this.onCall2,
    required this.onEmergency,
  });

  @override
  Widget build(BuildContext context) {
    final has1 = phone1 != null && phone1!.trim().isNotEmpty;
    final has2 = phone2 != null && phone2!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.78),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.10))),
      ),
      child: Row(
        children: [
          // Primary button (big)
          Expanded(
            child: ElevatedButton(
              onPressed: primaryEnabled ? onPrimary : null,
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

          // Call 1 / 2 (ALWAYS allowed, even after send)
          if (has1) ...[
            _miniActionBtn(
              icon: Icons.call_rounded,
              label: "1",
              onTap: onCall1,
            ),
            const SizedBox(width: 8),
          ],
          if (has2) ...[
            _miniActionBtn(
              icon: Icons.call_rounded,
              label: "2",
              onTap: onCall2,
            ),
            const SizedBox(width: 8),
          ],

          // Emergency
          _miniActionBtn(
            icon: Icons.warning_amber_rounded,
            label: "",
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

// ========================= Sections / Cards =========================

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

class CustomerCard extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback? onCall;

  const CustomerCard({
    super.key,
    required this.name,
    required this.phone,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = phone.trim().isNotEmpty && phone.trim() != "—";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
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
                  textDirection: mt.TextDirection.ltr,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
    );
  }
}

// Notes order: meal -> order -> address
class NotesCompact extends StatelessWidget {
  final String itemsNotes;
  final String orderNote;
  final String addressNote;

  const NotesCompact({
    super.key,
    required this.itemsNotes,
    required this.orderNote,
    required this.addressNote,
  });

  bool _isEmpty(String s) {
    final t = s.trim();
    return t.isEmpty || t == "—";
  }

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    if (!_isEmpty(itemsNotes)) {
      rows.add(
        _row(
          "ملاحظة الوجبة",
          itemsNotes,
          Icons.restaurant_menu_rounded,
          multiline: true,
        ),
      );
      rows.add(const SizedBox(height: 8));
    }

    if (!_isEmpty(orderNote)) {
      rows.add(_row("ملاحظة الطلب", orderNote, Icons.receipt_long_rounded));
      rows.add(const SizedBox(height: 8));
    }

    if (!_isEmpty(addressNote)) {
      rows.add(_row("ملاحظة العنوان", addressNote, Icons.location_on_rounded));
      rows.add(const SizedBox(height: 8));
    }

    if (rows.isNotEmpty) rows.removeLast();
    return Column(children: rows);
  }

  Widget _row(
    String title,
    String value,
    IconData icon, {
    bool multiline = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
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
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.78),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: multiline ? 8 : 3,
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
