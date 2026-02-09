import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:flutter/material.dart';

class EmergencyDialog extends StatefulWidget {
  final int orderId;
  const EmergencyDialog({super.key, required this.orderId});

  @override
  State<EmergencyDialog> createState() => _EmergencyDialogState();
}

class _EmergencyDialogState extends State<EmergencyDialog> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();

  String? _selectedKey;

  static const List<_Preset> _presets = [
    _Preset(key: "car", label: "حادث سيارة", icon: Icons.car_crash),
    _Preset(key: "medical", label: "مشكلة صحية", icon: Icons.health_and_safety),
    _Preset(key: "security", label: "مشكلة أمنية", icon: Icons.security),
    _Preset(key: "breakdown", label: "تعطّل الدراجة/السيارة", icon: Icons.build_circle),
    _Preset(key: "other", label: "سبب آخر", icon: Icons.more_horiz),
  ];

  bool get _isOther => _selectedKey == "other";
  bool get _canSend => _ctrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _selectPreset(_Preset p) {
    setState(() {
      _selectedKey = p.key;
      if (p.key == "other") {
        _ctrl.clear();
      } else {
        _ctrl.text = p.label;
      }
    });

    if (p.key == "other") {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (!mounted) return;
        _focus.requestFocus();
      });
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  void _send() {
    final reason = _ctrl.text.trim();
    if (reason.isEmpty) return;
    Navigator.pop(context, reason);
  }

  @override
  Widget build(BuildContext context) {
    final presets = _presets;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: "Cairo"),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.black,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.LightActive.withOpacity(.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.5),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: bottomInset > 0 ? 10 : 0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // HEADER
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(.16),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(.35)),
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "إرسال بلاغ طارئ",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.Dark.withOpacity(.35),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.LightActive.withOpacity(.15),
                                ),
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // DESC
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.Dark.withOpacity(.35),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(.08)),
                        ),
                        child: Text(
                          "الرجاء تحديد سبب البلاغ للطلب رقم #${widget.orderId}.\nسيتم إرسال البلاغ للإدارة فوراً.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(.85),
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // PRESETS TITLE
                      const Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          "اختر السبب",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // PRESETS CHIPS
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: presets.map((p) {
                          final selected = _selectedKey == p.key;

                          return InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => _selectPreset(p),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.red.shade700
                                    : Colors.white.withOpacity(.08),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: selected
                                      ? Colors.red.shade700
                                      : Colors.white.withOpacity(.10),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(p.icon, size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    p.label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12),

                      // INPUT
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(.10)),
                        ),
                        child: TextField(
                          controller: _ctrl,
                          focusNode: _focus,
                          maxLines: 3,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Cairo",
                          ),
                          cursorColor: AppTheme.primary,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: "اكتب سبب البلاغ هنا...",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(.45),
                              fontFamily: "Cairo",
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            prefixIcon: Icon(Icons.edit_note, color: Colors.white.withOpacity(.7)),
                            suffixIcon: _ctrl.text.trim().isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _ctrl.clear();
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.clear, color: Colors.white.withOpacity(.7)),
                                  ),
                          ),
                        ),
                      ),

                      if (_isOther) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            "اكتب السبب بالتفصيل لنقدر نساعدك بسرعة.",
                            style: TextStyle(
                              color: Colors.white.withOpacity(.6),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // ACTIONS
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white.withOpacity(.18)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "إلغاء",
                                style: TextStyle(fontWeight: FontWeight.w900, fontFamily: "Cairo"),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _canSend ? _send : null,
                              icon: const Icon(Icons.send_rounded, size: 18),
                              label: const Text(
                                "إرسال",
                                style: TextStyle(fontWeight: FontWeight.w900, fontFamily: "Cairo"),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.red.withOpacity(.25),
                                disabledForegroundColor: Colors.white.withOpacity(.65),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Preset {
  final String key;
  final String label;
  final IconData icon;
  const _Preset({required this.key, required this.label, required this.icon});
}
