import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageDialog {
  static Future<void> show(BuildContext context) async {
    final current = context.locale;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return _LanguageSheet(current: current);
      },
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  final Locale current;
  const _LanguageSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    final isAr = current.languageCode == 'ar';

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 8),
            color: Colors.black54,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // handle صغير
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),

            Row(
              children: [
                const Icon(Icons.translate, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  isAr ? 'اختيار اللغة' : 'Choose language',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),

            const SizedBox(height: 6),

            _LangTile(
              title: 'العربية',
              selected: isAr,
              onTap: () async {
                await context.setLocale(const Locale('ar'));
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _LangTile(
              title: 'English',
              selected: !isAr,
              onTap: () async {
                await context.setLocale(const Locale('en'));
                if (context.mounted) Navigator.pop(context);
              },
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _LangTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white10 : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? Colors.white24 : Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? Colors.greenAccent : Colors.white54,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
