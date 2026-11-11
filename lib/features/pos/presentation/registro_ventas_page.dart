import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/estado_carga.dart';
import '../../../core/widgets/estado_error.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/pos_repository.dart';
import 'pos_controller.dart';
import 'widgets/carrusel_categorias.dart';
import 'widgets/fila_producto_pos.dart';

class RegistroVentasPage extends StatelessWidget {
  const RegistroVentasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.read<AuthController>().usuario;
    if (usuario == null) return const SizedBox.shrink();
    return ChangeNotifierProvider<PosController>(
      create: (contexto) => PosController(
        repositorio: contexto.read<PosRepository>(),
        empresaId: usuario.empresaId,
      )..cargar(),
      child: const _VistaRegistroVentas(),
    );
  }
}

class _VistaRegistroVentas extends StatefulWidget {
  const _VistaRegistroVentas();

  @override
  State<_VistaRegistroVentas> createState() => _VistaRegistroVentasState();
}

class _VistaRegistroVentasState extends State<_VistaRegistroVentas> {
  final TextEditingController _campo = TextEditingController();

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<PosController>();

    switch (controlador.estado) {
      case EstadoPos.cargando:
        return const EstadoCarga();
      case EstadoPos.error:
        return EstadoError(
          mensaje: controlador.error ?? 'No pudimos cargar el punto de venta.',
          alReintentar: () => controlador.cargar(),
        );
      case EstadoPos.listo:
        return _Contenido(controlador: controlador, campo: _campo);
    }
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.controlador, required this.campo});

  final PosController controlador;
  final TextEditingController campo;

  @override
  Widget build(BuildContext context) {
    final carrito = controlador.carrito;
    final productos = controlador.productosVisibles;
    final categorias = controlador.categoriasVisibles;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text(
            'Registro de ventas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: papel,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: linea),
                  ),
                  child: Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        color: textoSecundario,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: campo,
                          onChanged: controlador.buscar,
                          textInputAction: TextInputAction.search,
                          style: const TextStyle(fontSize: 15),
                          cursorColor: tintaPrincipal,
                          decoration: const InputDecoration(
                            hintText: 'Buscar...',
                            hintStyle: TextStyle(
                              fontSize: 15,
                              color: textoSecundario,
                            ),
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _BotonCarrito(
                cantidad: carrito.cantidadProductos,
                alTocar: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'Categorías',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        CarruselCategorias(
          categorias: categorias,
          categoriaElegida: controlador.categoriaElegida,
          alElegir: controlador.elegirCategoria,
        ),
        const SizedBox(height: 12),
        if (controlador.sinCajaAbierta) const _AvisoCajaCerrada(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'Productos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${productos.length}',
                style: const TextStyle(fontSize: 13, color: textoSecundario),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: productos.isEmpty
              ? const _SinProductos()
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    24 + MediaQuery.paddingOf(context).bottom,
                  ),
                  itemCount: productos.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, indice) {
                    final producto = productos[indice];
                    return FilaProductoPos(
                      producto: producto,
                      seleccionado: carrito.estaSeleccionado(
                        producto.productoId,
                      ),
                      alSeleccionar: () => carrito.agregar(producto),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _BotonCarrito extends StatelessWidget {
  const _BotonCarrito({required this.cantidad, required this.alTocar});

  final int cantidad;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Carrito con $cantidad productos',
      child: GestureDetector(
        onTap: alTocar,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: papel,
                  shape: BoxShape.circle,
                  border: Border.all(color: linea),
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedShoppingCart01,
                  color: tintaPrincipal,
                  size: 22,
                ),
              ),
              if (cantidad > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: alerta,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cantidad',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: papel,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvisoCajaCerrada extends StatelessWidget {
  const _AvisoCajaCerrada();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: papel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: atencion.withValues(alpha: 0.35)),
      ),
      child: const Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedAlert02,
            color: atencion,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'La caja está cerrada. Ábrela para registrar ventas.',
              style: TextStyle(fontSize: 13, height: 1.3, color: textoSecundario),
            ),
          ),
        ],
      ),
    );
  }
}

class _SinProductos extends StatelessWidget {
  const _SinProductos();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Sin productos',
        style: TextStyle(fontSize: 15, color: textoSecundario),
      ),
    );
  }
}
