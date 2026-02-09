import 'package:breez_food_driver/core/services/price_formatter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const ItemCard({super.key, required this.item});

  String _v(dynamic x, {String empty = ""}) {
    if (x == null) return empty;
    final s = x.toString().trim();
    if (s.isEmpty || s.toLowerCase() == "null") return empty;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final qty = (item['quantity'] is num)
        ? (item['quantity'] as num).toInt()
        : int.tryParse("${item['quantity']}") ?? 0;

    final ar = _v(item['name_ar']);
    final en = _v(item['name_en']);
    final title = context.locale.languageCode == "ar"
        ? (ar.isNotEmpty ? ar : (en.isNotEmpty ? en : "—"))
        : (en.isNotEmpty ? en : (ar.isNotEmpty ? ar : "—"));

    final spicy = (item['with_Spicy'] is num)
        ? ((item['with_Spicy'] as num).toInt() == 1)
        : ("${item['with_Spicy']}" == "1");

    final totalText = context.syp(item['total_price']);
    final unitText = context.syp(item['unit_price']);

    final extras = _parseExtras(item['extras'], context.locale.languageCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (spicy) ...[
                const SizedBox(width: 8),
                _chip(context.locale.languageCode == "ar" ? "حار" : "Spicy",
                    bg: Colors.red.withOpacity(.18)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _chip("x$qty", bg: Colors.white.withOpacity(.10)),
              const SizedBox(width: 8),
              _chip(unitText, bg: Colors.white.withOpacity(.10)),
              const Spacer(),
              Text(
                totalText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (extras.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              context.locale.languageCode == "ar" ? "الإضافات" : "Extras",
              style: TextStyle(
                color: Colors.white.withOpacity(.85),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: extras.map((e) {
                final name = e.name;
                final q = e.qty;
                return _chip(q > 1 ? "$name ×$q" : name,
                    bg: Colors.white.withOpacity(.10));
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String text, {required Color bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  List<_ExtraLine> _parseExtras(dynamic raw, String langCode) {
    if (raw is! List) return const [];
    final out = <_ExtraLine>[];

    for (final e in raw) {
      if (e is! Map) continue;
      final m = e.cast<String, dynamic>();

      String pick(dynamic obj) {
        if (obj is Map) {
          final mm = obj.cast<String, dynamic>();
          return _v(mm['name']);
        }
        return _v(obj);
      }

      final ar = pick(m['name_ar']);
      final en = pick(m['name_en']);

      final name = (langCode == "ar")
          ? (ar.isNotEmpty ? ar : en)
          : (en.isNotEmpty ? en : ar);

      final qty = (m['quantity'] is num)
          ? (m['quantity'] as num).toInt()
          : int.tryParse("${m['quantity']}") ?? 1;

      out.add(_ExtraLine(name: name.isEmpty ? "—" : name, qty: qty <= 0 ? 1 : qty));
    }

    return out;
  }
}

class _ExtraLine {
  final String name;
  final int qty;
  const _ExtraLine({required this.name, required this.qty});
}
