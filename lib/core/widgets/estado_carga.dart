import 'package:flutter/material.dart';

import 'carga_marca.dart';

class EstadoCarga extends StatelessWidget {
  const EstadoCarga({super.key, this.tamano = 64});

  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 7),
        CargaMarca(tamano: tamano),
        const Spacer(flex: 13),
      ],
    );
  }
}
