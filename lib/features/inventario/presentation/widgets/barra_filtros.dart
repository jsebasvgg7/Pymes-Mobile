import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/theme.dart';

class BarraFiltros extends StatelessWidget {
  const BarraFiltros({
    super.key,
    required this.campo,
    required this.alBuscar,
    required this.alFiltrar,
    required this.alOrdenar,
    required this.filtrosActivos,
  });

  final TextEditingController campo;
  final ValueChanged<String> alBuscar;
  final VoidCallback alFiltrar;
  final VoidCallback alOrdenar;
  final bool filtrosActivos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(child: _CampoBusqueda(campo: campo, alCambiar: alBuscar)),
          const SizedBox(width: 8),
          _BotonIcono(
            etiqueta: 'Filtrar',
            icono: HugeIcons.strokeRoundedFilterHorizontal,
            marcado: filtrosActivos,
            alTocar: alFiltrar,
          ),
          const SizedBox(width: 8),
          _BotonIcono(
            etiqueta: 'Ordenar',
            icono: HugeIcons.strokeRoundedArrowUpDown,
            alTocar: alOrdenar,
          ),
        ],
      ),
    );
  }
}

class _CampoBusqueda extends StatelessWidget {
  const _CampoBusqueda({required this.campo, required this.alCambiar});

  final TextEditingController campo;
  final ValueChanged<String> alCambiar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: papel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: linea),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const HugeIcon(
            icon: HugeIcons.strokeRoundedSearch01,
            color: textoSecundario,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: campo,
              onChanged: alCambiar,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 15),
              cursorColor: tintaPrincipal,
              decoration: const InputDecoration(
                hintText: 'Producto, SKU o categoría',
                hintStyle: TextStyle(fontSize: 15, color: textoSecundario),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: campo,
            builder: (_, valor, _) {
              if (valor.text.isEmpty) return const SizedBox(width: 16);
              return Semantics(
                button: true,
                label: 'Borrar búsqueda',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    campo.clear();
                    alCambiar('');
                  },
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: textoSecundario,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BotonIcono extends StatelessWidget {
  const _BotonIcono({
    required this.etiqueta,
    required this.icono,
    required this.alTocar,
    this.marcado = false,
  });

  final String etiqueta;
  final List<List<dynamic>> icono;
  final VoidCallback alTocar;
  final bool marcado;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: etiqueta,
      excludeSemantics: true,
      child: Material(
        color: papel,
        shape: const CircleBorder(side: BorderSide(color: linea)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: alTocar,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                HugeIcon(icon: icono, color: tintaPrincipal, size: 22),
                if (marcado)
                  Positioned(
                    top: 11,
                    right: 11,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: tintaPrincipal,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
