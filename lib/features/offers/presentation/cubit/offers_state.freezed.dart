// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offers_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OfferState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(Map<String, dynamic> offer) received,
    required TResult Function(Map<String, dynamic> offer) actionLoading,
    required TResult Function(Map<String, dynamic> offer) accepted,
    required TResult Function(String message, Map<String, dynamic>? offer)
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(Map<String, dynamic> offer)? received,
    TResult? Function(Map<String, dynamic> offer)? actionLoading,
    TResult? Function(Map<String, dynamic> offer)? accepted,
    TResult? Function(String message, Map<String, dynamic>? offer)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(Map<String, dynamic> offer)? received,
    TResult Function(Map<String, dynamic> offer)? actionLoading,
    TResult Function(Map<String, dynamic> offer)? accepted,
    TResult Function(String message, Map<String, dynamic>? offer)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Received value) received,
    required TResult Function(_ActionLoading value) actionLoading,
    required TResult Function(_Accepted value) accepted,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Received value)? received,
    TResult? Function(_ActionLoading value)? actionLoading,
    TResult? Function(_Accepted value)? accepted,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Received value)? received,
    TResult Function(_ActionLoading value)? actionLoading,
    TResult Function(_Accepted value)? accepted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OfferStateCopyWith<$Res> {
  factory $OfferStateCopyWith(
          OfferState value, $Res Function(OfferState) then) =
      _$OfferStateCopyWithImpl<$Res, OfferState>;
}

/// @nodoc
class _$OfferStateCopyWithImpl<$Res, $Val extends OfferState>
    implements $OfferStateCopyWith<$Res> {
  _$OfferStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OfferState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$IdleImplCopyWith<$Res> {
  factory _$$IdleImplCopyWith(
          _$IdleImpl value, $Res Function(_$IdleImpl) then) =
      __$$IdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$IdleImplCopyWithImpl<$Res>
    extends _$OfferStateCopyWithImpl<$Res, _$IdleImpl>
    implements _$$IdleImplCopyWith<$Res> {
  __$$IdleImplCopyWithImpl(_$IdleImpl _value, $Res Function(_$IdleImpl) _then)
      : super(_value, _then);

  /// Create a copy of OfferState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$IdleImpl implements _Idle {
  const _$IdleImpl();

  @override
  String toString() {
    return 'OfferState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$IdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(Map<String, dynamic> offer) received,
    required TResult Function(Map<String, dynamic> offer) actionLoading,
    required TResult Function(Map<String, dynamic> offer) accepted,
    required TResult Function(String message, Map<String, dynamic>? offer)
        error,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(Map<String, dynamic> offer)? received,
    TResult? Function(Map<String, dynamic> offer)? actionLoading,
    TResult? Function(Map<String, dynamic> offer)? accepted,
    TResult? Function(String message, Map<String, dynamic>? offer)? error,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(Map<String, dynamic> offer)? received,
    TResult Function(Map<String, dynamic> offer)? actionLoading,
    TResult Function(Map<String, dynamic> offer)? accepted,
    TResult Function(String message, Map<String, dynamic>? offer)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Received value) received,
    required TResult Function(_ActionLoading value) actionLoading,
    required TResult Function(_Accepted value) accepted,
    required TResult Function(_Error value) error,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Received value)? received,
    TResult? Function(_ActionLoading value)? actionLoading,
    TResult? Function(_Accepted value)? accepted,
    TResult? Function(_Error value)? error,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Received value)? received,
    TResult Function(_ActionLoading value)? actionLoading,
    TResult Function(_Accepted value)? accepted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class _Idle implements OfferState {
  const factory _Idle() = _$IdleImpl;
}

/// @nodoc
abstract class _$$ReceivedImplCopyWith<$Res> {
  factory _$$ReceivedImplCopyWith(
          _$ReceivedImpl value, $Res Function(_$ReceivedImpl) then) =
      __$$ReceivedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Map<String, dynamic> offer});
}

