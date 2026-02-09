import 'package:breez_food_driver/features/auth/data/repo/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
part 'auth_flow_state.dart';
part 'auth_flow_cubit.freezed.dart';

class AuthFlowCubit extends Cubit<AuthFlowState> {
  final AuthRepository repo;
  AuthFlowCubit(this.repo) : super(const AuthFlowState.initial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthFlowState.loading());

    final fcm = await getFcmToken(); // ✅

    final res = await repo.login(
      email: email,
      password: password,
      token: fcm, // ✅
    );

    if (!res.ok) {
      emit(AuthFlowState.error(res.message ?? "خطأ"));
      return;
    }

    emit(AuthFlowState.loggedIn(res.data));
  }

  Future<void> logout() async {
    emit(const AuthFlowState.loading());

    final res = await repo.logout();
    if (!res.ok) {
      emit(AuthFlowState.error(res.message ?? "فشل تسجيل الخروج"));
      return;
    }

    emit(AuthFlowState.loggedOut(res.message ?? "Logged out successfully"));
  }
}

class LogoutService {
  final AuthRepository repo;
  LogoutService(this.repo);

  Future<void> logoutAndRedirect(
    BuildContext context, {
    required Widget Function() loginBuilder,
    void Function(String message)? onMessage,
  }) async {
    final res = await repo.logout();
    if (onMessage != null) {
      onMessage(res.message ?? "Logged out");
    }

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => loginBuilder()),
      (_) => false,
    );
  }
}

Future<String?> getFcmToken() async {
  try {
    return await FirebaseMessaging.instance.getToken();
  } catch (_) {
    return null;
  }
}

