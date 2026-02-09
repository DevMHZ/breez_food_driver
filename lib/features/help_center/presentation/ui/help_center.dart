import 'package:breez_food_driver/core/di/di.dart';
import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:breez_food_driver/features/help_center/data/model/help_center_models.dart';
import 'package:breez_food_driver/features/help_center/presentation/cubit/help_center_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpCenter extends StatefulWidget {
  const HelpCenter({super.key});

  @override
  State<HelpCenter> createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  late final HelpCenterCubit cubit;
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  int _lastMsgCount = 0;

  @override
  void initState() {
    super.initState();
    cubit = getIt<HelpCenterCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) => cubit.load());
  }

  @override
  void dispose() {
    cubit.close();
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent + 200,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HelpCenterCubit, HelpCenterState>(
      bloc: cubit,
      listenWhen: (prev, curr) {
        final prevLen = prev.ticket?.messages.length ?? 0;
        final currLen = curr.ticket?.messages.length ?? 0;
        return currLen != prevLen;
      },
      listener: (context, state) {
        final currLen = state.ticket?.messages.length ?? 0;
        if (currLen > _lastMsgCount) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
        }
        _lastMsgCount = currLen;
      },
      builder: (context, state) {
        final ticket = state.ticket;
        final msgs = ticket?.messages ?? const <TicketMessageModel>[];

        return Scaffold(
          backgroundColor: AppTheme.Dark,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(
                  title: "help_center.title".tr(),
                  onClose: () => Navigator.pop(context),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.black.withOpacity(0.35),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18.r),
                      ),
                    ),
                    child: _Body(
                      state: state,
                      msgs: msgs,
                      scrollCtrl: _scrollCtrl,
                    ),
                  ),
                ),

                _InputBar(
                  controller: _ctrl,
                  sending: state.sending,
                  onSend: (text) async {
                    await cubit.send(text);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _TopBar({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: Row(
        children: [
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              height: 40.h,
              width: 40.h,
              decoration: BoxDecoration(
                color: AppTheme.black,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppTheme.LightActive, width: 1),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppTheme.white,
                size: 18.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final HelpCenterState state;
  final List<TicketMessageModel> msgs;
  final ScrollController scrollCtrl;

  const _Body({
    required this.state,
    required this.msgs,
    required this.scrollCtrl,
  });

  @override
  Widget build(BuildContext context) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            state.error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontSize: 13.sp),
          ),
        ),
      );
    }
    if (msgs.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            "help_center.no_messages".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.white.withOpacity(0.7),
              fontSize: 13.sp,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollCtrl,
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 12.h),
      itemCount: msgs.length,
      itemBuilder: (context, index) {
        final msg = msgs[index];

        // عدّل حسب API: مين "أنا"؟
        final isMe = msg.senderType == "customer";

        return _ChatBubble(
          isMe: isMe,
          message: msg.message,
          time: _formatTime(msg.createdAt),
        );
      },
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return "common.time_unknown".tr();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
}

class _ChatBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String time;

  const _ChatBubble({
    required this.isMe,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width * 0.78;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[_MiniAvatar(isMe: false), SizedBox(width: 8.w)],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primary : AppTheme.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
                  bottomRight: Radius.circular(isMe ? 4.r : 16.r),
                ),
                border: Border.all(
                  color: isMe
                      ? AppTheme.primary.withOpacity(0.35)
                      : AppTheme.white.withOpacity(0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 13.sp,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    time,
                    style: TextStyle(
                      color: AppTheme.white.withOpacity(0.75),
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[SizedBox(width: 8.w), _MiniAvatar(isMe: true)],
        ],
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  final bool isMe;

  const _MiniAvatar({required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.r,
      width: 32.r,
      decoration: BoxDecoration(
        color: isMe
            ? AppTheme.primary.withOpacity(0.18)
            : AppTheme.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isMe
              ? AppTheme.primary.withOpacity(0.35)
              : AppTheme.white.withOpacity(0.10),
        ),
      ),
      child: Icon(
        isMe ? Icons.person : Icons.support_agent,
        color: isMe ? AppTheme.primary : AppTheme.white,
        size: 18.sp,
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final ValueChanged<String> onSend;

  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom; // keyboard

    return AnimatedPadding(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(
        12.w,
        10.h,
        12.w,
        12.h + (bottomPad > 0 ? 0 : 0),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppTheme.black,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppTheme.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(fontSize: 14.sp, color: AppTheme.white),
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "help_center.message_hint".tr(),
                  hintStyle: TextStyle(
                    color: AppTheme.white.withOpacity(0.55),
                    fontSize: 13.sp,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 8.h,
                  ),
                ),
                onSubmitted: sending
                    ? null
                    : (_) {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        controller.clear();
                        onSend(text);
                      },
              ),
            ),
            SizedBox(width: 8.w),
            InkWell(
              onTap: sending
                  ? null
                  : () {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;
                      controller.clear();
                      onSend(text);
                    },
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                height: 42.h,
                width: 42.h,
                decoration: BoxDecoration(
                  color: sending
                      ? AppTheme.white.withOpacity(0.08)
                      : AppTheme.primary,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  sending ? Icons.hourglass_top : Icons.send_rounded,
                  color: sending
                      ? AppTheme.white.withOpacity(0.7)
                      : AppTheme.black,
                  size: 18.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