/// @nodoc
class __$$ReceivedImplCopyWithImpl<$Res>
    extends _$OfferStateCopyWithImpl<$Res, _$ReceivedImpl>
    implements _$$ReceivedImplCopyWith<$Res> {
  __$$ReceivedImplCopyWithImpl(
      _$ReceivedImpl _value, $Res Function(_$ReceivedImpl) _then)
      : super(_value, _then);

  /// Create a copy of OfferState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? offer = null,
  }) {
    return _then(_$ReceivedImpl(
      offer: null == offer
          ? _value._offer
          : offer // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$ReceivedImpl implements _Received {
  const _$ReceivedImpl({required final Map<String, dynamic> offer})
      : _offer = offer;

  final Map<String, dynamic> _offer;
  @override
  Map<String, dynamic> get offer {
    if (_offer is EqualUnmodifiableMapView) return _offer;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_offer);
  }

  @override
  String toString() {
    return 'OfferState.received(offer: $offer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceivedImpl &&
            const DeepCollectionEquality().equals(other._offer, _offer));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_offer));

  /// Create a copy of OfferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceivedImplCopyWith<_$ReceivedImpl> get copyWith =>
      __$$ReceivedImplCopyWithImpl<_$ReceivedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(Map<String, dynamic> offer) received,
    required TResult Function(Map<String, dynamic> offer) actionLoading,
    required TResult Function(Map<String, dynamic> offer) accepted,
    required TResult Function(String message, Map<String, dynamic>? offer)
        error,
  }) {
    return received(offer);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(Map<String, dynamic> offer)? received,
    TResult? Function(Map<String, dynamic> offer)? actionLoading,
    TResult? Function(Map<String, dynamic> offer)? accepted,
    TResult? Function(String message, Map<String, dynamic>? offer)? error,
  }) {
    return received?.call(offer);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(Map<String, dynamic> offer)? received,
    TResult Function(Map<String, dynamic> offer)? actionLoading,
    TResult Function(Map<String, dynamic> offer)? accepted,
    TResult Function(String message, Map<String, dynamic>? offer)? error,
    required TResult orElse(),
  }) {
    if (received != null) {
      return received(offer);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Received value) received,
    required TResult Function(_ActionLoading value) actionLoading,
    required TResult Function(_Accepted value) accepted,
    required TResult Function(_Error value) error,
  }) {
    return received(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Received value)? received,
    TResult? Function(_ActionLoading value)? actionLoading,
    TResult? Function(_Accepted value)? accepted,
    TResult? Function(_Error value)? error,
  }) {
    return received?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Received value)? received,
    TResult Function(_ActionLoading value)? actionLoading,
    TResult Function(_Accepted value)? accepted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (received != null) {
      return received(this);
    }
    return orElse();
  }
}

abstract class _Received implements OfferState {
  const factory _Received({required final Map<String, dynamic> offer}) =
      _$ReceivedImpl;

  Map<String, dynamic> get offer;

  /// Create a copy of OfferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceivedImplCopyWith<_$ReceivedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ActionLoadingImplCopyWith<$Res> {
  factory _$$ActionLoadingImplCopyWith(
          _$ActionLoadingImpl value, $Res Function(_$ActionLoadingImpl) then) =
      __$$ActionLoadingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Map<String, dynamic> offer});
}

