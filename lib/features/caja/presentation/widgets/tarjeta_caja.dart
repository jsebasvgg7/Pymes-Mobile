import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class TarjetaCaja extends StatelessWidget {
  const TarjetaCaja({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: papel,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: tintaPrincipal.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
