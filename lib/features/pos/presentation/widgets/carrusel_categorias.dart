import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/theme.dart';
import '../../data/icono_categoria.dart';
import '../../data/models/categoria_pos.dart';

class CarruselCategorias extends StatelessWidget {
  const CarruselCategorias({
    super.key,
    required this.categorias,
    required this.categoriaElegida,
    required this.alElegir,
  });

  final List<CategoriaPos> categorias;
  final int? categoriaElegida;
  final ValueChanged<int?> alElegir;

  @override
  Widget build(BuildContext context) {
    if (categorias.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categorias.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 13),
        itemBuilder: (context, indice) {
          if (indice == 0) {
            return _BotonCategoria(
              nombre: 'Todos',
              icono: HugeIcons.strokeRoundedGrid,
              activo: categoriaElegida == null,
              alTocar: () => alElegir(null),
            );
          }
          final categoria = categorias[indice - 1];
          return _BotonCategoria(
            nombre: categoria.nombre,
            icono: iconoCategoria(categoria.nombre, clave: categoria.icono),
            activo: categoriaElegida == categoria.id,
            alTocar: () => alElegir(categoria.id),
          );
        },
      ),
    );
  }
}

class _BotonCategoria extends StatelessWidget {
  const _BotonCategoria({
    required this.nombre,
    required this.icono,
    required this.activo,
    required this.alTocar,
  });

  final String nombre;
  final List<List<dynamic>> icono;
  final bool activo;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: activo,
      label: 'Categoría $nombre',
      child: GestureDetector(
        onTap: alTocar,
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: superficie,
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: icono,
                color: tintaPrincipal,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              nombre,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.2,
                fontWeight: activo ? FontWeight.w600 : FontWeight.w400,
                color: activo ? tintaPrincipal : textoSecundario,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
