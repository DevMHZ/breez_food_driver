import 'dart:async';

import 'package:breez_food_driver/features/driver_location/data/repo/driver_location_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'driver_location_state.dart';

class DriverLocationCubit extends Cubit<DriverLocationState> {
  final DriverLocationRepository repo;
  DriverLocationCubit(this.repo) : super(const DriverLocationState.idle());

  Timer? _timer;
  LatLng? _latest;
  bool _online = false;

  DateTime _lastSent = DateTime.fromMillisecondsSinceEpoch(0);

  /// خزّن آخر موقع إجانا من الستريم
  void setLatest(LatLng latLng) {
    _latest = latLng;
  }

  /// شغّل/اطفي الإرسال الدوري حسب online
  void setOnline(
    bool online, {
    Duration interval = const Duration(seconds: 15),
  }) {
    _online = online;
    if (!_online) {
      stop();
      return;
    }
    start(interval: interval);
  }

  void start({Duration interval = const Duration(seconds: 15)}) {
    if (_timer != null) return;

    emit(const DriverLocationState.idle(running: true));

    // إرسال أول مرة فوراً (اختياري)
    _tick();

    _timer = Timer.periodic(interval, (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    emit(const DriverLocationState.idle(running: false));
  }

  Future<void> _tick() async {
    if (!_online) return;
    final pos = _latest;
    if (pos == null) return;

    // حماية بسيطة لو صار عندك double timers أو tick متقارب
    final now = DateTime.now();
    if (now.difference(_lastSent).inSeconds < 5) return;

    _lastSent = now;

    // ما بدي أعمل loading قوي كل مرة (بيأثر UI)،
    // بس إذا بدك، خليها sending:
    // emit(const DriverLocationState.sending());

    final res = await repo.sendLocation(
      latitude: pos.latitude,
      longitude: pos.longitude,
    );

    if (!res.ok) {
      emit(DriverLocationState.error(res.message ?? "خطأ إرسال الموقع"));
      // ما منوقف التايمر — منخليه يحاول تاني
      emit(const DriverLocationState.idle(running: true));
      return;
    }

    // optional: message
    // emit(const DriverLocationState.idle(running: true, message: "Location sent"));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
