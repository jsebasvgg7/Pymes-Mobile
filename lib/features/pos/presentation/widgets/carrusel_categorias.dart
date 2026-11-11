import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/theme.dart';
import '../../data/icono_categoria.dart';
import '../../data/models/categoria_pos.dart';

class CarruselCategorias extends StatefulWidget {
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
  State<CarruselCategorias> createState() => CarruselCategoriasState();
}

class CarruselCategoriasState extends State<CarruselCategorias> {
  static const double _largoDesvanecido = 28;

  final ScrollController _controlador = ScrollController();
  bool desvanecerIzquierda = false;
  bool desvanecerDerecha = false;

  @override
  void initState() {
    super.initState();
    _controlador.addListener(_actualizarBordes);
    _programarRevision();
  }

  @override
  void didUpdateWidget(CarruselCategorias oldWidget) {
    super.didUpdateWidget(oldWidget);
    _programarRevision();
  }

  @override
  void dispose() {
    _controlador.removeListener(_actualizarBordes);
    _controlador.dispose();
    super.dispose();
  }

  void _programarRevision() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _actualizarBordes();
    });
  }

  void _actualizarBordes() {
    if (!_controlador.hasClients) return;
    final posicion = _controlador.position;
    final izquierda = posicion.pixels > 0.5;
    final derecha = posicion.pixels < posicion.maxScrollExtent - 0.5;
    if (izquierda == desvanecerIzquierda && derecha == desvanecerDerecha) {
      return;
    }
    setState(() {
      desvanecerIzquierda = izquierda;
      desvanecerDerecha = derecha;
    });
  }

  Shader _construirDesvanecido(Rect area) {
    final fraccion = (_largoDesvanecido / area.width).clamp(0.0, 0.5);
    return LinearGradient(
      colors: [
        desvanecerIzquierda ? Colors.transparent : Colors.black,
        Colors.black,
        Colors.black,
        desvanecerDerecha ? Colors.transparent : Colors.black,
      ],
      stops: [0, fraccion, 1 - fraccion, 1],
    ).createShader(area);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categorias.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 92,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: _construirDesvanecido,
          child: ListView.separated(
            controller: _controlador,
            scrollDirection: Axis.horizontal,
            itemCount: widget.categorias.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 13),
            itemBuilder: (context, indice) {
              if (indice == 0) {
                return _BotonCategoria(
                  nombre: 'Todos',
                  icono: HugeIcons.strokeRoundedGrid,
                  activo: widget.categoriaElegida == null,
                  alTocar: () => widget.alElegir(null),
                );
              }
              final categoria = widget.categorias[indice - 1];
              return _BotonCategoria(
                nombre: categoria.nombre,
                icono: iconoCategoria(categoria.nombre, clave: categoria.icono),
                activo: widget.categoriaElegida == categoria.id,
                alTocar: () => widget.alElegir(categoria.id),
              );
            },
          ),
        ),
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
                decoration: BoxDecoration(
                  color: tintaPrincipal.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(icon: icono, color: tintaPrincipal, size: 24),
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
