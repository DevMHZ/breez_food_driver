import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeBottomBar extends StatelessWidget {
  final bool isOnline;
  final bool isConnected; // ✅ جديد
  final bool isSearching; // ✅ جديد
  final bool hasOffer;
  final bool isBusy;
  final VoidCallback onToggle;
  final VoidCallback? onMenuTap;

  const HomeBottomBar({
    super.key,
    required this.isOnline,
    required this.isConnected,
    required this.isSearching,
    required this.hasOffer,
    required this.isBusy,
    required this.onToggle,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    final meta = _statusMeta(
      isOnline: isOnline,
      isConnected: isConnected,
      isSearching: isSearching,
      hasOffer: hasOffer,
    );

    final barHeight = 96.h;

    return Container(
      height: barHeight + bottomSafe,
      padding: EdgeInsets.only(left: 18.w, right: 18.w, bottom: bottomSafe),
      decoration: BoxDecoration(
        color: AppTheme.Dark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: barHeight,
          child: Row(
            children: [
              _CircleIconButton(
                icon: Icons.menu_rounded,
                onTap: isBusy ? null : onMenuTap,
              ),
              const Spacer(),
              _StatusTogglePill(
                text: meta.text,
                background: meta.color,
                isBusy: isBusy,
                enabled: !hasOffer && !isBusy,
                onTap: (!hasOffer && !isBusy) ? onToggle : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StatusMeta _statusMeta({
    required bool isOnline,
    required bool isConnected,
    required bool isSearching,
    required bool hasOffer,
  }) {
    if (hasOffer) {
      return _StatusMeta("تم استلام عرض", AppTheme.orange);
    }

    if (!isOnline) {
      return _StatusMeta("غير متصل", AppTheme.red);
    }

    // ✅ متصل بس لسا مو جاهز يبحث (مثلاً Pusher مو CONNECTED)
    if (isConnected && !isSearching) {
      return _StatusMeta("متصل", AppTheme.primary);
    }

    // ✅ جاهز ويبحث
    if (isSearching) {
      return _StatusMeta("جاري البحث", AppTheme.green);
    }

    // fallback
    return _StatusMeta("متصل", AppTheme.primary);
  }
}

// ================= UI bits =================

class _StatusTogglePill extends StatelessWidget {
  final String text;
  final Color background;
  final bool isBusy;
  final bool enabled;
  final VoidCallback? onTap;

  const _StatusTogglePill({
    required this.text,
    required this.background,
    required this.isBusy,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pillH = 54.h;
    final pillW = 170.w;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: pillW,
            height: pillH,
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isBusy) ...[
                  SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 10.w),
                ],
                Flexible(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      fontFamily: "Cairo",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = 52.w;

    return Opacity(
      opacity: onTap == null ? 0.55 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: Icon(icon, color: Colors.white, size: 26.sp),
          ),
        ),
      ),
    );
  }
}

class _StatusMeta {
  final String text;
  final Color color;
  const _StatusMeta(this.text, this.color);
}
