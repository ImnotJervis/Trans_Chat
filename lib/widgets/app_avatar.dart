import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  final IconData fallback;
  final Color? bg;

  const AppAvatar({
    super.key,
    required this.url,
    this.radius = 22,
    this.fallback = Icons.person,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    // 여백 살짝: 카카오톡 느낌 + 프레임 여유
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg ?? Colors.grey.shade200,
      backgroundImage: (url != null && url!.isNotEmpty)
          ? NetworkImage(url!)
          : null,
      child: (url == null || url!.isEmpty)
          ? Icon(fallback, color: Colors.grey.shade600, size: radius)
          : null,
    );
  }
}
