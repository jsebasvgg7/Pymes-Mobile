import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class PildoraEstadoCaja extends StatelessWidget {
  const PildoraEstadoCaja({
    super.key,
    required this.abierta,
    required this.cierrePendiente,
  });

  final bool abierta;
  final bool cierrePendiente;

  String get _texto {
    if (cierrePendiente) return 'Cierre pendiente';
    return abierta ? 'Caja abierta' : 'Caja cerrada';
  }

  Color get _color {
    if (cierrePendiente) return atencion;
    return abierta ? positivo : textoSecundario;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            _texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
