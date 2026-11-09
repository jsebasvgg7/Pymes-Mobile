import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/shell/hoja_inferior.dart';
import '../../../../app/theme.dart';
import '../inventario_controller.dart';

Future<void> mostrarHojaOrden(
  BuildContext context,
  InventarioController controlador,
) {
  return mostrarHojaInferior<void>(
    context: context,
    builder: (hoja) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Ordenar por',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          for (final orden in OrdenInventario.values)
            _FilaOrden(
              orden: orden,
              seleccionada: controlador.orden == orden,
              alTocar: () {
                controlador.ordenar(orden);
                Navigator.of(hoja).pop();
              },
            ),
        ],
      ),
    ),
  );
}

class _FilaOrden extends StatelessWidget {
  const _FilaOrden({
    required this.orden,
    required this.seleccionada,
    required this.alTocar,
  });

  final OrdenInventario orden;
  final bool seleccionada;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: seleccionada,
      label: orden.etiqueta,
      excludeSemantics: true,
      child: InkWell(
        onTap: alTocar,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    orden.etiqueta,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: seleccionada
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (seleccionada)
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedTick02,
                    color: tintaPrincipal,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
