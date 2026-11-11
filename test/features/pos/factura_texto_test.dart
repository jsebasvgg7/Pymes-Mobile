import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/productos/producto_inventario.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/ajustes_venta.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/forma_pago.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/venta_creada.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/carrito_controller.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/factura_texto.dart';

const _efectivo = FormaPago(
  id: 1,
  nombre: 'Efectivo',
  tipo: TipoFormaPago.efectivo,
);

ProductoInventario _producto({num precio = 31400}) {
  return ProductoInventario(
    productoId: 1,
    nombre: 'Arroz Blanco',
    sku: 'ABA-001',
    categoria: 'Abarrotes',
    categoriaId: 1,
    descripcion: '',
    unidadMedida: 'UNIDAD',
    cantidadActual: 59,
    costoPromedio: 3650,
    stockMinimo: 19,
    precioVenta: precio,
    stockBajo: false,
  );
}

VentaCreada _venta({String cliente = '', num descuento = 0}) {
  final total = 31400 - descuento;
  return VentaCreada(
    id: 1,
    numero: 'FAC-20261111-00001',
    estado: 'EMITIDA',
    subtotal: 31400,
    descuento: descuento,
    total: total,
    fechaEmision: DateTime(2026, 11, 11, 18, 57),
    clienteNombre: cliente,
    formaPagoNombre: 'Efectivo',
    detalles: const [
      DetalleVenta(
        productoId: 1,
        descripcion: 'Arroz Blanco',
        cantidad: 2,
        precioUnitario: 15700,
        totalLinea: 31400,
      ),
    ],
  );
}

CarritoController _carrito({
  AjustesVenta ajustes = const AjustesVenta(),
  String nombreEmpresa = 'SuperMarket V',
  num descuento = 0,
  num recibido = 50000,
}) {
  final carrito = CarritoController(
    ajustes: ajustes,
    nombreEmpresa: nombreEmpresa,
  )..cargarFormasDePago(const [_efectivo]);
  carrito.agregar(_producto());
  if (descuento > 0) carrito.cambiarDescuento(descuento);
  if (recibido > 0) carrito.cambiarRecibido(recibido);
  return carrito;
}

void main() {
  test('arma la factura completa en texto', () {
    final carrito = _carrito(
      ajustes: const AjustesVenta(mensajePieRecibo: 'Gracias por su compra.'),
      descuento: 2000,
      recibido: 50000,
    );

    expect(
      textoFactura(
        _venta(cliente: 'Yesenia Cassiani Díaz', descuento: 2000),
        carrito,
      ),
      'SuperMarket V\n'
      'Recibo FAC-20261111-00001\n'
      'Fecha: 11/11/2026 6:57 p. m.\n'
      'Método de pago: Efectivo\n'
      'Cliente: Yesenia Cassiani Díaz\n'
      '\n'
      '2 × Arroz Blanco  \$ 31.400\n'
      '\n'
      'Subtotal: \$ 31.400\n'
      'Descuento: − \$ 2.000\n'
      'Total: \$ 29.400\n'
      'Recibido: \$ 50.000\n'
      'Vuelto: \$ 20.600\n'
      '\n'
      'Gracias por su compra.',
    );
  });

  test('omite descuento, cliente, recibido, vuelto y pie cuando no hay', () {
    final carrito = _carrito(recibido: 0);

    expect(
      textoFactura(_venta(), carrito),
      'SuperMarket V\n'
      'Recibo FAC-20261111-00001\n'
      'Fecha: 11/11/2026 6:57 p. m.\n'
      'Método de pago: Efectivo\n'
      '\n'
      '2 × Arroz Blanco  \$ 31.400\n'
      '\n'
      'Subtotal: \$ 31.400\n'
      'Total: \$ 31.400',
    );
  });

  test('usa la moneda configurada con dos decimales', () {
    final carrito = _carrito(
      ajustes: const AjustesVenta(moneda: 'USD', simboloMoneda: 'US\$'),
      recibido: 40000,
    );

    final texto = textoFactura(_venta(), carrito);

    expect(texto, contains('Total: US\$ 31.400,00'));
    expect(texto, contains('Recibido: US\$ 40.000,00'));
    expect(texto, contains('Vuelto: US\$ 8.600,00'));
  });

  test('cae en el nombre de la empresa cuando el recibo no tiene nombre', () {
    final carrito = _carrito();

    expect(textoFactura(_venta(), carrito), startsWith('SuperMarket V\n'));
  });
}
