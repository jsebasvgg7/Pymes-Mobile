import 'package:flutter/material.dart';

import '../../app/theme.dart';

class EstadoCarga extends StatelessWidget {
  const EstadoCarga({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: tintaPrincipal),
      ),
    );
  }
}
