import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/network/api_exception.dart';
import 'package:pymes_erp_mobile/features/dashboard/data/dashboard_repository.dart';
import 'package:pymes_erp_mobile/features/dashboard/data/models/dashboard_resumen.dart';
import 'package:pymes_erp_mobile/features/dashboard/data/models/ventas_hoy.dart';
import 'package:pymes_erp_mobile/features/dashboard/presentation/dashboard_controller.dart';

class _RepoFalso implements DashboardRepository {
  _RepoFalso(this.accion);

  Future<DashboardDatos> Function(int empresaId) accion;
  int llamadas = 0;

  @override
  Future<DashboardDatos> obtener(int empresaId) {
    llamadas++;
    return accion(empresaId);
  }
}

DashboardResumen _resumen({int clientes = 8, DateTime? fecha}) {
  return DashboardResumen(
    totalClientes: clientes,
    totalProveedores: 1,
    totalProductos: 30,
    productosStockBajo: 3,
    productosSinStock: 1,
    totalCajas: 1,
    saldoTotalCajas: 900000,
    cajas: const [],
    fechaConsulta: fecha,
  );
}

DashboardDatos _datos({
  int clientes = 8,
  DateTime? fecha,
  VentasHoy? ventas = const VentasHoy(cantidad: 2, total: 8000),
}) {
  return DashboardDatos(
    resumen: _resumen(clientes: clientes, fecha: fecha),
    ventasHoy: ventas,
  );
}

void main() {
  final fijo = DateTime(2026, 11, 8, 9, 5);

  DashboardController construir(_RepoFalso repo) => DashboardController(
    repositorio: repo,
    empresaId: 7,
    ahora: () => fijo,
  );

  test('carga bien y deja el estado listo', () async {
    final fecha = DateTime(2026, 11, 8, 14, 30);
    final repo = _RepoFalso((_) async => _datos(fecha: fecha));
    final c = construir(repo);
    expect(c.estado, EstadoDashboard.cargando);
    await c.cargar();
    expect(c.estado, EstadoDashboard.listo);
    expect(c.resumen!.totalClientes, 8);
    expect(c.ventasHoy!.total, 8000);
    expect(c.actualizadoEn, fecha);
    expect(c.error, isNull);
  });

  test('usa la hora del teléfono si no llega fechaConsulta', () async {
    final c = construir(_RepoFalso((_) async => _datos()));
    await c.cargar();
    expect(c.actualizadoEn, fijo);
  });

  test('pasa la empresa al repositorio', () async {
    int? recibida;
    final c = construir(
      _RepoFalso((id) async {
        recibida = id;
        return _datos();
      }),
    );
    await c.cargar();
    expect(recibida, 7);
  });

  test('si falla el resumen, queda en error con el mensaje', () async {
    final c = construir(
      _RepoFalso((_) async => throw const ApiException('Sin conexión')),
    );
    await c.cargar();
    expect(c.estado, EstadoDashboard.error);
    expect(c.error, 'Sin conexión');
    expect(c.resumen, isNull);
  });

  test('un error inesperado también queda en error', () async {
    final c = construir(_RepoFalso((_) async => throw StateError('x')));
    await c.cargar();
    expect(c.estado, EstadoDashboard.error);
    expect(c.error, 'Ocurrió un error inesperado. Intenta de nuevo.');
  });

  test('si fallan solo las ventas de hoy, el resto se muestra', () async {
    final c = construir(_RepoFalso((_) async => _datos(ventas: null)));
    await c.cargar();
    expect(c.estado, EstadoDashboard.listo);
    expect(c.ventasHoy, isNull);
    expect(c.resumen, isNotNull);
  });

  test('reintentar después de un error vuelve a cargar', () async {
    var falla = true;
    final c = construir(
      _RepoFalso((_) async {
        if (falla) throw const ApiException('Sin conexión');
        return _datos();
      }),
    );
    await c.cargar();
    expect(c.estado, EstadoDashboard.error);
    falla = false;
    await c.cargar();
    expect(c.estado, EstadoDashboard.listo);
    expect(c.error, isNull);
  });

  test('refrescar actualiza los datos sin pasar por cargando', () async {
    var clientes = 8;
    final c = construir(_RepoFalso((_) async => _datos(clientes: clientes)));
    await c.cargar();
    final estados = <EstadoDashboard>[];
    c.addListener(() => estados.add(c.estado));
    clientes = 9;
    final exito = await c.refrescar();
    expect(exito, isTrue);
    expect(c.resumen!.totalClientes, 9);
    expect(estados, isNot(contains(EstadoDashboard.cargando)));
  });

  test('refrescar con error conserva los datos y devuelve false', () async {
    var falla = false;
    final c = construir(
      _RepoFalso((_) async {
        if (falla) throw const ApiException('Sin conexión');
        return _datos();
      }),
    );
    await c.cargar();
    falla = true;
    final exito = await c.refrescar();
    expect(exito, isFalse);
    expect(c.estado, EstadoDashboard.listo);
    expect(c.resumen!.totalClientes, 8);
    expect(c.error, 'Sin conexión');
  });

  test('no notifica después de liberar el controlador', () async {
    final espera = Completer<DashboardDatos>();
    final c = construir(_RepoFalso((_) => espera.future));
    final carga = c.cargar();
    c.dispose();
    espera.complete(_datos());
    await carga;
  });
}
