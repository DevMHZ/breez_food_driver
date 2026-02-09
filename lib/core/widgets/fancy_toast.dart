import 'dart:async';
import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Fancy toast (top overlay) styled to match app theme.
/// - Uses ScreenUtil for sizes only (not text)
/// - Supports stacking multiple toasts (queue).
class FancyToast {
  FancyToast._();

  static final List<OverlayEntry> _entries = [];
  static Timer? _cleanupTimer;

  static void show(
    BuildContext context, {
    required String message,
    bool success = true,
    String? title,
    Duration duration = const Duration(milliseconds: 1800),
  }) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    // ✅ limit stack (avoid infinite overlays)
    if (_entries.length >= 3) {
      _entries.first.remove();
      _entries.removeAt(0);
    }

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _FancyToastOverlay(
        indexFromTop: _entries.length,
        title: title ??
            (success ? "toast.success_title".tr() : "toast.error_title".tr()),
        message: message,
        success: success,
        duration: duration,
        onClose: () => _remove(entry),
      ),
    );

    _entries.add(entry);
    overlay.insert(entry);

    // cleanup timer (in case something stays mounted)
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer(const Duration(seconds: 10), () {
      // ignore
    });
  }

  static void _remove(OverlayEntry entry) {
    if (!entry.mounted) return;
    entry.remove();
    _entries.remove(entry);

    // rebuild remaining entries to update their stack position
    for (final e in _entries) {
      e.markNeedsBuild();
    }
  }

  static void clearAll() {
    for (final e in List<OverlayEntry>.from(_entries)) {
      if (e.mounted) e.remove();
    }
    _entries.clear();
  }
}

/// Backward compatible function name (so you can keep calling showFancyToast).
void showFancyToast(
  BuildContext context, {
  required String message,
  bool success = true,
  String? title,
  Duration duration = const Duration(milliseconds: 1800),
}) {
  FancyToast.show(
    context,
    message: message,
    success: success,
    title: title,
    duration: duration,
  );
}

class _FancyToastOverlay extends StatefulWidget {
  const _FancyToastOverlay({
    required this.indexFromTop,
    required this.title,
    required this.message,
    required this.success,
    required this.duration,
    required this.onClose,
  });

  final int indexFromTop;
  final String title;
  final String message;
  final bool success;
  final Duration duration;
  final VoidCallback onClose;

  @override
  State<_FancyToastOverlay> createState() => _FancyToastOverlayState();
}

class _FancyToastOverlayState extends State<_FancyToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    reverseDuration: const Duration(milliseconds: 180),
  );

  late final Animation<double> _opacity =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -0.12),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
    HapticFeedback.lightImpact();

    // ✅ auto dismiss with animation
    _timer = Timer(widget.duration, () async {
      if (!mounted) return;
      await _ctrl.reverse();
      if (!mounted) return;
      widget.onClose();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Color _accent() => widget.success ? AppTheme.primary : AppTheme.red;

  IconData _icon() =>
      widget.success ? Icons.check_circle_rounded : Icons.error_rounded;

  @override
  Widget build(BuildContext context) {
    final accent = _accent();

    // ✅ stack spacing (top toasts push next ones down)
    final topPadding = (12.h + (widget.indexFromTop * 74.h));

    return IgnorePointer(
      ignoring: false,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: topPadding, left: 14.w, right: 14.w),
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _opacity,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 520.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppTheme.backfilter, // ✅ matches app dark cards
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                          color: Colors.black.withOpacity(.35),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Accent bar
                        Container(
                          width: 4.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        SizedBox(width: 10.w),

                        // Icon bubble
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(.14),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: accent.withOpacity(.22),
                              width: 1,
                            ),
                          ),
                          child: Icon(_icon(), color: accent),
                        ),
                        SizedBox(width: 10.w),

                        // Texts (NO ScreenUtil for text sizes)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14, // ✅ fixed (not .sp)
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                widget.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppTheme.white.withOpacity(.85),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5, // ✅ fixed
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Close
                        InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () async {
                            _timer?.cancel();
                            await _ctrl.reverse();
                            if (!mounted) return;
                            widget.onClose();
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppTheme.white.withOpacity(.75),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
