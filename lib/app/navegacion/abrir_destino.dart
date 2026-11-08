import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme.dart';
import 'destino.dart';

void abrirDestino(BuildContext context, Destino destino) {
  final ruta = destino.ruta;
  if (ruta != null) {
    context.go(ruta);
    return;
  }
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '${destino.nombre}: próximamente',
          style: const TextStyle(color: papel),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: tintaPrincipal,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
}
