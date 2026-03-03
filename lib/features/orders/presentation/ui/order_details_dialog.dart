import 'dart:async';

import 'package:breez_food_driver/core/services/price_formatter.dart';
import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OrderDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> offerData;
  final Future<void> Function() onAccept;
  final Future<void> Function() onDecline;

  const OrderDetailsDialog({
    super.key,
    required this.offerData,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<OrderDetailsDialog> {
  static const int kOfferTtlSeconds = 30;
  static const int _tickMs = 100;

  Timer? _timer;
  bool _ended = false;

  int _remainingSeconds = kOfferTtlSeconds;
  double _progress = 1.0;

  int? _expiresAtMs;
  int _serverOffsetMs = 0;

  @override
  void initState() {
    super.initState();
    _setupTiming();
    _startTimer();
  }

  bool _isZeroish(dynamic v) {
    if (v == null) return true;
    if (v is num) return v == 0;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == "null") return true;
    final n = num.tryParse(s);
    return n == null || n == 0;
  }

  void _setupTiming() {
    final expiresRaw = widget.offerData['expires_at_ms'];
    final serverRaw = widget.offerData['server_time_ms'];
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    if (serverRaw is num) {
      _serverOffsetMs = serverRaw.toInt() - nowMs;
    } else {
      _serverOffsetMs = 0;
    }

    if (expiresRaw is num && expiresRaw.toInt() > 0) {
      _expiresAtMs = expiresRaw.toInt();
    } else if (serverRaw is num) {
      _expiresAtMs = serverRaw.toInt() + kOfferTtlSeconds * 1000;
    } else {
      _expiresAtMs = nowMs + kOfferTtlSeconds * 1000;
    }

    _remainingSeconds = kOfferTtlSeconds;
    _progress = 1.0;
  }

  int _serverNowMs() => DateTime.now().millisecondsSinceEpoch + _serverOffsetMs;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: _tickMs), (_) {
      if (_ended) return;

      final expiresAt = _expiresAtMs;
      if (expiresAt == null) return;

      final remainMs = expiresAt - _serverNowMs();
      final maxMs = kOfferTtlSeconds * 1000;
      final clampedMs = remainMs.clamp(0, maxMs);

      final newProgress = (clampedMs / maxMs).toDouble();
      final newSec = (clampedMs / 1000).ceil().clamp(0, kOfferTtlSeconds);

      if (!mounted) return;

      if (newSec != _remainingSeconds || newProgress != _progress) {
        setState(() {
          _remainingSeconds = newSec;
          _progress = newProgress;
        });
      }

      if (newSec <= 0) {
        _autoDecline();
      }
    });
  }

  // ✅ لا تنتظر الشبكة هون، الأب لحاله بسكّر UI وبيوقف الصوت فوراً
  void _autoDecline() {
    if (_ended) return;
    _ended = true;
    _timer?.cancel();

    if (mounted) setState(() {});

    unawaited(() async {
      try {
        await widget.onDecline();
      } catch (_) {}
    }());
  }

  void _manualDecline() {
    if (_ended) return;
    _ended = true;
    _timer?.cancel();

    if (mounted) setState(() {});

    unawaited(() async {
      try {
        await widget.onDecline();
      } catch (_) {}
    }());
  }

  void _manualAccept() {
    if (_ended) return;
    _ended = true;
    _timer?.cancel();

    if (mounted) setState(() {});

    unawaited(() async {
      try {
        await widget.onAccept();
      } catch (_) {}
    }());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Offer envelope fields
    final isVip = widget.offerData['is_vip'] == true;
    // ignore: unused_local_variable
    final offerId = (widget.offerData['offer_id'] ?? '').toString();

    final order =
        (widget.offerData['order'] as Map?)?.cast<String, dynamic>() ?? {};
    final restaurant =
        (order['restaurant'] as Map?)?.cast<String, dynamic>() ?? {};

    final restaurantName =
        (restaurant['name']?.toString().trim().isNotEmpty ?? false)
        ? restaurant['name'].toString()
        : "common.restaurant".tr();

    final deliveryFee = order['delivery_fee'];
    final feeText = MoneyFormatter.formatSyp(
      context,
      deliveryFee,
      withSymbol: true,
      decimals: 0,
    );

    final progress = _progress.clamp(0.0, 1.0);
    final danger = _remainingSeconds <= 10;

    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Text(
                restaurantName.isNotEmpty ? restaurantName[0] : "?",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isVip) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.amber.withOpacity(.35),
                            ),
                          ),
                          child: Text(
                            "VIP",
                            style: TextStyle(
                              color: Colors.amber.withOpacity(.95),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!_isZeroish(deliveryFee))
                    Text(
                      "offer.delivery_fee".tr(namedArgs: {"fee": feeText}),
                      style: TextStyle(color: Colors.grey[300], fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                "offer.time_remaining".tr(
                  namedArgs: {"sec": _remainingSeconds.toString()},
                ),
                style: TextStyle(
                  color: danger ? AppTheme.red : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                minHeight: 8,
                value: value,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  danger ? AppTheme.red : AppTheme.primary,
                ),
              );
            },
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _ended ? null : _manualDecline,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                ),
                child: Text("offer.decline".tr()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _ended ? null : _manualAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                ),
                child: Text(
                  "offer.accept".tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
