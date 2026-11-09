import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/format/moneda.dart';
import 'panel_dashboard.dart';

class PanelIngresosEgresos extends StatelessWidget {
  const PanelIngresosEgresos({
    super.key,
    required this.ingresos,
    required this.egresos,
  });

  final num ingresos;
  final num egresos;

  @override
  Widget build(BuildContext context) {
    final mayor = ingresos > egresos ? ingresos : egresos;
    return PanelDashboard(
      titulo: 'Ingresos y egresos',
      hijos: [
        _Barra(
          etiqueta: 'Ingresos',
          valor: ingresos,
          proporcion: mayor > 0 ? (ingresos / mayor).toDouble() : 0,
          color: tintaPrincipal,
        ),
        const SizedBox(height: 16),
        _Barra(
          etiqueta: 'Egresos',
          valor: egresos,
          proporcion: mayor > 0 ? (egresos / mayor).toDouble() : 0,
          color: textoSecundario,
        ),
      ],
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({
    required this.etiqueta,
    required this.valor,
    required this.proporcion,
    required this.color,
  });

  final String etiqueta;
  final num valor;
  final double proporcion;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                etiqueta,
                style: const TextStyle(fontSize: 13, color: textoSecundario),
              ),
            ),
            Text(
              formatearMoneda(valor),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 8,
            width: double.infinity,
            color: superficie,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: proporcion.clamp(0.0, 1.0).toDouble(),
              child: Container(color: color),
            ),
          ),
        ),
      ],
    );
  }
}
