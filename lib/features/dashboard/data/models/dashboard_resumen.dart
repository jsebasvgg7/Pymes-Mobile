import '../../../../core/format/fecha.dart';
import '../../../../core/format/numero.dart';

class CajaResumen {
  const CajaResumen({
    required this.id,
    required this.nombre,
    required this.saldoActual,
    required this.totalIngresos,
    required this.totalEgresos,
  });

  final int id;
  final String nombre;
  final num saldoActual;
  final num totalIngresos;
  final num totalEgresos;

  factory CajaResumen.fromJson(Map<String, dynamic> json) {
    return CajaResumen(
      id: _entero(json['cajaId']),
      nombre: (json['cajaNombre'] as String?)?.trim() ?? '',
      saldoActual: aNumero(json['saldoActual']),
      totalIngresos: aNumero(json['totalIngresos']),
      totalEgresos: aNumero(json['totalEgresos']),
    );
  }
}

class DashboardResumen {
  const DashboardResumen({
    required this.totalClientes,
    required this.totalProveedores,
    required this.totalProductos,
    required this.productosStockBajo,
    required this.productosSinStock,
    required this.totalCajas,
    required this.saldoTotalCajas,
    required this.cajas,
    this.fechaConsulta,
  });

  final int totalClientes;
  final int totalProveedores;
  final int totalProductos;
  final int productosStockBajo;
  final int productosSinStock;
  final int totalCajas;
  final num saldoTotalCajas;
  final List<CajaResumen> cajas;
  final DateTime? fechaConsulta;

  num get totalIngresos => cajas.fold<num>(0, (a, c) => a + c.totalIngresos);
  num get totalEgresos => cajas.fold<num>(0, (a, c) => a + c.totalEgresos);

  factory DashboardResumen.fromJson(Map<String, dynamic> json) {
    final lista = json['cajas'] as List<dynamic>? ?? const [];
    return DashboardResumen(
      totalClientes: _entero(json['totalClientes']),
      totalProveedores: _entero(json['totalProveedores']),
      totalProductos: _entero(json['totalProductos']),
      productosStockBajo: _entero(json['productosStockBajo']),
      productosSinStock: _entero(json['productosSinStock']),
      totalCajas: _entero(json['totalCajas']),
      saldoTotalCajas: aNumero(json['saldoTotalCajas']),
      cajas: lista
          .whereType<Map<String, dynamic>>()
          .map(CajaResumen.fromJson)
          .toList(),
      fechaConsulta: parsearFechaIso(json['fechaConsulta']),
    );
  }
}

int _entero(dynamic valor) => aNumero(valor).toInt();
