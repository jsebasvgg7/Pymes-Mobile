import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../navegacion/destino.dart';
import '../theme.dart';

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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 64,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: superficie,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: linea),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final destino in destinos)
                      _ItemBarra(
                        destino: destino,
                        activo: destino.id == activoId,
                        alTocar: () => alTocarDestino(destino),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Semantics(
              button: true,
              label: 'Más opciones',
              child: Material(
                color: tintaPrincipal,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: alTocarMas,
                  child: const SizedBox(
                    width: 56,
                    height: 56,
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
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: activo ? papel : Colors.transparent,
            border: activo ? Border.all(color: linea) : null,
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
