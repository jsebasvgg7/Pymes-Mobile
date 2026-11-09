import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class OpcionChip extends StatelessWidget {
  const OpcionChip({
    super.key,
    required this.etiqueta,
    required this.seleccionada,
    required this.alTocar,
  });

  final String etiqueta;
  final bool seleccionada;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: seleccionada,
      label: etiqueta,
      excludeSemantics: true,
      child: Material(
        color: seleccionada ? tintaPrincipal : papel,
        shape: StadiumBorder(
          side: BorderSide(color: seleccionada ? tintaPrincipal : linea),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: alTocar,
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                widthFactor: 1,
                child: Text(
                  etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: seleccionada ? papel : tintaPrincipal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
