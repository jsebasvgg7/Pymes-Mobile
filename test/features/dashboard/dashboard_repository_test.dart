import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/network/api_client.dart';
import 'package:pymes_erp_mobile/core/network/api_exception.dart';
import 'package:pymes_erp_mobile/core/storage/session_storage.dart';
import 'package:pymes_erp_mobile/features/dashboard/data/dashboard_repository.dart';

class _Almacen extends SessionStorage {
  @override
  Future<String?> leerToken() async => 'abc';
}

class _Adaptador implements HttpClientAdapter {
  _Adaptador({
    this.statusResumen = 200,
    this.statusVentas = 200,
    this.statusFlujo = 200,
    this.statusMovimientos = 200,
  });

  final int statusResumen;
  final int statusVentas;
  final int statusFlujo;
  final int statusMovimientos;
  final List<RequestOptions> peticiones = [];

  static const String _resumen =
      '{"totalClientes":8,"totalProveedores":1,"totalProductos":30,'
      '"productosStockBajo":3,"productosSinStock":1,"totalCajas":1,'
      '"saldoTotalCajas":900000,"cajas":[{"cajaId":1,"cajaNombre":"Caja",'
      '"saldoInicial":0,"saldoActual":900000,"totalIngresos":500000,'
      '"totalEgresos":100000,"totalMovimientos":3}],'
      '"fechaConsulta":"2026-11-08T14:30:15"}';
  static const String _facturas =
      '[{"estado":"PAGADA","total":5000},{"estado":"ANULADA","total":9000},'
      '{"estado":"EMITIDA","total":3000}]';
  static const String _flujo =
      '[{"fecha":"2026-11-08","ingreso":1000,"egreso":200},'
      '{"fecha":"2026-11-09","ingreso":500,"egreso":0}]';
  static const String _movimientos =
      '{"content":[{"id":1,"fecha":"2026-11-09T10:00:00","tipo":"INGRESO",'
      '"monto":5000,"descripcion":"Venta","cajaNombre":"Caja"},'
      '{"id":2,"fecha":"2026-11-08T09:00:00","tipo":"EGRESO","monto":300,'
      '"descripcion":null,"cajaNombre":"Caja 2"}],"totalElements":2}';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    peticiones.add(options);
    final ruta = options.path;
    final int status;
    final String cuerpo;
    if (ruta.contains('/api/dashboard/resumen/')) {
      status = statusResumen;
      cuerpo = _resumen;
    } else if (ruta.contains('/api/facturas-venta/por-periodo/')) {
      status = statusVentas;
      cuerpo = _facturas;
    } else if (ruta.contains('/api/caja/movimientos/flujo-diario/')) {
      status = statusFlujo;
      cuerpo = _flujo;
    } else {
      status = statusMovimientos;
      cuerpo = _movimientos;
    }
    return ResponseBody.fromString(
      status == 200 ? cuerpo : '{}',
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

(DashboardRepository, _Adaptador) _construir(_Adaptador adaptador) {
  final cliente = ApiClient(almacen: _Almacen());
  cliente.dio.httpClientAdapter = adaptador;
  return (DashboardRepository(cliente: cliente), adaptador);
}

void main() {
  test('combina el resumen, las ventas, el flujo y los movimientos', () async {
    final (repositorio, _) = _construir(_Adaptador());
    final datos = await repositorio.obtener(7);
    expect(datos.resumen.totalProductos, 30);
    expect(datos.ventasHoy!.cantidad, 2);
    expect(datos.ventasHoy!.total, 8000);
    expect(datos.flujo!.length, 2);
    expect(datos.flujo!.first.ingreso, 1000);
    expect(datos.movimientos!.length, 2);
    expect(datos.movimientos!.first.concepto, 'Venta');
    expect(datos.movimientos!.last.concepto, 'Egreso');
  });

  test('pide el día local completo con la empresa del usuario', () async {
    final (repositorio, adaptador) = _construir(_Adaptador());
    await repositorio.obtener(7);
    final ahora = DateTime.now();
    final dia =
        '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-'
        '${ahora.day.toString().padLeft(2, '0')}';
    final ventas = adaptador.peticiones.firstWhere(
      (p) => p.path.contains('/api/facturas-venta/por-periodo/7'),
    );
    expect(ventas.queryParameters['inicio'], '${dia}T00:00:00');
    expect(ventas.queryParameters['fin'], '${dia}T23:59:59');
    expect(
      adaptador.peticiones.any(
        (p) => p.path.contains('/api/dashboard/resumen/7'),
      ),
      isTrue,
    );
  });

  test('pide el flujo del último mes y los 4 movimientos más recientes', () async {
    final (repositorio, adaptador) = _construir(_Adaptador());
    await repositorio.obtener(7);
    final flujo = adaptador.peticiones.firstWhere(
      (p) => p.path.contains('/api/caja/movimientos/flujo-diario/7'),
    );
    expect(flujo.queryParameters['mesesAtras'], 1);
    final movimientos = adaptador.peticiones.firstWhere(
      (p) => p.path.contains('/api/caja/movimientos/empresa/7'),
    );
    expect(movimientos.queryParameters['page'], 0);
    expect(movimientos.queryParameters['size'], 4);
    expect(movimientos.queryParameters['sort'], 'fecha,desc');
  });

  test('si fallan las ventas, lo demás se entrega', () async {
    final (repositorio, _) = _construir(_Adaptador(statusVentas: 403));
    final datos = await repositorio.obtener(7);
    expect(datos.resumen.totalClientes, 8);
    expect(datos.ventasHoy, isNull);
    expect(datos.flujo, isNotNull);
    expect(datos.movimientos, isNotNull);
  });

  test('si falla el flujo, lo demás se entrega', () async {
    final (repositorio, _) = _construir(_Adaptador(statusFlujo: 403));
    final datos = await repositorio.obtener(7);
    expect(datos.flujo, isNull);
    expect(datos.ventasHoy, isNotNull);
    expect(datos.movimientos, isNotNull);
  });

  test('si fallan los movimientos, lo demás se entrega', () async {
    final (repositorio, _) = _construir(_Adaptador(statusMovimientos: 403));
    final datos = await repositorio.obtener(7);
    expect(datos.movimientos, isNull);
    expect(datos.ventasHoy, isNotNull);
    expect(datos.flujo, isNotNull);
  });

  test('si falla el resumen, se lanza el error', () async {
    final (repositorio, _) = _construir(_Adaptador(statusResumen: 403));
    expect(
      repositorio.obtener(7),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 403)),
    );
  });
}
