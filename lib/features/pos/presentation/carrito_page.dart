import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../core/format/moneda.dart';
import 'carrito_controller.dart';
import 'ultimo_paso_sheet.dart';
import 'widgets/tarjeta_linea_carrito.dart';

Future<void> abrirCarrito(BuildContext context, CarritoController carrito) {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider<CarritoController>.value(
        value: carrito,
        child: const CarritoPage(),
      ),
    ),
  );
}

class CarritoPage extends StatelessWidget {
  const CarritoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _VistaCarrito();
  }
}

class _VistaCarrito extends StatelessWidget {
  const _VistaCarrito();

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
            if (carrito.cantidadProductos > 0) _Pie(carrito: carrito),
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
  const _Pie({required this.carrito});

  final CarritoController carrito;

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
          if (carrito.ventaRegistrada != null) ...[
            OutlinedButton(
              onPressed: carrito.enviando ? null : () => _anular(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: negativo,
                side: const BorderSide(color: linea),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Anular la venta',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: () => mostrarUltimoPaso(context, carrito),
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

  Future<void> _anular(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await carrito.anularVenta();
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(carrito.error ?? 'No pudimos anular la venta.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: tintaPrincipal,
        ),
      );
    }
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
              style: TextStyle(fontSize: 13, height: 1.4, color: textoSecundario),
            ),
          ),
        ],
      ),
    );
  }
}
