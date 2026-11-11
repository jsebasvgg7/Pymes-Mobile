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
    final stock =
        'Stock: ${formatearCantidad(producto.cantidadActual, decimales: decimales)} ${abreviarUnidad(producto.unidadMedida, producto.cantidadActual)}';
    final detalle = item.cantidad == 1
        ? stock
        : '$stock · ${formatearMoneda(producto.precioVenta)} / ${abreviarUnidad(producto.unidadMedida, 1)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: papel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: linea, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 96),
        child: Row(
          children: [
            _IconoProducto(icono: carrito.iconoDe(producto)),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 8, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          formatearMoneda(item.totalLinea),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          detalle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: textoSecundario,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _ControlCantidad(item: item, carrito: carrito),
                        const Spacer(),
                        _BotonQuitar(
                          nombre: producto.nombre,
                          alTocar: () => carrito.quitar(producto.productoId),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconoProducto extends StatelessWidget {
  const _IconoProducto({required this.icono});

  final List<List<dynamic>> icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: papel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: linea, width: 1),
      ),
      child: HugeIcon(icon: icono, color: tintaPrincipal, size: 32),
    );
  }
}

class _BotonQuitar extends StatelessWidget {
  const _BotonQuitar({required this.nombre, required this.alTocar});

  final String nombre;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Quitar $nombre',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: alTocar,
        behavior: HitTestBehavior.opaque,
        child: const SizedBox(
          width: 36,
          height: 32,
          child: Align(
            alignment: Alignment.centerRight,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedDelete02,
              color: negativo,
              size: 22,
            ),
          ),
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
    final cantidad = formatearCantidad(item.cantidad, decimales: decimales);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Boton(
          etiqueta: 'Restar',
          icono: HugeIcons.strokeRoundedMinus,
          habilitado: carrito.puedeBajar(item),
          alTocar: () => carrito.bajarCantidad(producto.productoId),
        ),
        SizedBox(
          width: decimales ? 44 : 32,
          child: Text(
            cantidad,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        _Boton(
          etiqueta: 'Sumar',
          icono: HugeIcons.strokeRoundedPlus,
          habilitado: carrito.puedeSubir(item),
          alTocar: () => carrito.subirCantidad(producto.productoId),
        ),
      ],
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
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: habilitado ? tintaPrincipal : superficie,
            shape: BoxShape.circle,
          ),
          child: HugeIcon(
            icon: icono,
            color: habilitado ? papel : textoSecundario,
            size: 14,
          ),
        ),
      ),
    );
  }
}
