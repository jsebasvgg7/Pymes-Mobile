import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../caja_controller.dart';

class SelectorCajas extends StatelessWidget {
  const SelectorCajas({
    super.key,
    required this.cajas,
    required this.seleccionadaId,
    required this.alElegir,
  });

  final List<CajaVista> cajas;
  final int? seleccionadaId;
  final ValueChanged<int> alElegir;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < cajas.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _ChipCaja(
              caja: cajas[i],
              elegida: cajas[i].cajaId == seleccionadaId,
              alTocar: () => alElegir(cajas[i].cajaId),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChipCaja extends StatelessWidget {
  const _ChipCaja({
    required this.caja,
    required this.elegida,
    required this.alTocar,
  });

  final CajaVista caja;
  final bool elegida;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: elegida,
      label: caja.nombre,
      child: Material(
        color: elegida ? tintaPrincipal : papel,
        shape: StadiumBorder(
          side: BorderSide(color: elegida ? tintaPrincipal : linea),
        ),
        child: InkWell(
          onTap: alTocar,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Text(
              caja.nombre,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: elegida ? papel : tintaPrincipal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
