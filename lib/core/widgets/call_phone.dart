import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:breez_food_driver/core/widgets/fancy_toast.dart';

Future<void> callPhone(BuildContext context, String? phone) async {
  final p = (phone ?? '').trim();
  if (p.isEmpty) {
    showFancyToast(
      context,
      message: "common.phone_missing".tr(),
      success: false,
      title: "toast.error_title".tr(),
    );
    return;
  }

  final uri = Uri(scheme: 'tel', path: p);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    showFancyToast(
      context,
      message: "common.call_failed".tr(),
      success: false,
      title: "toast.error_title".tr(),
    );
  }
}
