import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme.dart';
import '../../../core/format/cantidad.dart';
import '../../../core/format/fecha.dart';
import '../../../core/format/moneda.dart';
import '../data/models/venta_creada.dart';
import 'carrito_controller.dart';
import 'factura_texto.dart';

Future<void> mostrarFactura(
  BuildContext context,
  VentaCreada venta,
  CarritoController carrito, {
  VoidCallback? alNuevaVenta,
  Future<void> Function(String texto)? alCompartir,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    barrierDismissible: false,
    builder: (dialogo) => PopScope(
      canPop: false,
      child: _FacturaDialog(
        venta: venta,
        carrito: carrito,
        alNuevaVenta: alNuevaVenta,
        alCompartir: alCompartir,
      ),
    ),
  );
}

class _FacturaDialog extends StatelessWidget {
  const _FacturaDialog({
    required this.venta,
    required this.carrito,
    this.alNuevaVenta,
    this.alCompartir,
  });

  final VentaCreada venta;
  final CarritoController carrito;
  final VoidCallback? alNuevaVenta;
  final Future<void> Function(String texto)? alCompartir;

  @override
  Widget build(BuildContext context) {
    final simbolo = carrito.ajustes.simboloMoneda;
    final decimales = decimalesDeMoneda(carrito.ajustes.moneda);
    String moneda(num valor) => formatearMonedaConfigurada(
      valor,
      simbolo: simbolo,
      decimales: decimales,
    );

    return Dialog(
      backgroundColor: papel,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFE4F0E8),
                  shape: BoxShape.circle,
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCheck,
                  color: positivo,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Venta registrada',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Recibo ${venta.numero}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: textoSecundario),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: linea),
            const SizedBox(height: 16),
            Text(
              carrito.nombreNegocio,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            if (venta.fechaEmision != null)
              _Dato(
                etiqueta: 'Fecha',
                valor: formatearFechaYHora12(venta.fechaEmision!),
              ),
            if (venta.formaPagoNombre.isNotEmpty)
              _Dato(etiqueta: 'Método de pago', valor: venta.formaPagoNombre),
            if (venta.clienteNombre.isNotEmpty)
              _Dato(etiqueta: 'Cliente', valor: venta.clienteNombre),
            const SizedBox(height: 12),
            const Divider(height: 1, color: linea),
            const SizedBox(height: 12),
            for (final detalle in venta.detalles)
              _Dato(
                etiqueta:
                    '${formatearCantidad(detalle.cantidad, decimales: true)} × ${detalle.descripcion}',
                valor: moneda(detalle.totalLinea),
              ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: linea),
            const SizedBox(height: 12),
            _Dato(etiqueta: 'Subtotal', valor: moneda(venta.subtotal)),
            if (venta.descuento > 0)
              _Dato(
                etiqueta: 'Descuento',
                valor: '− ${moneda(venta.descuento)}',
                colorValor: positivo,
              ),
            if (carrito.recibido > 0)
              _Dato(etiqueta: 'Recibido', valor: moneda(carrito.recibido)),
            if (carrito.vuelto > 0)
              _Dato(
                etiqueta: 'Vuelto',
                valor: moneda(carrito.vuelto),
                colorValor: positivo,
              ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: linea),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  moneda(venta.total),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (carrito.mensajePie.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                carrito.mensajePie,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: textoSecundario),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _compartir(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      foregroundColor: tintaPrincipal,
                      side: const BorderSide(color: linea),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Compartir',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _nuevaVenta(context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Nueva venta',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _compartir(BuildContext context) async {
    final texto = textoFactura(venta, carrito);
    try {
      final enviar = alCompartir ?? _compartirConShare;
      await enviar(texto);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos abrir el menú para compartir.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: tintaPrincipal,
        ),
      );
    }
  }

  Future<void> _compartirConShare(String texto) async {
    await SharePlus.instance.share(ShareParams(text: texto));
  }

  void _nuevaVenta(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    navigator.popUntil((route) => route.isFirst);
    carrito.nuevaVenta();
    alNuevaVenta?.call();
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor, this.colorValor});

  final String etiqueta;
  final String valor;
  final Color? colorValor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              etiqueta,
              style: const TextStyle(fontSize: 13, color: textoSecundario),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            valor,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorValor ?? tintaPrincipal,
            ),
          ),
        ],
      ),
    );
  }
}
