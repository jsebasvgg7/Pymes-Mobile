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
  _Adaptador({required this.statusResumen, required this.statusVentas});

  final int statusResumen;
  final int statusVentas;
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

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    peticiones.add(options);
    final esResumen = options.path.contains('/api/dashboard/resumen/');
    final status = esResumen ? statusResumen : statusVentas;
    final cuerpo = status == 200 ? (esResumen ? _resumen : _facturas) : '{}';
    return ResponseBody.fromString(
      cuerpo,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

(DashboardRepository, _Adaptador) _construir({
  int statusResumen = 200,
  int statusVentas = 200,
}) {
  final adaptador = _Adaptador(
    statusResumen: statusResumen,
    statusVentas: statusVentas,
  );
  final cliente = ApiClient(almacen: _Almacen());
  cliente.dio.httpClientAdapter = adaptador;
  return (DashboardRepository(cliente: cliente), adaptador);
}

void main() {
  test('combina el resumen con las ventas de hoy sin las anuladas', () async {
    final (repositorio, _) = _construir();
    final datos = await repositorio.obtener(7);
    expect(datos.resumen.totalProductos, 30);
    expect(datos.ventasHoy, isNotNull);
    expect(datos.ventasHoy!.cantidad, 2);
    expect(datos.ventasHoy!.total, 8000);
  });

  test('pide el día local completo con la empresa del usuario', () async {
    final (repositorio, adaptador) = _construir();
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

  test('si fallan las ventas, el resumen igual se entrega', () async {
    final (repositorio, _) = _construir(statusVentas: 403);
    final datos = await repositorio.obtener(7);
    expect(datos.resumen.totalClientes, 8);
    expect(datos.ventasHoy, isNull);
  });

  test('si falla el resumen, se lanza el error', () async {
    final (repositorio, _) = _construir(statusResumen: 403);
    expect(
      repositorio.obtener(7),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 403)),
    );
  });
}
