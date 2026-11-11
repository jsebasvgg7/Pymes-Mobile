import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../app/theme.dart';
import '../../../core/format/cantidad.dart';
import '../../../core/format/fecha.dart';
import '../../../core/format/moneda.dart';
import '../data/models/venta_creada.dart';
import 'carrito_controller.dart';

/// Muestra la factura de la venta registrada. El boton de compartir queda
/// fuera de esta entrega (depende de `share_plus`, que se agrega en la 5.1f).
Future<void> mostrarFactura(
  BuildContext context,
  VentaCreada venta,
  CarritoController carrito,
) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogo) => _FacturaDialog(venta: venta, carrito: carrito),
  );
}

class _FacturaDialog extends StatelessWidget {
  const _FacturaDialog({required this.venta, required this.carrito});

  final VentaCreada venta;
  final CarritoController carrito;

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
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
              _nombreNegocio(),
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: tintaPrincipal,
                      side: const BorderSide(color: linea),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      carrito.nuevaVenta();
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Nueva venta',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

  String _nombreNegocio() {
    final nombre = carrito.ajustes.nombreRecibo;
    if (nombre.isNotEmpty) return nombre;
    return 'Pymes ERP';
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.etiqueta,
    required this.valor,
    this.colorValor,
  });

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
