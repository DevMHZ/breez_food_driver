import 'package:breez_food_driver/core/services/price_formatter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppetizerCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const AppetizerCard({super.key, required this.item});

  String _v(dynamic x, {String empty = ""}) {
    if (x == null) return empty;
    final s = x.toString().trim();
    if (s.isEmpty || s.toLowerCase() == "null") return empty;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final ar = _v(item['name_ar']);
    final en = _v(item['name_en']);
    final name = context.locale.languageCode == "ar"
        ? (ar.isNotEmpty ? ar : (en.isNotEmpty ? en : "—"))
        : (en.isNotEmpty ? en : (ar.isNotEmpty ? ar : "—"));

    final qty = (item['quantity'] is num)
        ? (item['quantity'] as num).toInt()
        : int.tryParse("${item['quantity']}") ?? 0;

    final totalText = context.syp(item['total_price']);
    final unitText = context.syp(item['unit_price']);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Row(
        children: [
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
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip("x$qty", bg: Colors.white.withOpacity(.10)),
                    _chip(unitText, bg: Colors.white.withOpacity(.10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            totalText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
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
}
