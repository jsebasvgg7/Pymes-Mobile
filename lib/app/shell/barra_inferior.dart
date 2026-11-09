import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../navegacion/destino.dart';
import '../theme.dart';

const List<BoxShadow> _sombra = [
  BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
];

class BarraInferior extends StatelessWidget {
  const BarraInferior({
    super.key,
    required this.destinos,
    required this.activoId,
    required this.alTocarDestino,
    required this.alTocarMas,
  });

  final List<Destino> destinos;
  final String? activoId;
  final ValueChanged<Destino> alTocarDestino;
  final VoidCallback alTocarMas;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: papel,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: linea),
                boxShadow: _sombra,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < destinos.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    _ItemBarra(
                      destino: destinos[i],
                      activo: destinos[i].id == activoId,
                      alTocar: () => alTocarDestino(destinos[i]),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Semantics(
              button: true,
              label: 'Más opciones',
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: _sombra,
                ),
                child: Material(
                  color: tintaPrincipal,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: alTocarMas,
                    child: const SizedBox(
                      width: 52,
                      height: 52,
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedAdd01,
                          color: papel,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemBarra extends StatelessWidget {
  const _ItemBarra({
    required this.destino,
    required this.activo,
    required this.alTocar,
  });

  final Destino destino;
  final bool activo;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: activo,
      label: destino.nombre,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: alTocar,
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: activo ? superficie : Colors.transparent,
          ),
          child: HugeIcon(
            icon: destino.icono,
            color: activo ? tintaPrincipal : textoSecundario,
            size: 24,
          ),
        ),
      ),
    );
  }
}
