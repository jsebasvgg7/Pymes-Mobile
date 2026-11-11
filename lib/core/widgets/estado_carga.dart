import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'carga_marca.dart';

class EstadoCarga extends StatelessWidget {
  const EstadoCarga({super.key, this.tamano = 64, this.mensaje});

  final double tamano;
  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 7),
        CargaMarca(tamano: tamano),
        if (mensaje != null) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              mensaje!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: textoSecundario,
              ),
            ),
          ),
        ],
        const Spacer(flex: 13),
      ],
    );
  }
}
