import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/theme.dart';

class AvisoCaja extends StatelessWidget {
  const AvisoCaja({
    super.key,
    required this.titulo,
    required this.mensaje,
    required this.color,
    this.resaltado = false,
  });

  final String titulo;
  final String mensaje;
  final Color color;
  final bool resaltado;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: resaltado ? color.withValues(alpha: 0.08) : papel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: resaltado ? color.withValues(alpha: 0.3) : linea,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedAlert02,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mensaje,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: textoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
