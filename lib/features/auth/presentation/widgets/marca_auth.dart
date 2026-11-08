import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class MarcaAuth extends StatelessWidget {
  const MarcaAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Align(
          widthFactor: 0.56,
          child: SizedBox(
            width: 48,
            height: 48,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                tintaPrincipal,
                BlendMode.srcIn,
              ),
              child: Image.asset('assets/icon/icon_foreground.png'),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Pymes ERP',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}
