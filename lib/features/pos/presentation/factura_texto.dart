import '../../../core/format/cantidad.dart';
import '../../../core/format/fecha.dart';
import '../../../core/format/moneda.dart';
import '../data/models/venta_creada.dart';
import 'carrito_controller.dart';

String textoFactura(VentaCreada venta, CarritoController carrito) {
  final simbolo = carrito.ajustes.simboloMoneda;
  final decimales = decimalesDeMoneda(carrito.ajustes.moneda);
  String moneda(num valor) =>
      formatearMonedaConfigurada(valor, simbolo: simbolo, decimales: decimales);

  final lineas = <String>[carrito.nombreNegocio, 'Recibo ${venta.numero}'];
  final fecha = venta.fechaEmision;
  if (fecha != null) lineas.add('Fecha: ${formatearFechaYHora12(fecha)}');
  if (venta.formaPagoNombre.isNotEmpty) {
    lineas.add('Método de pago: ${venta.formaPagoNombre}');
  }
  if (venta.clienteNombre.isNotEmpty) {
    lineas.add('Cliente: ${venta.clienteNombre}');
  }
  lineas.add('');
  for (final detalle in venta.detalles) {
    final cantidad = formatearCantidad(detalle.cantidad, decimales: true);
    lineas.add(
      '$cantidad × ${detalle.descripcion}  ${moneda(detalle.totalLinea)}',
    );
  }
  lineas.add('');
  lineas.add('Subtotal: ${moneda(venta.subtotal)}');
  if (venta.descuento > 0) {
    lineas.add('Descuento: − ${moneda(venta.descuento)}');
  }
  lineas.add('Total: ${moneda(venta.total)}');
  if (carrito.recibido > 0) {
    lineas.add('Recibido: ${moneda(carrito.recibido)}');
  }
  if (carrito.vuelto > 0) {
    lineas.add('Vuelto: ${moneda(carrito.vuelto)}');
  }
  final pie = carrito.mensajePie;
  if (pie.isNotEmpty) {
    lineas.add('');
    lineas.add(pie);
  }
  return lineas.join('\n');
}
