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
    final codigo = movimiento.codigo;
    final detalle = [
      if (movimiento.cajaNombre.isNotEmpty) movimiento.cajaNombre,
      ?codigo,
    ].join(' · ');
    final signo = movimiento.esIngreso ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movimiento.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (detalle.isNotEmpty) ...[
                  const SizedBox(height: 2),
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
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$signo${formatearMoneda(movimiento.monto)}',
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (fecha != null) ...[
                const SizedBox(height: 2),
                Text(
                  etiquetaMovimiento(fecha, DateTime.now()),
                  maxLines: 1,
                  style: const TextStyle(fontSize: 12, color: textoSecundario),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