/// @nodoc
class __$$ActionLoadingImplCopyWithImpl<$Res>
    extends _$OfferStateCopyWithImpl<$Res, _$ActionLoadingImpl>
    implements _$$ActionLoadingImplCopyWith<$Res> {
  __$$ActionLoadingImplCopyWithImpl(
      _$ActionLoadingImpl _value, $Res Function(_$ActionLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of OfferState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? offer = null,
  }) {
    return _then(_$ActionLoadingImpl(
      offer: null == offer
          ? _value._offer
          : offer // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$ActionLoadingImpl implements _ActionLoading {
  const _$ActionLoadingImpl({required final Map<String, dynamic> offer})
      : _offer = offer;

  final Map<String, dynamic> _offer;
  @override
  Map<String, dynamic> get offer {
    if (_offer is EqualUnmodifiableMapView) return _offer;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_offer);
  }

  @override
  String toString() {
    return 'OfferState.actionLoading(offer: $offer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActionLoadingImpl &&
            const DeepCollectionEquality().equals(other._offer, _offer));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_offer));

  /// Create a copy of OfferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActionLoadingImplCopyWith<_$ActionLoadingImpl> get copyWith =>
      __$$ActionLoadingImplCopyWithImpl<_$ActionLoadingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(Map<String, dynamic> offer) received,
    required TResult Function(Map<String, dynamic> offer) actionLoading,
    required TResult Function(Map<String, dynamic> offer) accepted,
    required TResult Function(String message, Map<String, dynamic>? offer)
        error,
  }) {
    return actionLoading(offer);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(Map<String, dynamic> offer)? received,
    TResult? Function(Map<String, dynamic> offer)? actionLoading,
    TResult? Function(Map<String, dynamic> offer)? accepted,
    TResult? Function(String message, Map<String, dynamic>? offer)? error,
  }) {
    return actionLoading?.call(offer);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(Map<String, dynamic> offer)? received,
    TResult Function(Map<String, dynamic> offer)? actionLoading,
    TResult Function(Map<String, dynamic> offer)? accepted,
    TResult Function(String message, Map<String, dynamic>? offer)? error,
    required TResult orElse(),
  }) {
    if (actionLoading != null) {
      return actionLoading(offer);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Received value) received,
    required TResult Function(_ActionLoading value) actionLoading,
    required TResult Function(_Accepted value) accepted,
    required TResult Function(_Error value) error,
  }) {
    return actionLoading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Received value)? received,
    TResult? Function(_ActionLoading value)? actionLoading,
    TResult? Function(_Accepted value)? accepted,
    TResult? Function(_Error value)? error,
  }) {
    return actionLoading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Received value)? received,
    TResult Function(_ActionLoading value)? actionLoading,
    TResult Function(_Accepted value)? accepted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (actionLoading != null) {
      return actionLoading(this);
    }
    return orElse();
  }
}

abstract class _ActionLoading implements OfferState {
  const factory _ActionLoading({required final Map<String, dynamic> offer}) =
      _$ActionLoadingImpl;

  Map<String, dynamic> get offer;

  /// Create a copy of OfferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActionLoadingImplCopyWith<_$ActionLoadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AcceptedImplCopyWith<$Res> {
  factory _$$AcceptedImplCopyWith(
          _$AcceptedImpl value, $Res Function(_$AcceptedImpl) then) =
      __$$AcceptedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Map<String, dynamic> offer});
}

