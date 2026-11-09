import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/features/dashboard/data/models/movimiento_caja.dart';

void main() {
  test('lee un movimiento de ingreso', () {
    final m = MovimientoCaja.fromJson({
      'id': 7,
      'fecha': '2026-11-09T10:00:00',
      'tipo': 'INGRESO',
      'monto': 5000.5,
      'descripcion': ' Venta POS ',
      'cajaNombre': 'Caja Principal',
    });
    expect(m.id, 7);
    expect(m.esIngreso, isTrue);
    expect(m.monto, 5000.5);
    expect(m.descripcion, 'Venta POS');
    expect(m.concepto, 'Venta POS');
    expect(m.cajaNombre, 'Caja Principal');
    expect(m.fecha, DateTime(2026, 11, 9, 10));
  });

  test('sin descripción usa Ingreso o Egreso como concepto', () {
    final ingreso = MovimientoCaja.fromJson({'tipo': 'INGRESO'});
    final egreso = MovimientoCaja.fromJson({'tipo': 'EGRESO', 'descripcion': ''});
    expect(ingreso.concepto, 'Ingreso');
    expect(egreso.concepto, 'Egreso');
    expect(egreso.esIngreso, isFalse);
  });

  test('tolera campos faltantes', () {
    final m = MovimientoCaja.fromJson({});
    expect(m.id, 0);
    expect(m.monto, 0);
    expect(m.fecha, isNull);
    expect(m.cajaNombre, '');
  });

  test('lee el contenido de una página', () {
    final lista = MovimientoCaja.listaDesdePagina({
      'content': [
        {'id': 1, 'tipo': 'INGRESO', 'monto': 10},
        {'id': 2, 'tipo': 'EGRESO', 'monto': 5},
        'basura',
      ],
      'totalElements': 2,
    });
    expect(lista.length, 2);
    expect(lista.last.esIngreso, isFalse);
  });

  test('una página sin contenido o ajena da lista vacía', () {
    expect(MovimientoCaja.listaDesdePagina({'content': 'x'}), isEmpty);
    expect(MovimientoCaja.listaDesdePagina([]), isEmpty);
    expect(MovimientoCaja.listaDesdePagina(null), isEmpty);
  });

  test('separa el título del código de la factura', () {
    final venta = MovimientoCaja.fromJson({
      'tipo': 'INGRESO',
      'descripcion': 'Venta factura #FAC-20261109-00123',
    });
    expect(venta.titulo, 'Venta factura');
    expect(venta.codigo, '#FAC-20261109-00123');
    final compra = MovimientoCaja.fromJson({
      'tipo': 'EGRESO',
      'descripcion': 'Compra #COM-2026-0004',
    });
    expect(compra.titulo, 'Compra');
    expect(compra.codigo, '#COM-2026-0004');
  });

  test('sin código el título es el concepto completo', () {
    final manual = MovimientoCaja.fromJson({
      'tipo': 'EGRESO',
      'descripcion': 'Pago de arriendo',
    });
    expect(manual.titulo, 'Pago de arriendo');
    expect(manual.codigo, isNull);
    final vacio = MovimientoCaja.fromJson({'tipo': 'INGRESO'});
    expect(vacio.titulo, 'Ingreso');
    expect(vacio.codigo, isNull);
  });

  test('un concepto que empieza con # no se parte', () {
    final m = MovimientoCaja.fromJson({
      'tipo': 'INGRESO',
      'descripcion': '#FAC-1',
    });
    expect(m.titulo, '#FAC-1');
    expect(m.codigo, isNull);
  });

  test('un # suelto al final no deja código vacío', () {
    final m = MovimientoCaja.fromJson({
      'tipo': 'INGRESO',
      'descripcion': 'Venta #',
    });
    expect(m.titulo, 'Venta');
    expect(m.codigo, isNull);
  });
}
