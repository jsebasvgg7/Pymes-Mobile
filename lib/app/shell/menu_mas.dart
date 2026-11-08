import 'package:flutter/material.dart';

import '../navegacion/abrir_destino.dart';
import '../navegacion/destino.dart';
import '../navegacion/destinos.dart';
import 'fila_destino.dart';
import 'hoja_inferior.dart';

Future<void> mostrarMenuMas(BuildContext context) {
  return mostrarHojaInferior<void>(
    context: context,
    builder: (hoja) => ListaDestinos(
      titulo: 'Más opciones',
      grupos: [
        GrupoLista('Operación', destinosDe(GrupoDestino.operacion)),
        GrupoLista('Catálogo', destinosDe(GrupoDestino.catalogo)),
      ],
      alElegir: (destino) {
        Navigator.of(hoja).pop();
        abrirDestino(context, destino);
      },
    ),
  );
}
