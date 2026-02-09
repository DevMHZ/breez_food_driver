import 'package:breez_food_driver/core/services/url_helper.dart';
import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:breez_food_driver/core/widgets/custom_appbar_profile.dart';
import 'package:breez_food_driver/core/widgets/custom_button.dart';
import 'package:breez_food_driver/features/home_map/presentation/ui/home_map_screen.dart';
import 'package:breez_food_driver/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:breez_food_driver/features/profile/presentation/widget/custom_textfaild_info.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InfoProfile extends StatefulWidget {
  final ProfileCubit profileCubit;
  const InfoProfile({super.key, required this.profileCubit});

  @override
  State<InfoProfile> createState() => _InfoProfileState();
}

class _InfoProfileState extends State<InfoProfile> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  int _avatarVer = 0;
  bool _didFillOnce = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final st = widget.profileCubit.state;

      st.maybeWhen(
        loaded:
            (user, addresses, avatars, selectedAvatarId, isSaving, message) {
              _fillFromLoadedOnce(st);
            },
        orElse: () => widget.profileCubit.load(),
      );
    });
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _fillFromLoadedOnce(ProfileState state) {
    if (_didFillOnce) return;

    state.maybeWhen(
      loaded: (user, _, __, ___, ____, _____) {
        _firstCtrl.text = user.firstName;
        _lastCtrl.text = user.lastName;
        _phoneCtrl.text = user.phone;
        _didFillOnce = true;
      },
      orElse: () {},
    );
  }

  ImageProvider _avatarImageProvider(ProfileState state) {
    final selectedPath = state.maybeWhen(
      loaded: (_, __, ___, selectedAvatarPath, ____, _____) =>
          selectedAvatarPath,
      orElse: () => null,
    );

    final serverPath = state.maybeWhen(
      loaded: (user, _, __, ___, ____, _____) => user.profileImage,
      orElse: () => null,
    );

    final raw = (selectedPath != null && selectedPath.trim().isNotEmpty)
        ? selectedPath
        : serverPath;

    final full = UrlHelper.toFullUrl(raw);
    if (full != null && full.isNotEmpty) {
      final busted = "$full?v=$_avatarVer";
      return CachedNetworkImageProvider(busted);
    }

    return const AssetImage('assets/images/person.jpg');
  }

  Future<void> _openAvatarPicker(ProfileState state) async {
    final avatarsEmpty = state.maybeWhen(
      loaded: (_, __, avatars, ___, ____, _____) => avatars.isEmpty,
      orElse: () => true,
    );

    if (avatarsEmpty) {
      await widget.profileCubit.loadAvatars();
      if (!mounted) return;
    }

    final latestState = widget.profileCubit.state;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.Dark,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: latestState.maybeWhen(
            loaded:
                (
                  user,
                  addresses,
                  avatars,
                  selectedAvatarPath,
                  isSaving,
                  message,
                ) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'اختر صورة شخصية',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      if (avatars.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: avatars.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemBuilder: (_, i) {
                            final av = avatars[i];
                            final selected = selectedAvatarPath == av.path;

                            return GestureDetector(
                              onTap: () async {
                                widget.profileCubit.selectAvatar(av);

                                final full = UrlHelper.toFullUrl(av.path);
                                if (full != null && full.isNotEmpty) {
                                  await CachedNetworkImage.evictFromCache(full);
                                }

                                if (mounted) {
                                  setState(() {
                                    _avatarVer =
                                        DateTime.now().millisecondsSinceEpoch;
                                  });
                                }

                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? AppTheme.LightActive
                                        : Colors.white24,
                                    width: selected ? 3 : 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white10,
                                  backgroundImage: av.fullUrl.isNotEmpty
                                      ? NetworkImage(av.fullUrl)
                                      : const AssetImage(
                                          'assets/images/person.jpg',
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
            orElse: () => Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ),
    );
  }

  bool _validate() {
    if (_firstCtrl.text.trim().isEmpty || _lastCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("رجاءً أدخل الاسم والكنية"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // ✅ RTL دائمًا
      textDirection: TextDirection.rtl,
      child: BlocConsumer<ProfileCubit, ProfileState>(
        bloc: widget.profileCubit,
        listener: (context, state) {
          _fillFromLoadedOnce(state);

          final msg = state.maybeWhen(
            loaded: (_, __, ___, ____, _____, message) => message,
            orElse: () => null,
          );

          if (msg != null && msg.trim().isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
            );
          }
        },
        builder: (context, state) {
          final isSaving = state.maybeWhen(
            loaded: (_, __, ___, ____, isSaving, _____) => isSaving,
            orElse: () => false,
          );

          return Scaffold(
            backgroundColor: AppTheme.Dark,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(60.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CustomAppbarProfile(
                  title: "الملف الشخصي",
                  icon: Icons.arrow_back_ios,
                  ontap: () => Navigator.pop(context),
                ),
              ),
            ),
            body: state.maybeWhen(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (msg) => Center(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.h),
                      TextButton(
                        onPressed: () => widget.profileCubit.load(),
                        child: const Text(
                          "إعادة المحاولة",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              loaded: (_, __, ___, ____, _____, ______) {
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomLeft, // لأن RTL
                          children: [
                            CircleAvatar(
                              radius: 70.r,
                              backgroundImage: _avatarImageProvider(state),
                            ),
                            GestureDetector(
                              onTap: () => _openAvatarPicker(state),
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: AppTheme.Dark,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.LightActive,
                                    width: 1.w,
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/edit.svg",
                                  width: 18.w,
                                  height: 18.h,
                                  colorFilter: const ColorFilter.mode(
                                    AppTheme.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 35.h),

                        CustomTextfaildInfo(
                          label: "الاسم",
                          hint: "مثال: محمد",
                          controller: _firstCtrl,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 15.h),

                        CustomTextfaildInfo(
                          label: "الكنية",
                          hint: "مثال: أحمد",
                          controller: _lastCtrl,
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 15.h),

                        CustomTextfaildInfo(
                          label: "رقم الهاتف",
                          hint: "09xxxxxxxx",
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 30.h),

                   CustomButton(
  title: isSaving ? "جارٍ الحفظ..." : "حفظ",
  onPressed: isSaving
      ? null
      : () async {
          if (!_validate()) return;

          await widget.profileCubit.saveProfile(
            firstName: _firstCtrl.text.trim(),
            lastName: _lastCtrl.text.trim(),
          );

          // ✅ امسح كاش الصورة (اختياري)
          final st = widget.profileCubit.state;
          final serverPath = st.maybeWhen(
            loaded: (user, _, __, ___, ____, _____) => user.profileImage,
            orElse: () => null,
          );

          final full = UrlHelper.toFullUrl(serverPath);
          if (full != null && full.isNotEmpty) {
            await CachedNetworkImage.evictFromCache(full);
          }

          if (!mounted) return;

          // ✅ ارجع ومعك true
          Navigator.pop(context, true);
        },
)

                      ],
                    ),
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
