import 'package:breez_food_driver/core/services/shared_perfrences_key.dart';
import 'package:breez_food_driver/features/profile/data/model/address_model.dart';
import 'package:breez_food_driver/features/profile/data/model/avatar_model.dart';
import 'package:breez_food_driver/features/profile/data/model/user_model.dart';
import 'package:breez_food_driver/features/profile/data/repo/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.dart';
part 'profile_cubit.freezed.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repo;
  ProfileCubit(this.repo) : super(const ProfileState.initial());

  // =========================
  // Load Me
  // =========================
  Future<void> load({bool forceRefresh = false}) async {
    final prev = state;
    final prevLoaded = prev is _Loaded ? prev : null;

    // ✅ 1) اعرض الكاش فوراً (UX سريع)
    if (!forceRefresh) {
      final cached = await AuthStorageHelper.getMeJson();
      if (cached != null) {
        try {
          final user = UserModel.fromJson(cached);
          emit(ProfileState.loaded(
            user: user,
            addresses: const [],
            avatars: prevLoaded?.avatars ?? const <AvatarModel>[],
            selectedAvatarPath: prevLoaded?.selectedAvatarPath,
            isSaving: false,
            message: null,
          ));
        } catch (_) {}
      }

      // ✅ إذا الكاش fresh لا تضرب الشبكة
      final fresh = await AuthStorageHelper.isMeCacheFresh(
        ttl: const Duration(hours: 6),
      );
      if (fresh && cached != null) return;
    }

    emit(const ProfileState.loading());

    final meRes = await repo.me();
    if (!meRes.ok) {
      emit(ProfileState.error(meRes.message ?? "خطأ"));
      if (prevLoaded != null) emit(prevLoaded);
      return;
    }

    try {
      final raw = meRes.data;
      if (raw is! Map) throw Exception("bad");

      final root = raw.cast<String, dynamic>();
      final inner = root["data"];
      final Map<String, dynamic> data =
          (inner is Map) ? inner.cast<String, dynamic>() : root;

      // ✅ خزّن اللوكال
      await AuthStorageHelper.saveMeJson(data);

      final user = UserModel.fromJson(data);

      final List<AddressModel> addresses = [];
      final rawAddresses = data["addresses"];
      if (rawAddresses is List) {
        for (final e in rawAddresses) {
          if (e is Map) {
            addresses.add(AddressModel.fromJson(e.cast<String, dynamic>()));
          }
        }
      }

      emit(ProfileState.loaded(
        user: user,
        addresses: addresses,
        avatars: prevLoaded?.avatars ?? const <AvatarModel>[],
        selectedAvatarPath: prevLoaded?.selectedAvatarPath,
        isSaving: false,
        message: null,
      ));
    } catch (_) {
      emit(const ProfileState.error("فشل قراءة بيانات الحساب"));
      if (prevLoaded != null) emit(prevLoaded);
    }
  }

  // =========================
  // Avatars
  // =========================
  Future<void> loadAvatars() async {
    final current = state;
    if (current is! _Loaded) return;

    final res = await repo.getAvatars();
    if (!res.ok) return;

    try {
      final raw = res.data;
      if (raw is! Map) return;

      final parsed = AvatarsResponse.fromJson(raw.cast<String, dynamic>());
      emit(current.copyWith(avatars: parsed.data));
    } catch (_) {}
  }

  /// ✅ اختيار avatar (نخزن path مباشرة)
  void selectAvatarPath(String path) {
    final current = state;
    if (current is! _Loaded) return;
    emit(current.copyWith(selectedAvatarPath: path));
  }

  void selectAvatar(AvatarModel avatar) => selectAvatarPath(avatar.path);

  // =========================
  // Save Profile
  // =========================
  Future<void> saveProfile({String? firstName, String? lastName}) async {
    final current = state;
    if (current is! _Loaded) return;

    final fn = (firstName?.trim().isNotEmpty == true)
        ? firstName!.trim()
        : current.user.firstName;

    final ln = (lastName?.trim().isNotEmpty == true)
        ? lastName!.trim()
        : current.user.lastName;

    final avatarPath = current.selectedAvatarPath; // ممكن null

    emit(current.copyWith(isSaving: true, message: null));

    final res = await repo.updateProfile(
      firstName: fn,
      lastName: ln,
      profileImagePath: avatarPath,
    );

    if (!res.ok) {
      emit(current.copyWith(
        isSaving: false,
        message: res.message ?? "فشل التحديث",
      ));
      return;
    }

    // ✅ 1) حدّث الـ user فوراً من response (بدون انتظار load وبدون TTL)
    try {
      final raw = res.data;
      if (raw is Map) {
        final root = raw.cast<String, dynamic>();
        final inner = root["data"];
        final Map<String, dynamic> data =
            (inner is Map) ? inner.cast<String, dynamic>() : root;

        final updatedUser = UserModel.fromJson(data);

        // ✅ خزّن اللوكال فوراً (حتى الدراور يقرأ صح)
        await AuthStorageHelper.saveMeJson(data);

        emit(current.copyWith(
          user: updatedUser,
          // ✅ بعد الحفظ خلّي selectedAvatarPath = null
          // لأنه صار عندنا user.profileImage الجديد من السيرفر
          selectedAvatarPath: null,
          isSaving: false,
          message: "Saved",
        ));
        return;
      }
    } catch (_) {
      // إذا parsing فشل، نكمل للخطة B
    }

    // ✅ 2) خطة B: اجباري reload من السيرفر (تجاهل TTL)
    await load(forceRefresh: true);

    final after = state;
    if (after is _Loaded) {
      emit(after.copyWith(isSaving: false, message: "Saved"));
    }
  }
}
