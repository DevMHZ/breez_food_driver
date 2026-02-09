import 'package:breez_food_driver/core/di/di.dart';
import 'package:breez_food_driver/core/services/url_helper.dart';
import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:breez_food_driver/core/widgets/language_dialog.dart';
import 'package:breez_food_driver/core/widgets/logout_dialog.dart';
import 'package:breez_food_driver/features/auth/data/repo/auth_repository.dart';
import 'package:breez_food_driver/features/auth/presentation/cubit/auth_flow_cubit.dart';
import 'package:breez_food_driver/features/auth/presentation/ui/login_page.dart';
import 'package:breez_food_driver/features/earnings/presentation/cubit/earnings_cubit.dart';
import 'package:breez_food_driver/features/earnings/presentation/ui/earning_main_screen.dart';
import 'package:breez_food_driver/features/help_center/presentation/ui/help_center.dart';
import 'package:breez_food_driver/features/help_center/presentation/cubit/help_center_cubit.dart';
import 'package:breez_food_driver/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:breez_food_driver/features/profile/presentation/ui/info_profile.dart';
import 'package:breez_food_driver/features/terms/presentation/ui/terms.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart'; // PaintingBinding

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<void> _showLogoutDialog(BuildContext context) async {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return LogoutDialog(
          onLogoutConfirmed: () async {
            Navigator.of(dialogCtx).pop();

            final repo = getIt<AuthRepository>();
            final service = LogoutService(repo);

            await service.logoutAndRedirect(
              context,
              loginBuilder: () => const Login(),
              onMessage: (msg) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(msg)));
              },
            );
          },
          onCancel: () => Navigator.of(dialogCtx).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppTheme.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const _DrawerHeader(),

            _buildDrawerSection(
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  title: "drawer.personal_info".tr(),
                  onTap: () async {
                    final stBefore = context.read<ProfileCubit>().state;

                    final oldPath = stBefore.whenOrNull(
                      loaded: (user, _, __, ___, ____, _____) =>
                          user.profileImage,
                    );

                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => InfoProfile(
                          profileCubit: context.read<ProfileCubit>(),
                        ),
                      ),
                    );

                    if (changed == true) {
                      final oldUrl = UrlHelper.toFullUrl(oldPath);
                      if (oldUrl != null && oldUrl.isNotEmpty) {
                        await CachedNetworkImage.evictFromCache(oldUrl);
                        PaintingBinding.instance.imageCache.evict(
                          NetworkImage(oldUrl),
                        );
                      }

                      await context.read<ProfileCubit>().load();

                      final stAfter = context.read<ProfileCubit>().state;
                      final newPath = stAfter.whenOrNull(
                        loaded: (user, _, __, ___, ____, _____) =>
                            user.profileImage,
                      );

                      final newUrl = UrlHelper.toFullUrl(newPath);
                      if (newUrl != null && newUrl.isNotEmpty) {
                        await CachedNetworkImage.evictFromCache(newUrl);
                        PaintingBinding.instance.imageCache.evict(
                          NetworkImage(newUrl),
                        );
                      }
                    }
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.monetization_on_outlined,
                  title: "drawer.earning".tr(),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) => getIt<EarningsCubit>(),
                          child: EarningMainScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ],
              color: AppTheme.primary,
            ),

            const SizedBox(height: 12),

            _buildDrawerSection(
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: "drawer.help_center".tr(),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) => getIt<HelpCenterCubit>(),
                          child: HelpCenter(),
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: "drawer.terms".tr(),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => Terms()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: "drawer.logout".tr(),
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.body16(context),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white70,
        size: 18,
      ),
      onTap: onTap,
    );
  }

  static Widget _buildDrawerSection({
    required List<Widget> children,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(children: children),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      color: AppTheme.background,
      child: Column(
        children: [
          Text(
            "drawer.profile_title".tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final user = state.whenOrNull(
                loaded:
                    (
                      user,
                      addresses,
                      avatars,
                      selectedAvatarPath,
                      isSaving,
                      message,
                    ) => user,
              );

              final first = (user?.firstName ?? '').trim();
              final last = (user?.lastName ?? '').trim();
              final fullName = ('$first $last').trim();

              final name = fullName.isNotEmpty
                  ? fullName
                  : "drawer.profile_name_fallback".tr();

              final imagePath = user?.profileImage?.toString();

              return Column(
                children: [
                  _ProfileAvatar(imagePath: imagePath),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? imagePath;
  const _ProfileAvatar({required this.imagePath});

  static const String _host = "https://breezefood.cloud/";

  String? _resolveImageUrl(String? raw) {
    if (raw == null) return null;
    final v = raw.trim();
    if (v.isEmpty) return null;
    if (v.startsWith("http://") || v.startsWith("https://")) return v;
    final cleaned = v.startsWith("/") ? v.substring(1) : v;
    return "$_host$cleaned";
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolveImageUrl(imagePath);
    final hasImage = url != null && url.isNotEmpty;

    // ✅ version ثابت = يتغير لما تتغير قيمة profileImage
    // (هيك ما منعمل request جديد كل build)
    final ver = (imagePath ?? '').hashCode;
    final bustedUrl = hasImage ? "$url?v=$ver" : null;

    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.white,
      backgroundImage: bustedUrl != null
          ? CachedNetworkImageProvider(
              bustedUrl,
              // cacheKey: bustedUrl, // اختياري
            )
          : null,
      child: hasImage
          ? null
          : const Icon(
              Icons.account_circle,
              size: 80,
              color: Color(0xFFC4C4C4),
            ),
    );
  }
}
