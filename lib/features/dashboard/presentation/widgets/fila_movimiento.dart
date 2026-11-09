import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/theme.dart';
import '../../../../core/format/fecha.dart';
import '../../../../core/format/moneda.dart';
import '../../data/models/movimiento_caja.dart';

class FilaMovimiento extends StatelessWidget {
  const FilaMovimiento({super.key, required this.movimiento});

  final MovimientoCaja movimiento;

  @override
  Widget build(BuildContext context) {
    final fecha = movimiento.fecha;
    final detalle = [
      if (movimiento.cajaNombre.isNotEmpty) movimiento.cajaNombre,
      if (fecha != null) etiquetaMovimiento(fecha, DateTime.now()),
    ].join(' · ');
    final signo = movimiento.esIngreso ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: superficie,
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: movimiento.esIngreso
                  ? HugeIcons.strokeRoundedArrowDownLeft01
                  : HugeIcons.strokeRoundedArrowUpRight01,
              color: tintaPrincipal,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movimiento.concepto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (detalle.isNotEmpty)
                  Text(
                    detalle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textoSecundario,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$signo${formatearMoneda(movimiento.monto)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
