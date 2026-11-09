import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/estado_carga.dart';
import '../../../core/widgets/estado_error.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/inventario_repository.dart';
import 'inventario_controller.dart';
import 'widgets/barra_filtros.dart';
import 'widgets/hoja_filtros.dart';
import 'widgets/hoja_orden.dart';
import 'widgets/tarjeta_producto.dart';

class InventarioPage extends StatelessWidget {
  const InventarioPage({super.key, this.filtroInicial = FiltroStock.todos});

  final FiltroStock filtroInicial;

  @override
  Widget build(BuildContext context) {
    final usuario = context.read<AuthController>().usuario;
    if (usuario == null) return const SizedBox.shrink();
    return ChangeNotifierProvider<InventarioController>(
      create: (contexto) => InventarioController(
        repositorio: contexto.read<InventarioRepository>(),
        empresaId: usuario.empresaId,
        filtroInicial: filtroInicial,
      )..cargar(),
      child: const _VistaInventario(),
    );
  }
}

class _VistaInventario extends StatefulWidget {
  const _VistaInventario();

  @override
  State<_VistaInventario> createState() => _VistaInventarioState();
}

class _VistaInventarioState extends State<_VistaInventario> {
  final TextEditingController _campo = TextEditingController();

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<InventarioController>();

    switch (controlador.estado) {
      case EstadoInventario.cargando:
        return const EstadoCarga();
      case EstadoInventario.error:
        return EstadoError(
          mensaje: controlador.error ?? 'No pudimos cargar el inventario.',
          alReintentar: controlador.cargar,
        );
      case EstadoInventario.listo:
        return Column(
          children: [
            BarraFiltros(
              campo: _campo,
              alBuscar: controlador.buscar,
              alFiltrar: () => mostrarHojaFiltros(context, controlador),
              alOrdenar: () => mostrarHojaOrden(context, controlador),
              filtrosActivos:
                  controlador.filtro != FiltroStock.todos ||
                  controlador.categoria != null,
            ),
            Expanded(
              child: RefreshIndicator(
                color: tintaPrincipal,
                backgroundColor: papel,
                onRefresh: () => _refrescar(context, controlador),
                child: _Lista(
                  controlador: controlador,
                  alLimpiar: () => _limpiarTodo(controlador),
                ),
              ),
            ),
          ],
        );
    }
  }

  void _limpiarTodo(InventarioController controlador) {
    _campo.clear();
    controlador.limpiarFiltros();
  }

  Future<void> _refrescar(
    BuildContext context,
    InventarioController controlador,
  ) async {
    final mensajero = ScaffoldMessenger.of(context);
    final exito = await controlador.refrescar();
    if (exito) return;
    mensajero
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            controlador.error ?? 'No pudimos actualizar.',
            style: const TextStyle(color: papel),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: tintaPrincipal,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({required this.controlador, required this.alLimpiar});

  final InventarioController controlador;
  final VoidCallback alLimpiar;

  @override
  Widget build(BuildContext context) {
    final visibles = controlador.visibles;
    final vacia = visibles.isEmpty;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: 1 + (vacia ? 1 : visibles.length),
      itemBuilder: (context, indice) {
        if (indice == 0) {
          return _Resumen(controlador: controlador, alLimpiar: alLimpiar);
        }
        if (vacia) {
          return _Vacio(
            sinProductos: controlador.total == 0,
            alLimpiar: alLimpiar,
          );
        }
        final item = visibles[indice - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TarjetaProducto(key: ValueKey(item.productoId), item: item),
        );
      },
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.controlador, required this.alLimpiar});

  final InventarioController controlador;
  final VoidCallback alLimpiar;

  String _texto() {
    final mostrados = controlador.visibles.length;
    final total = controlador.total;
    final base = controlador.hayFiltros && mostrados != total
        ? '$mostrados de $total'
        : '$mostrados';
    return '$base ${total == 1 ? 'producto' : 'productos'}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            Expanded(
              child: Text(
                _texto(),
                style: const TextStyle(fontSize: 13, color: textoSecundario),
              ),
            ),
            if (controlador.hayFiltros)
              TextButton(
                onPressed: alLimpiar,
                style: TextButton.styleFrom(
                  foregroundColor: tintaPrincipal,
                  minimumSize: const Size(48, 44),
                ),
                child: const Text(
                  'Limpiar',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio({required this.sinProductos, required this.alLimpiar});

  final bool sinProductos;
  final VoidCallback alLimpiar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: papel,
              shape: BoxShape.circle,
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedPackage,
              color: textoSecundario,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            sinProductos ? 'Sin productos' : 'Sin resultados',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              sinProductos
                  ? 'Cuando agregues productos al inventario aparecerán aquí.'
                  : 'Prueba con otra búsqueda o quita los filtros.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: textoSecundario,
              ),
            ),
          ),
          if (!sinProductos) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: alLimpiar,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(180, 48),
                foregroundColor: tintaPrincipal,
                backgroundColor: papel,
                side: const BorderSide(color: linea),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Quitar filtros'),
            ),
          ],
        ],
      ),
    );
  }
}
