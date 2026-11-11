import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/theme.dart';
import '../../../../core/format/cantidad.dart';
import '../../../../core/format/moneda.dart';
import '../carrito_controller.dart';

class TarjetaLineaCarrito extends StatelessWidget {
  const TarjetaLineaCarrito({
    super.key,
    required this.item,
    required this.carrito,
  });

  final LineaCarrito item;
  final CarritoController carrito;

  @override
  Widget build(BuildContext context) {
    final producto = item.producto;
    final decimales = producto.permiteDecimales;

    return Dismissible(
      key: ValueKey('linea-${producto.productoId}'),
      direction: DismissDirection.endToStart,
      background: const _FondoBorrado(),
      onDismissed: (_) => carrito.quitar(producto.productoId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: papel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: linea, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Stock: ${formatearCantidad(producto.cantidadActual, decimales: decimales)} ${abreviarUnidad(producto.unidadMedida, producto.cantidadActual)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: textoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatearMoneda(item.totalLinea),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ControlCantidad(item: item, carrito: carrito),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    '${formatearMoneda(producto.precioVenta)} / ${abreviarUnidad(producto.unidadMedida, producto.cantidadActual)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, color: textoSecundario),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlCantidad extends StatelessWidget {
  const _ControlCantidad({required this.item, required this.carrito});

  final LineaCarrito item;
  final CarritoController carrito;

  @override
  Widget build(BuildContext context) {
    final producto = item.producto;
    final decimales = producto.permiteDecimales;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: superficie,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Boton(
            etiqueta: 'Restar',
            icono: HugeIcons.strokeRoundedMinus,
            habilitado: carrito.puedeBajar(item),
            alTocar: () => carrito.bajarCantidad(producto.productoId),
          ),
          SizedBox(
            width: decimales ? 62 : 44,
            child: Text(
              '${formatearCantidad(item.cantidad, decimales: decimales)} ${decimales ? abreviarUnidad(producto.unidadMedida, item.cantidad) : ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _Boton(
            etiqueta: 'Sumar',
            icono: HugeIcons.strokeRoundedPlus,
            habilitado: carrito.puedeSubir(item),
            alTocar: () => carrito.subirCantidad(producto.productoId),
          ),
        ],
      ),
    );
  }
}

class _Boton extends StatelessWidget {
  const _Boton({
    required this.etiqueta,
    required this.icono,
    required this.habilitado,
    required this.alTocar,
  });

  final String etiqueta;
  final List<List<dynamic>> icono;
  final bool habilitado;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: habilitado,
      label: etiqueta,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: habilitado ? alTocar : null,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 36,
          height: 36,
          child: HugeIcon(
            icon: icono,
            color: habilitado ? tintaPrincipal : linea,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _FondoBorrado extends StatelessWidget {
  const _FondoBorrado();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: borrado,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const HugeIcon(
        icon: HugeIcons.strokeRoundedDelete02,
        color: borradoIcono,
        size: 24,
      ),
    );
  }
}
