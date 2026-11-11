import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../core/format/moneda.dart';
import 'carrito_controller.dart';
import 'ultimo_paso_sheet.dart';
import 'widgets/tarjeta_linea_carrito.dart';

Future<void> abrirCarrito(
  BuildContext context,
  CarritoController carrito, {
  VoidCallback? alNuevaVenta,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider<CarritoController>.value(
        value: carrito,
        child: CarritoPage(alNuevaVenta: alNuevaVenta),
      ),
    ),
  );
}

class CarritoPage extends StatelessWidget {
  const CarritoPage({super.key, this.alNuevaVenta});

  final VoidCallback? alNuevaVenta;

  @override
  Widget build(BuildContext context) {
    return _VistaCarrito(alNuevaVenta: alNuevaVenta);
  }
}

class _VistaCarrito extends StatelessWidget {
  const _VistaCarrito({this.alNuevaVenta});

  final VoidCallback? alNuevaVenta;

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoController>();

    return Scaffold(
      backgroundColor: papel,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Encabezado(cantidad: carrito.cantidadProductos),
            Expanded(
              child: carrito.cantidadProductos == 0
                  ? const _CarritoVacio()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      itemCount: carrito.lineas.length,
                      itemBuilder: (context, indice) {
                        return TarjetaLineaCarrito(
                          item: carrito.lineas[indice],
                          carrito: carrito,
                        );
                      },
                    ),
            ),
            if (carrito.cantidadProductos > 0)
              _Pie(carrito: carrito, alNuevaVenta: alNuevaVenta),
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.cantidad});

  final int cantidad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Carrito',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  cantidad == 1 ? '1 Producto' : '$cantidad Productos',
                  style: const TextStyle(fontSize: 13, color: textoSecundario),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Cerrar',
                onPressed: () => Navigator.of(context).maybePop(),
                style: IconButton.styleFrom(
                  backgroundColor: papel,
                  fixedSize: const Size(44, 44),
                  side: const BorderSide(color: tintaPrincipal, width: 1.5),
                ),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: tintaPrincipal,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pie extends StatelessWidget {
  const _Pie({required this.carrito, this.alNuevaVenta});

  final CarritoController carrito;
  final VoidCallback? alNuevaVenta;

  @override
  Widget build(BuildContext context) {
    final subtotal = formatearMonedaConfigurada(
      carrito.subtotal,
      simbolo: carrito.ajustes.simboloMoneda,
      decimales: decimalesDeMoneda(carrito.ajustes.moneda),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: papel,
        border: Border(top: BorderSide(color: linea)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 15, color: textoSecundario),
              ),
              const Spacer(),
              Text(
                subtotal,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () =>
                mostrarUltimoPaso(context, carrito, alNuevaVenta: alNuevaVenta),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              'Último paso',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarritoVacio extends StatelessWidget {
  const _CarritoVacio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              icon: HugeIcons.strokeRoundedShoppingCart01,
              color: textoSecundario,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Agrega productos desde el registro de ventas para empezar una venta.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: textoSecundario,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
