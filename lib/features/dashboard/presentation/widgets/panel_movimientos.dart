import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/theme.dart';
import '../../data/models/movimiento_caja.dart';
import 'fila_movimiento.dart';
import 'panel_dashboard.dart';

class PanelMovimientos extends StatelessWidget {
  const PanelMovimientos({
    super.key,
    required this.movimientos,
    required this.alVerTodo,
  });

  final List<MovimientoCaja>? movimientos;
  final VoidCallback alVerTodo;

  @override
  Widget build(BuildContext context) {
    final lista = movimientos;
    return PanelDashboard(
      titulo: 'Movimientos recientes',
      accion: _VerTodo(alTocar: alVerTodo),
      hijos: [
        if (lista == null)
          const _Aviso('No disponible')
        else if (lista.isEmpty)
          const _Aviso('Aún no hay movimientos registrados.')
        else
          for (final movimiento in lista)
            FilaMovimiento(movimiento: movimiento),
      ],
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 13, color: textoSecundario),
      ),
    );
  }
}

class _VerTodo extends StatelessWidget {
  const _VerTodo({required this.alTocar});

  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ver todos los movimientos',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: alTocar,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ver todo',
                style: TextStyle(fontSize: 13, color: textoSecundario),
              ),
              SizedBox(width: 4),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: textoSecundario,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
