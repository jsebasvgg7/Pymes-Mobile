import 'package:flutter/material.dart';

import '../navegacion/abrir_destino.dart';
import '../navegacion/destino.dart';
import '../navegacion/destinos.dart';
import 'fila_destino.dart';
import 'hoja_inferior.dart';

Future<void> mostrarHojaAdministracion(BuildContext context) {
  return mostrarHojaInferior<void>(
    context: context,
    builder: (hoja) => ListaDestinos(
      titulo: 'Administración',
      grupos: [GrupoLista(null, destinosDe(GrupoDestino.administracion))],
      alElegir: (destino) {
        Navigator.of(hoja).pop();
        abrirDestino(context, destino);
      },
    ),
  );
}
