import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderCodeDialog extends StatefulWidget {
  const OrderCodeDialog({super.key});

  @override
  State<OrderCodeDialog> createState() => _OrderCodeDialogState();
}

class _OrderCodeDialogState extends State<OrderCodeDialog> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  bool get _isComplete => _controllers.every((c) => c.text.trim().isNotEmpty);

  String get _code => _controllers.map((c) => c.text.trim()).join();

  void _submit() {
    if (!_isComplete) return;
    Navigator.of(context).pop(_code);
  }

  Widget _codeBox(int index) {
    final isFocused = _focusNodes[index].hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused ? AppTheme.primary : Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (v.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
        onSubmitted: (_) {
          if (index == 3 && _isComplete) _submit();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔐 عنوان
            const Text(
              "رمز تأكيد الطلب",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),

            // 📝 وصف
            Text(
              "أدخل الرمز المكوّن من 4 أرقام الموجود لدى الزبون",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 24),

            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, _codeBox),
              ),
            ),

            const SizedBox(height: 28),

            // ✅ زر التأكيد
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isComplete ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isComplete
                      ? AppTheme.primary
                      : Colors.grey.shade700,
                  disabledBackgroundColor: Colors.grey.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "تأكيد الرمز",
                  style: TextStyle(
                    color: _isComplete
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
