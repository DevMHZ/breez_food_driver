import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

mixin TrackingHelpers<T extends StatefulWidget> on State<T> {
  String trSafe(
    String key, {
    required String fallback,
    Map<String, String>? namedArgs,
  }) {
    try {
      final t = key.tr(namedArgs: namedArgs);
      if (t == key) return fallback;
      return t;
    } catch (_) {
      return fallback;
    }
  }

  String v(dynamic x, {String empty = "—"}) {
    if (x == null) return empty;
    final s = x.toString().trim();
    if (s.isEmpty || s.toLowerCase() == "null") return empty;
    return s;
  }

  String vn(dynamic x, {String empty = "—"}) {
    if (x == null) return empty;
    if (x is num) return x.toString();
    final s = x.toString().trim();
    if (s.isEmpty || s.toLowerCase() == "null") return empty;
    return s;
  }

  String money(dynamic x, {String currency = "SYP", String empty = "—"}) {
    if (x == null) return empty;
    if (x is num) return "${x.toStringAsFixed(0)} $currency";
    final n = num.tryParse(x.toString());
    if (n == null) return empty;
    return "${n.toStringAsFixed(0)} $currency";
  }

  String trSmart(String textOrKey) {
    final s = (textOrKey).trim();
    if (s.isEmpty) return s;
    final looksLikeKey = s.contains('.') || s.contains('_');
    if (!looksLikeKey) return s;
    final translated = s.tr();
    if (translated == s) return s;
    return translated;
  }
}
