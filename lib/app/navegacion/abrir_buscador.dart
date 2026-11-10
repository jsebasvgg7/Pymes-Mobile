import 'package:flutter/material.dart';

import '../shell/buscador_page.dart';
import 'abrir_destino.dart';

Future<void> abrirBuscador(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (_) => BuscadorPage(
        alElegir: (destino) => abrirDestino(context, destino),
      ),
    ),
  );
}
