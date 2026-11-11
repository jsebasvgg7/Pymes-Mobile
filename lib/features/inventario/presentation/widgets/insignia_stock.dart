import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/productos/producto_inventario.dart';

String etiquetaEstadoStock(EstadoStock estado) {
  return switch (estado) {
    EstadoStock.disponible => 'Disponible',
    EstadoStock.bajo => 'Stock bajo',
    EstadoStock.agotado => 'Sin stock',
  };
}

Color colorEstadoStock(EstadoStock estado) {
  return switch (estado) {
    EstadoStock.disponible => positivo,
    EstadoStock.bajo => atencion,
    EstadoStock.agotado => negativo,
  };
}

class InsigniaStock extends StatelessWidget {
  const InsigniaStock({super.key, required this.estado});

  final EstadoStock estado;

  @override
  Widget build(BuildContext context) {
    final color = colorEstadoStock(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        etiquetaEstadoStock(estado),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
