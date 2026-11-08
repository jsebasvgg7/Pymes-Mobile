import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class EncabezadoAuth extends StatelessWidget {
  const EncabezadoAuth({
    super.key,
    required this.titulo,
    required this.subtitulo,
  });

  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitulo,
          style: const TextStyle(
            color: textoSecundario,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
