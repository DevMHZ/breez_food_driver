import 'dart:async';
import 'package:breez_food_driver/core/di/di.dart';
import 'package:breez_food_driver/core/services/map_marker_icon.dart';
import 'package:breez_food_driver/core/services/shared_perfrences_key.dart';
import 'package:breez_food_driver/core/widgets/fancy_toast.dart';
import 'package:breez_food_driver/features/dialogs/confirm_oder_dialog_otp.dart';
import 'package:breez_food_driver/features/driver_location/presentation/cubit/driver_location_cubit.dart';
import 'package:breez_food_driver/features/orders/data/repo/orders_repo.dart';
import 'package:breez_food_driver/features/orders/presentation/cubit/order_status_state.dart';
import 'package:breez_food_driver/features/orders/presentation/cubit/orders_cubit.dart'
    show OrderStatusCubit;
import 'package:breez_food_driver/features/orders/presentation/ui/emergency_dialog.dart';
import 'package:breez_food_driver/features/orders/presentation/ui/tracking_map.dart';
import 'package:breez_food_driver/features/orders/presentation/ui/tracking_pretty_panel.dart';
import 'package:breez_food_driver/features/orders/presentation/ui/tracking_top_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'tracking_helpers.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;
  final Map<String, dynamic> order;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.order,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TrackingHelpers {
  // ✅ Phones (no sheet)
  List<String> restaurantPhones() {
    final r = restaurantMap();
    final p1 = (r['phone'] ?? '').toString().trim();
    final p2 = (r['phone2'] ?? '').toString().trim();

    final phones = <String>[];
    if (p1.isNotEmpty) phones.add(p1);
    if (p2.isNotEmpty && p2 != p1) phones.add(p2);
    return phones;
  }

  String _orderStatus() {
    final o = orderMap();
    final s = (o['status'] ?? o['order_status'] ?? o['state'] ?? "")
        .toString()
        .trim()
        .toLowerCase();
    return s;
  }

  void _syncFlagsFromStatus() {
    final s = _orderStatus();

    final isPreparing =
        s == "preparing" || s == "in_progress" || s == "inprogress";
    final isInWay = s == "inway" || s == "on_the_way" || s == "onway";
    final isDelivered = s == "delivered";

    setState(() {
      // إذا صار preparing أو أكثر => يعني انبعت للمطبخ
      sentToKitchen = isPreparing || isInWay || isDelivered;
      inWay = isInWay || isDelivered;
      delivered = isDelivered;
    });
  }

  final Completer<GoogleMapController> _controller = Completer();
  final DraggableScrollableController _panelCtrl =
      DraggableScrollableController();

  static const double _minSheet = 0.18;
  static const double _midSheet = 0.42;
  static const double _maxSheet = 0.85;

  bool restaurantCalled = false;
  bool sentToKitchen = false;
  bool primaryLoading = false;

  bool inWay = false;
  bool delivered = false;

  BitmapDescriptor? customerIcon;
  BitmapDescriptor? restaurantIcon;

  bool detailsLoading = false;
  Map<String, dynamic>? details;
  String? detailsError;

  // ✅ location stream
  StreamSubscription<Position>? _posSub;
  bool _locationStarted = false;

  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(34.103001, -117.435728),
    zoom: 14.47,
  );

  void _log(String msg) {
    // ignore: avoid_print
    print("🟩[TRACKING ${widget.orderId}] $msg");
  }

  // ===================== PRIMARY BUTTON =====================

  String _primaryBtnText() {
    final s = _orderStatus();
    if (s == "delivered")
      return trSafe("tracking.delivered", fallback: "تم التسليم");
    if (s == "inway")
      return trSafe("tracking.mark_delivered", fallback: "تأكيد التسليم");
    if (s == "preparing")
      return trSafe("tracking.start_inway", fallback: "ابدأ الطريق");
    return trSafe("tracking.send_to_kitchen", fallback: "إرسال للمطبخ");
  }

  String statusText() {
    final s = _orderStatus();
    if (s == "delivered")
      return trSafe("tracking.status_delivered", fallback: "تم التسليم");
    if (s == "inway")
      return trSafe("tracking.status_on_the_way", fallback: "بالطريق");
    if (s == "preparing")
      return trSafe("tracking.status_preparing", fallback: "قيد التحضير");
    return trSafe("tracking.status_accepted", fallback: "مقبول");
  }

  bool get _primaryBtnEnabled {
    if (detailsLoading) return false;
    if (primaryLoading) return false;
    if (delivered) return false;
    return true;
  }

  Future<void> _onPrimaryPressed() async {
    if (!_primaryBtnEnabled) return;

    if (!sentToKitchen) {
      setState(() => primaryLoading = true);
      try {
        final ok = await context.read<OrderStatusCubit>().sendOrderToKitchen(
          widget.orderId,
        );
        setState(() => sentToKitchen = true);
        await _loadOrderDetails(); // رح يعمل sync كمان

        if (!mounted) return;

        setState(() => primaryLoading = false);
        if (!ok) return;

        setState(() => sentToKitchen = true);

        showFancyToast(
          context,
          success: true,
          title: trSafe("toast.success_title", fallback: "نجاح"),
          message: trSafe(
            "tracking.sent_to_kitchen",
            fallback: "تم إرسال الطلب إلى المطبخ",
          ),
        );
      } catch (_) {
        if (!mounted) return;
        setState(() => primaryLoading = false);
        showFancyToast(
          context,
          success: false,
          title: trSafe("toast.error_title", fallback: "خطأ"),
          message: trSafe("common.unexpected_error", fallback: "خطأ غير متوقع"),
        );
      }
      return;
    }

    if (!inWay) {
      await startInWay();
      return;
    }

    await markDelivered();
  }

  // ===================== EXIT (CLEAR CACHE) =====================

  Future<void> _exitAndClearCache() async {
    try {
      await AuthStorageHelper.clearActiveOrder();
    } catch (_) {}

    _stopLocationSending();

    try {
      context.read<OrderStatusCubit>().reset();
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pop(false); // false = not delivered
  }

  // ===================== LIFECYCLE =====================

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadOrderDetails();
      await fitToPickupDropoff();
      await _startLocationSending();
    });
  }

  @override
  void dispose() {
    _stopLocationSending();
    _panelCtrl.dispose();
    super.dispose();
  }

  // ===================== LOCATION =====================

  Future<void> _startLocationSending() async {
    if (_locationStarted) return;
    _locationStarted = true;

    final ok = await _ensureLocationPermissionAndService();
    if (!ok) {
      _locationStarted = false;
      return;
    }

    final first = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    final firstLatLng = LatLng(first.latitude, first.longitude);
    context.read<DriverLocationCubit>().setLatest(firstLatLng);

    context.read<DriverLocationCubit>().setOnline(
      true,
      interval: const Duration(seconds: 15),
    );

    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );

    await _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen((
      pos,
    ) {
      final latLng = LatLng(pos.latitude, pos.longitude);
      context.read<DriverLocationCubit>().setLatest(latLng);
    });

    _log("✅ Location sending started");
  }

  void _stopLocationSending() {
    _posSub?.cancel();
    _posSub = null;

    try {
      context.read<DriverLocationCubit>().setOnline(false);
    } catch (_) {}

    _locationStarted = false;
    _log("🟥 Location sending stopped");
  }

  Future<bool> _ensureLocationPermissionAndService() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      if (mounted) {
        showFancyToast(
          context,
          success: false,
          title: trSafe("toast.error_title", fallback: "خطأ"),
          message: trSafe(
            "location.service_disabled",
            fallback: "فعّل خدمة الموقع (GPS) أولاً",
          ),
        );
      }
      return false;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied) {
      if (mounted) {
        showFancyToast(
          context,
          success: false,
          title: trSafe("toast.error_title", fallback: "خطأ"),
          message: trSafe(
            "location.permission_denied",
            fallback: "تم رفض صلاحية الموقع",
          ),
        );
      }
      return false;
    }

    if (perm == LocationPermission.deniedForever) {
      if (mounted) {
        showFancyToast(
          context,
          success: false,
          title: trSafe("toast.error_title", fallback: "خطأ"),
          message: trSafe(
            "location.permission_denied_forever",
            fallback: "صلاحية الموقع مرفوضة نهائيًا، فعّلها من الإعدادات",
          ),
        );
      }
      return false;
    }

    return true;
  }

  // ===================== MARKERS + DETAILS =====================

  Future<void> _loadMarkerIcons() async {
    try {
      customerIcon = await MapMarkerIcon.fromAsset(
        "assets/b_driver/customer_map_point.png",
        width: 120,
      );
      restaurantIcon = await MapMarkerIcon.fromAsset(
        "assets/b_driver/resturant_map_point.png",
        width: 120,
      );
      if (mounted) setState(() {});
    } catch (e) {
      _log("Marker icons load failed: $e");
    }
  }

  Future<void> _loadOrderDetails() async {
    if (detailsLoading) return;

    setState(() {
      detailsLoading = true;
      detailsError = null;
    });

    try {
      final repo = getIt<OrdersRepository>();
      final res = await repo.orderDetailsToDriver(widget.orderId);
      if (!mounted) return;

      if (!res.isOk) {
        final msg = (res.message ?? "common.failed").toString();
        setState(() {
          detailsLoading = false;
          detailsError = msg;
          details = null;
        });

        showFancyToast(
          context,
          success: false,
          title: trSafe("toast.error_title", fallback: "خطأ"),
          message: trSmart(msg),
        );
        return;
      }

      final raw = res.data;
      if (raw == null || raw is! Map) {
        setState(() {
          detailsLoading = false;
          details = raw.cast<String, dynamic>();
        });

        // ✅ مهم جداً: بعد ما خزّنت details
        _syncFlagsFromStatus();

        // (اختياري) إذا بدك تحديث النص/الخريطة مباشرة
        await fitToPickupDropoff();

        showFancyToast(
          context,
          success: false,
          title: trSafe("toast.error_title", fallback: "خطأ"),
          message: trSafe("common.failed", fallback: "فشلت العملية"),
        );
        return;
      }

      setState(() {
        detailsLoading = false;
        details = raw.cast<String, dynamic>();
      });
    } catch (e) {
      _log("Details exception: $e");
      if (!mounted) return;

      setState(() {
        detailsLoading = false;
        detailsError = "common.unexpected_error";
        details = null;
      });

      showFancyToast(
        context,
        success: false,
        title: trSafe("toast.error_title", fallback: "خطأ"),
        message: trSafe("common.unexpected_error", fallback: "خطأ غير متوقع"),
      );
    }
  }

  // ===================== maps from details =====================

  Map<String, dynamic> orderMap() {
    final o = (details?['order'] as Map?)?.cast<String, dynamic>();
    if (o != null && o.isNotEmpty) return o;
    return widget.order.cast<String, dynamic>();
  }

  Map<String, dynamic> restaurantMap() {
    return (details?['restaurant'] as Map?)?.cast<String, dynamic>() ?? {};
  }

  List<Map<String, dynamic>> itemsList() {
    final list = details?['items'];
    if (list is List) {
      return list
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    return const [];
  }

  List<Map<String, dynamic>> appetizersList() {
    final list = details?['appetizers'];
    if (list is List) {
      return list
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    return const [];
  }

  LatLng? pickupLatLng() {
    final order = orderMap();
    final pickup = (order['pickup'] as Map?)?.cast<String, dynamic>();
    if (pickup != null) {
      final lat = pickup['lat'];
      final lng = pickup['lng'];
      if (lat is num && lng is num) {
        final p = LatLng(lat.toDouble(), lng.toDouble());
        if (p.latitude != 0 && p.longitude != 0) return p;
      }
    }

    final r = restaurantMap();
    final rLat = r['latitude'];
    final rLng = r['longitude'];
    final lat = (rLat is num) ? rLat.toDouble() : double.tryParse("$rLat");
    final lng = (rLng is num) ? rLng.toDouble() : double.tryParse("$rLng");

    if (lat == null || lng == null) return null;
    if (lat == 0 || lng == 0) return null;

    return LatLng(lat, lng);
  }

  LatLng? dropoffLatLng() {
    final order = orderMap();
    final drop = (order['dropoff'] as Map?)?.cast<String, dynamic>();
    if (drop != null) {
      final lat = drop['lat'];
      final lng = drop['lng'];
      if (lat is num && lng is num) {
        final d = LatLng(lat.toDouble(), lng.toDouble());
        if (d.latitude != 0 && d.longitude != 0) return d;
      }
    }

    final latAny = order['latitude'];
    final lngAny = order['longitude'];
    final lat = (latAny is num)
        ? latAny.toDouble()
        : double.tryParse("$latAny");
    final lng = (lngAny is num)
        ? lngAny.toDouble()
        : double.tryParse("$lngAny");

    if (lat == null || lng == null) return null;
    if (lat == 0 || lng == 0) return null;

    return LatLng(lat, lng);
  }

  Future<void> fitToPickupDropoff() async {
    final p = pickupLatLng();
    final d = dropoffLatLng();
    if (p == null || d == null || !_controller.isCompleted) return;

    final c = await _controller.future;

    final southWest = LatLng(
      (p.latitude < d.latitude) ? p.latitude : d.latitude,
      (p.longitude < d.longitude) ? p.longitude : d.longitude,
    );
    final northEast = LatLng(
      (p.latitude > d.latitude) ? p.latitude : d.latitude,
      (p.longitude > d.longitude) ? p.longitude : d.longitude,
    );

    await c.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southWest, northeast: northEast),
        90,
      ),
    );
  }

  // ===================== actions =====================

  Future<void> openNavigationTo(LatLng? target) async {
    if (target == null) return;

    final uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=${target.latitude},${target.longitude}&travelmode=driving",
    );

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      showFancyToast(
        context,
        success: false,
        title: trSafe("toast.error_title", fallback: "خطأ"),
        message: trSafe(
          "tracking.maps_open_failed",
          fallback: "تعذر فتح الخرائط",
        ),
      );
    }
  }

  Future<bool> callNumber(String? phone) async {
    final p = (phone ?? "").trim();
    if (p.isEmpty) {
      showFancyToast(
        context,
        success: false,
        title: trSafe("toast.error_title", fallback: "خطأ"),
        message: trSafe(
          "common.phone_missing",
          fallback: "رقم الهاتف غير موجود",
        ),
      );
      return false;
    }

    final uri = Uri(scheme: "tel", path: p);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!ok && mounted) {
      showFancyToast(
        context,
        success: false,
        title: trSafe("toast.error_title", fallback: "خطأ"),
        message: trSafe("common.call_failed", fallback: "فشل الاتصال"),
      );
    }

    return ok;
  }

  Future<void> _callRestaurantAt(int index) async {
    final phones = restaurantPhones();
    if (index < 0 || index >= phones.length) {
      showFancyToast(
        context,
        success: false,
        title: trSafe("toast.error_title", fallback: "خطأ"),
        message: trSafe(
          "common.phone_missing",
          fallback: "رقم الهاتف غير موجود",
        ),
      );
      return;
    }

    final ok = await callNumber(phones[index]);
    if (!mounted) return;

    if (ok && !restaurantCalled) {
      setState(() => restaurantCalled = true);
      showFancyToast(
        context,
        success: true,
        title: trSafe("toast.success_title", fallback: "نجاح"),
        message: trSafe(
          "tracking.restaurant_called",
          fallback: "تم الاتصال بالمطعم",
        ),
      );
    }
  }

  Future<void> startInWay() async {
    if (!restaurantCalled) {
      showFancyToast(
        context,
        success: false,
        title: trSafe("toast.error_title", fallback: "تنبيه"),
        message: trSafe(
          "tracking.call_required_before_start",
          fallback: "لازم تتصل بالمطعم قبل ما تبدأ الطريق",
        ),
      );
      return;
    }

    final ok = await context.read<OrderStatusCubit>().changeToInWay(
      widget.orderId,
    );
    if (!ok) return;
    await _loadOrderDetails(); // هون رح يجيب status=inway ويحدّث UI
    if (!mounted) return;
    setState(() => inWay = true);
    await _loadOrderDetails();
    _panelCtrl.animateTo(
      _midSheet,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _showDeliveredSuccessDialog() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (ctx) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // دائرة النجاح
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.12),
                  ),
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Image.asset(
                  "assets/images/breeze-food2.png",
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 12),

                const Text(
                  "تم التسليم بنجاح",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "تم تأكيد تسليم الطلب بنجاح ✅",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 18,
                        color: Colors.black.withOpacity(0.55),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "تم حفظ حالة الطلب، يمكنك إغلاق النافذة الآن.",
                          style: TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "تمام",
                      style: TextStyle(
                        fontFamily: "Cairo",
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> markDelivered() async {
    if (!inWay || delivered) return;

    final code = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const OrderCodeDialog(),
    );
    if (code == null || code.trim().isEmpty) return;

    final ok = await context.read<OrderStatusCubit>().changeToDelivered(
      orderId: widget.orderId,
      code: code.trim(),
    );
    if (!ok || !mounted) return;

    setState(() => delivered = true);
    await _showDeliveredSuccessDialog();

    await AuthStorageHelper.clearActiveOrder();
    _stopLocationSending();

    goHomeAndClearStack();
  }

  Future<void> sendEmergency() async {
    final reason = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => EmergencyDialog(orderId: widget.orderId),
    );
    if (reason == null || reason.trim().isEmpty) return;

    final ok = await context.read<OrderStatusCubit>().sendEmergency(
      orderId: widget.orderId,
      reason: reason.trim(),
    );
    if (!ok || !mounted) return;

    showFancyToast(
      context,
      success: true,
      title: trSafe("toast.success_title", fallback: "نجاح"),
      message: trSafe("tracking.emergency_sent", fallback: "تم إرسال البلاغ"),
    );
  }

  void goHomeAndClearStack() {
    try {
      context.read<OrderStatusCubit>().reset();
    } catch (_) {}

    Navigator.of(context).pop(true); // true = delivered
  }

  // ===================== build =====================

  @override
  Widget build(BuildContext context) {
    final pickup = pickupLatLng();
    final dropoff = dropoffLatLng();
    final phones = restaurantPhones();

    final markers = <Marker>{
      if (pickup != null)
        Marker(
          markerId: const MarkerId("pickup"),
          position: pickup,
          icon:
              restaurantIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          anchor: const Offset(0.5, 1.0),
          infoWindow: InfoWindow(
            title: trSafe("tracking.pickup", fallback: "Pickup"),
          ),
        ),
      if (dropoff != null)
        Marker(
          markerId: const MarkerId("dropoff"),
          position: dropoff,
          icon:
              customerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          anchor: const Offset(0.5, 1.0),
          infoWindow: InfoWindow(
            title: trSafe("tracking.dropoff", fallback: "Dropoff"),
          ),
        ),
    };

    return BlocListener<OrderStatusCubit, OrderStatusState>(
      listener: (context, state) {
        String trMaybe(String keyOrText) {
          final s = keyOrText.trim();
          final looksLikeKey = s.contains('.') && !s.contains(' ');
          return looksLikeKey ? s.tr() : s;
        }

        state.whenOrNull(
          success: (_, message) {
            showFancyToast(
              context,
              success: true,
              title: trSafe("toast.success_title", fallback: "نجاح"),
              message: trMaybe(message),
            );
            context.read<OrderStatusCubit>().reset();
          },
          error: (_, message) {
            showFancyToast(
              context,
              success: false,
              title: trSafe("toast.error_title", fallback: "خطأ"),
              message: trMaybe(message),
            );
            context.read<OrderStatusCubit>().reset();
          },
        );
      },
      child: WillPopScope(
        onWillPop: () async {
          await _exitAndClearCache();
          return false;
        },
        child: Scaffold(
          body: Stack(
            children: [
              TrackingMap(
                controller: _controller,
                initial: initialCameraPosition,
                markers: markers,
                onCreated: () async {
                  await Future.delayed(const Duration(milliseconds: 200));
                  if (mounted) await fitToPickupDropoff();
                },
              ),

              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                right: 10,
                child: TrackingTopBar(
                  onBack: _exitAndClearCache,
                  onClose: _exitAndClearCache,
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: MediaQuery.of(context).padding.top + 70,
                child: DraggableScrollableSheet(
                  controller: _panelCtrl,
                  initialChildSize: _midSheet,
                  minChildSize: _minSheet,
                  maxChildSize: _maxSheet,
                  snap: true,
                  snapSizes: const [_minSheet, _midSheet, _maxSheet],
                  builder: (context, scrollController) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Material(
                        elevation: 14,
                        borderRadius: BorderRadius.circular(18),
                        clipBehavior: Clip.antiAlias,
                        child: CustomScrollView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 8,
                                ),
                                child: Center(
                                  child: Container(
                                    width: 44,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SliverToBoxAdapter(
                              child: TrackingPrettyPanel(
                                restaurantPhones: phones,
                                onCallRestaurant1: phones.isNotEmpty
                                    ? () => _callRestaurantAt(0)
                                    : null,
                                onCallRestaurant2: phones.length > 1
                                    ? () => _callRestaurantAt(1)
                                    : null,
                                customer: (details?['customer'] as Map?)
                                    ?.cast<String, dynamic>(),
                                showCustomerInfo: inWay,
                                orderId: widget.orderId,
                                statusText: statusText(),
                                restaurantCalled: restaurantCalled,
                                primaryLoading: primaryLoading,
                                detailsLoading: detailsLoading,
                                detailsError: detailsError,
                                order: orderMap(),
                                restaurant: restaurantMap(),
                                items: itemsList(),
                                appetizers: appetizersList(),
                                pickup: pickup,
                                dropoff: dropoff,
                                onRetry: _loadOrderDetails,
                                onNavigateTo: openNavigationTo,
                                primaryBtnText: _primaryBtnText(),
                                primaryBtnEnabled: _primaryBtnEnabled,
                                onPrimaryPressed: _onPrimaryPressed,
                                onEmergencyPressed: sendEmergency,
                              ),
                            ),

                            const SliverToBoxAdapter(
                              child: SizedBox(height: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
