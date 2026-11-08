import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/format/moneda.dart';
import '../../data/models/dashboard_resumen.dart';
import 'panel_dashboard.dart';

class PanelCajas extends StatelessWidget {
  const PanelCajas({super.key, required this.cajas});

  final List<CajaResumen> cajas;

  @override
  Widget build(BuildContext context) {
    return PanelDashboard(
      titulo: 'Cajas',
      hijos: cajas.isEmpty
          ? const [
              Text(
                'Aún no hay cajas registradas.',
                style: TextStyle(fontSize: 14, color: textoSecundario),
              ),
            ]
          : [
              for (final caja in cajas)
                FilaPanel(
                  etiqueta: caja.nombre.isEmpty ? 'Caja' : caja.nombre,
                  valor: formatearMoneda(caja.saldoActual),
                ),
            ],
    );
  }
}
