import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repo/offers_repo.dart';
import 'offers_state.dart';

class OfferCubit extends Cubit<OfferState> {
  final OffersRepository repo;

  bool _sheetOpened = false;
  bool get sheetOpened => _sheetOpened;

  OfferCubit(this.repo) : super(const OfferState.idle());

  void markSheetOpened(bool v) => _sheetOpened = v;

  Map<String, dynamic>? get _currentOffer {
    return state.whenOrNull(
      received: (offer) => offer,
      actionLoading: (offer) => offer,
      error: (_, offer) => offer,
      accepted: (offer) => offer,
    );
  }

  int? get currentOrderId {
    final offer = _currentOffer;
    final order = offer?['order'];
    if (order is Map) {
      final id = order['id'];
      if (id is int) return id;
      if (id is num) return id.toInt();
      if (id is String) return int.tryParse(id);
    }
    return null;
  }

  /// يستدعى من Pusher event
  Future<void> onOfferReceived(Map<String, dynamic> data) async {
    emit(OfferState.received(offer: data));

    final orderId = _extractOrderIdFromOffer(data);
    if (orderId == null) return;

    // ACK best effort
    unawaited(repo.ack(orderId.toString()));
  }

  int? _extractOrderIdFromOffer(Map<String, dynamic> offer) {
    final order = (offer['order'] as Map?)?.cast<String, dynamic>() ?? {};
    final orderIdRaw = order['id'];
    if (orderIdRaw is int) return orderIdRaw;
    if (orderIdRaw is num) return orderIdRaw.toInt();
    return int.tryParse("$orderIdRaw");
  }

  Future<void> declineCurrent() async {
    final offer = _currentOffer;

    if (offer == null) {
      emit(const OfferState.idle());
      _sheetOpened = false;
      return;
    }

    final orderId = _extractOrderIdFromOffer(offer);
    if (orderId == null) {
      emit(const OfferState.idle());
      _sheetOpened = false;
      return;
    }

    emit(OfferState.actionLoading(offer: offer));
    final res = await repo.decline(orderId.toString());

    if (!res.ok) {
      emit(
        OfferState.error(message: res.message ?? "فشل رفض الطلب", offer: offer),
      );
      emit(OfferState.received(offer: offer));
      return;
    }

    emit(const OfferState.idle());
    _sheetOpened = false;
  }

  Future<bool> acceptCurrent() async {
    final offer = state.whenOrNull(
      received: (offer) => offer,
      actionLoading: (offer) => offer,
      error: (_, offer) => offer,
    );

    if (offer == null) return false;

    final orderId = _extractOrderIdFromOffer(offer);
    if (orderId == null) return false;

    emit(OfferState.actionLoading(offer: offer));
    final res = await repo.accept(orderId.toString());

    if (!res.ok) {
      emit(
        OfferState.error(
          message: res.message ?? "فشل قبول الطلب",
          offer: offer,
        ),
      );
      emit(OfferState.received(offer: offer));
      return false;
    }

    emit(OfferState.accepted(offer: offer));
    return true;
  }

  void reset() {
    _sheetOpened = false;
    emit(const OfferState.idle());
  }
}
