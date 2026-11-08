import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/features/dashboard/data/models/dashboard_resumen.dart';

Map<String, dynamic> _json({dynamic fecha = '2026-11-08T14:30:15.123456'}) => {
  'totalClientes': 8,
  'totalProveedores': 3,
  'totalProductos': 30,
  'productosStockBajo': 4,
  'productosSinStock': 2,
  'totalCajas': 2,
  'saldoTotalCajas': 1250000.5,
  'cajas': [
    {
      'cajaId': 1,
      'cajaNombre': 'Caja Principal',
      'saldoInicial': 100000,
      'saldoActual': 900000,
      'totalIngresos': 500000,
      'totalEgresos': 100000,
      'totalMovimientos': 10,
    },
    {
      'cajaId': 2,
      'cajaNombre': ' Caja 2 ',
      'saldoInicial': 0,
      'saldoActual': 350000.5,
      'totalIngresos': 400000,
      'totalEgresos': 49999.5,
      'totalMovimientos': 4,
    },
  ],
  'fechaConsulta': fecha,
};

void main() {
  test('lee los campos del resumen', () {
    final r = DashboardResumen.fromJson(_json());
    expect(r.totalClientes, 8);
    expect(r.totalProveedores, 3);
    expect(r.totalProductos, 30);
    expect(r.productosStockBajo, 4);
    expect(r.productosSinStock, 2);
    expect(r.totalCajas, 2);
    expect(r.saldoTotalCajas, 1250000.5);
    expect(r.cajas.length, 2);
    expect(r.cajas.first.nombre, 'Caja Principal');
    expect(r.cajas.last.nombre, 'Caja 2');
    expect(r.cajas.last.saldoActual, 350000.5);
  });

  test('suma ingresos y egresos de todas las cajas', () {
    final r = DashboardResumen.fromJson(_json());
    expect(r.totalIngresos, 900000);
    expect(r.totalEgresos, 149999.5);
  });

  test('parsea la fecha de consulta con más de seis decimales', () {
    final r = DashboardResumen.fromJson(
      _json(fecha: '2026-11-08T14:30:15.123456789'),
    );
    expect(r.fechaConsulta, DateTime(2026, 11, 8, 14, 30, 15, 123, 456));
  });

  test('una fecha ausente o ilegible queda en null', () {
    expect(DashboardResumen.fromJson(_json(fecha: null)).fechaConsulta, isNull);
    expect(
      DashboardResumen.fromJson(_json(fecha: 'no es fecha')).fechaConsulta,
      isNull,
    );
  });

  test('tolera campos faltantes y números como texto', () {
    final r = DashboardResumen.fromJson({'totalClientes': '5'});
    expect(r.totalClientes, 5);
    expect(r.totalProductos, 0);
    expect(r.saldoTotalCajas, 0);
    expect(r.cajas, isEmpty);
    expect(r.fechaConsulta, isNull);
  });
}
