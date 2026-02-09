part of 'auth_flow_cubit.dart';

@freezed
class AuthFlowState with _$AuthFlowState {
  const factory AuthFlowState.initial() = _Initial;
  const factory AuthFlowState.loading() = _Loading;
  const factory AuthFlowState.error(String message) = _Error;
  const factory AuthFlowState.loggedIn(dynamic data) = _LoggedIn;
  const factory AuthFlowState.loggedOut(String message) = _LoggedOut;
}
