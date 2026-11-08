import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/features/dashboard/data/models/ventas_hoy.dart';

void main() {
  test('suma los totales y cuenta las facturas', () {
    final ventas = VentasHoy.desdeFacturas([
      {'estado': 'PAGADA', 'total': 5000},
      {'estado': 'EMITIDA', 'total': 3000.5},
    ]);
    expect(ventas.cantidad, 2);
    expect(ventas.total, 8000.5);
  });

  test('descarta las facturas anuladas', () {
    final ventas = VentasHoy.desdeFacturas([
      {'estado': 'PAGADA', 'total': 5000},
      {'estado': 'ANULADA', 'total': 9000},
    ]);
    expect(ventas.cantidad, 1);
    expect(ventas.total, 5000);
  });

  test('una lista vacía da cero', () {
    final ventas = VentasHoy.desdeFacturas([]);
    expect(ventas.cantidad, 0);
    expect(ventas.total, 0);
  });

  test('tolera totales como texto y elementos inesperados', () {
    final ventas = VentasHoy.desdeFacturas([
      {'estado': 'PAGADA', 'total': '2500'},
      {'estado': 'PAGADA', 'total': null},
      'basura',
    ]);
    expect(ventas.cantidad, 2);
    expect(ventas.total, 2500);
  });
}