/// @nodoc
class __$$AcceptedImplCopyWithImpl<$Res>
    extends _$OfferStateCopyWithImpl<$Res, _$AcceptedImpl>
    implements _$$AcceptedImplCopyWith<$Res> {
  __$$AcceptedImplCopyWithImpl(
      _$AcceptedImpl _value, $Res Function(_$AcceptedImpl) _then)
      : super(_value, _then);

  /// Create a copy of OfferState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? offer = null,
  }) {
    return _then(_$AcceptedImpl(
      offer: null == offer
          ? _value._offer
          : offer // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$AcceptedImpl implements _Accepted {
  const _$AcceptedImpl({required final Map<String, dynamic> offer})
      : _offer = offer;

  final Map<String, dynamic> _offer;
  @override
  Map<String, dynamic> get offer {
    if (_offer is EqualUnmodifiableMapView) return _offer;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_offer);
  }

  @override
  String toString() {
    return 'OfferState.accepted(offer: $offer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AcceptedImpl &&
            const DeepCollectionEquality().equals(other._offer, _offer));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_offer));

  /// Create a copy of OfferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AcceptedImplCopyWith<_$AcceptedImpl> get copyWith =>
      __$$AcceptedImplCopyWithImpl<_$AcceptedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(Map<String, dynamic> offer) received,
    required TResult Function(Map<String, dynamic> offer) actionLoading,
    required TResult Function(Map<String, dynamic> offer) accepted,
    required TResult Function(String message, Map<String, dynamic>? offer)
        error,
  }) {
    return accepted(offer);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(Map<String, dynamic> offer)? received,
    TResult? Function(Map<String, dynamic> offer)? actionLoading,
    TResult? Function(Map<String, dynamic> offer)? accepted,
    TResult? Function(String message, Map<String, dynamic>? offer)? error,
  }) {
    return accepted?.call(offer);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(Map<String, dynamic> offer)? received,
    TResult Function(Map<String, dynamic> offer)? actionLoading,
    TResult Function(Map<String, dynamic> offer)? accepted,
    TResult Function(String message, Map<String, dynamic>? offer)? error,
    required TResult orElse(),
  }) {
    if (accepted != null) {
      return accepted(offer);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Received value) received,
    required TResult Function(_ActionLoading value) actionLoading,
    required TResult Function(_Accepted value) accepted,
    required TResult Function(_Error value) error,
  }) {
    return accepted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Received value)? received,
    TResult? Function(_ActionLoading value)? actionLoading,
    TResult? Function(_Accepted value)? accepted,
    TResult? Function(_Error value)? error,
  }) {
    return accepted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Received value)? received,
    TResult Function(_ActionLoading value)? actionLoading,
    TResult Function(_Accepted value)? accepted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (accepted != null) {
      return accepted(this);
    }
    return orElse();
  }
}

abstract class _Accepted implements OfferState {
  const factory _Accepted({required final Map<String, dynamic> offer}) =
      _$AcceptedImpl;

  Map<String, dynamic> get offer;

  /// Create a copy of OfferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AcceptedImplCopyWith<_$AcceptedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, Map<String, dynamic>? offer});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$OfferStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of OfferState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? offer = freezed,
  }) {
    return _then(_$ErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      offer: freezed == offer
          ? _value._offer
          : offer // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl({required this.message, final Map<String, dynamic>? offer})
      : _offer = offer;

  @override
  final String message;
  final Map<String, dynamic>? _offer;
  @override
  Map<String, dynamic>? get offer {
    final value = _offer;
    if (value == null) return null;
    if (_offer is EqualUnmodifiableMapView) return _offer;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'OfferState.error(message: $message, offer: $offer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._offer, _offer));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, const DeepCollectionEquality().hash(_offer));

  /// Create a copy of OfferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(Map<String, dynamic> offer) received,
    required TResult Function(Map<String, dynamic> offer) actionLoading,
    required TResult Function(Map<String, dynamic> offer) accepted,
    required TResult Function(String message, Map<String, dynamic>? offer)
        error,
  }) {
    return error(message, offer);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(Map<String, dynamic> offer)? received,
    TResult? Function(Map<String, dynamic> offer)? actionLoading,
    TResult? Function(Map<String, dynamic> offer)? accepted,
    TResult? Function(String message, Map<String, dynamic>? offer)? error,
  }) {
    return error?.call(message, offer);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(Map<String, dynamic> offer)? received,
    TResult Function(Map<String, dynamic> offer)? actionLoading,
    TResult Function(Map<String, dynamic> offer)? accepted,
    TResult Function(String message, Map<String, dynamic>? offer)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, offer);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Received value) received,
    required TResult Function(_ActionLoading value) actionLoading,
    required TResult Function(_Accepted value) accepted,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Received value)? received,
    TResult? Function(_ActionLoading value)? actionLoading,
    TResult? Function(_Accepted value)? accepted,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Received value)? received,
    TResult Function(_ActionLoading value)? actionLoading,
    TResult Function(_Accepted value)? accepted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements OfferState {
  const factory _Error(
      {required final String message,
      final Map<String, dynamic>? offer}) = _$ErrorImpl;

  String get message;
  Map<String, dynamic>? get offer;

  /// Create a copy of OfferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
