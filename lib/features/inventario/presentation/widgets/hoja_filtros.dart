import 'package:flutter/material.dart';

import '../../../../app/shell/hoja_inferior.dart';
import '../../../../app/theme.dart';
import '../inventario_controller.dart';
import 'opcion_chip.dart';

Future<void> mostrarHojaFiltros(
  BuildContext context,
  InventarioController controlador,
) {
  return mostrarHojaInferior<void>(
    context: context,
    builder: (hoja) => ListenableBuilder(
      listenable: controlador,
      builder: (_, _) => _ContenidoFiltros(
        controlador: controlador,
        alCerrar: () => Navigator.of(hoja).pop(),
      ),
    ),
  );
}

class _ContenidoFiltros extends StatelessWidget {
  const _ContenidoFiltros({required this.controlador, required this.alCerrar});

  final InventarioController controlador;
  final VoidCallback alCerrar;

  @override
  Widget build(BuildContext context) {
    final cantidad = controlador.visibles.length;
    final hayFiltrosDeHoja =
        controlador.filtro != FiltroStock.todos ||
        controlador.categoria != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Etiqueta('Estado'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final filtro in FiltroStock.values)
                        OpcionChip(
                          etiqueta: filtro.etiqueta,
                          seleccionada: controlador.filtro == filtro,
                          alTocar: () => controlador.filtrar(filtro),
                        ),
                    ],
                  ),
                  if (controlador.categorias.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const _Etiqueta('Categoría'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OpcionChip(
                          etiqueta: 'Todas',
                          seleccionada: controlador.categoria == null,
                          alTocar: () => controlador.elegirCategoria(null),
                        ),
                        for (final categoria in controlador.categorias)
                          OpcionChip(
                            etiqueta: categoria,
                            seleccionada: controlador.categoria == categoria,
                            alTocar: () =>
                                controlador.elegirCategoria(categoria),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: hayFiltrosDeHoja
                      ? () {
                          controlador.filtrar(FiltroStock.todos);
                          controlador.elegirCategoria(null);
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    foregroundColor: tintaPrincipal,
                    side: const BorderSide(color: linea),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: alCerrar,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Ver $cantidad ${cantidad == 1 ? 'producto' : 'productos'}',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textoSecundario,
      ),
    );
  }
}
