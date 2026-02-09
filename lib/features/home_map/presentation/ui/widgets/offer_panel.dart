import 'package:flutter/material.dart';
import 'package:breez_food_driver/core/style/app_theme.dart';

class OfferFixedPanel extends StatelessWidget {
  final double height;
  final Widget child;

  const OfferFixedPanel({super.key, required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 14,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: height,
        color: AppTheme.backfilter,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: child,
      ),
    );
  }
}
