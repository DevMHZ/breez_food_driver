import 'package:flutter/material.dart';

class TrackingTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;

  const TrackingTopBar({
    super.key,
    required this.onBack,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          backgroundColor: Colors.black,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: onBack,
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.black,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
          ),
        ),
      ],
    );
  }
}
