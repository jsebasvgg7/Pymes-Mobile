import 'package:flutter/material.dart';

import 'panel_dashboard.dart';

class PanelStock extends StatelessWidget {
  const PanelStock({
    super.key,
    required this.stockBajo,
    required this.sinStock,
  });

  final int stockBajo;
  final int sinStock;

  @override
  Widget build(BuildContext context) {
    return PanelDashboard(
      titulo: 'Stock',
      hijos: [
        FilaPanel(etiqueta: 'Productos con stock bajo', valor: '$stockBajo'),
        FilaPanel(etiqueta: 'Productos sin stock', valor: '$sinStock'),
      ],
    );
  }
}
