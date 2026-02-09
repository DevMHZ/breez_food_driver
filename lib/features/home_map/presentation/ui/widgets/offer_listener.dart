import 'package:breez_food_driver/core/widgets/fancy_toast.dart';
import 'package:breez_food_driver/features/offers/presentation/cubit/offers_cubit.dart';
import 'package:breez_food_driver/features/offers/presentation/cubit/offers_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef OfferArrivedCallback = void Function(Map<String, dynamic> offer);

class OfferListener extends StatelessWidget {
  final Widget child;
  final OfferArrivedCallback? onOfferArrived;

  const OfferListener({
    super.key,
    required this.child,
    this.onOfferArrived,
  });

  void _toast(
    BuildContext context,
    String message, {
    bool success = true,
    String? title,
  }) {
    showFancyToast(
      context,
      success: success,
      title: title,
      message: message,
    );
  }

  // ترجمة ذكية لو الرسالة جايّة كمفتاح
  String _trSmart(String textOrKey) {
    final s = (textOrKey).toString().trim();
    if (s.isEmpty) return s;

    final looksLikeKey = s.contains('.') || s.contains('_');
    if (!looksLikeKey) return s;

    final translated = s.tr();
    return translated == s ? s : translated;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OfferCubit, OfferState>(
      listener: (ctx, state) {
        state.whenOrNull(
          received: (offer) {
            // ✅ فقط بلّغ الهوم (بدون bottom sheet / dialog)
            onOfferArrived?.call(offer);
          },
          error: (message, _) {
            _toast(
              ctx,
              _trSmart(message),
              success: false,
              title: "offer.error_title".tr(),
            );
          },
        );
      },
      child: child,
    );
  }
}
