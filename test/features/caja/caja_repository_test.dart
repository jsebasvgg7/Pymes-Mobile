import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/network/api_client.dart';
import 'package:pymes_erp_mobile/core/network/api_exception.dart';
import 'package:pymes_erp_mobile/core/storage/session_storage.dart';
import 'package:pymes_erp_mobile/features/caja/data/caja_repository.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/movimiento_caja.dart';

class _Almacen extends SessionStorage {
  @override
  Future<String?> leerToken() async => 'abc';
}

class _Adaptador implements HttpClientAdapter {
  _Adaptador(this.cuerpo, {this.status = 200});

  final String cuerpo;
  final int status;
  final List<RequestOptions> peticiones = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    peticiones.add(options);
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

(CajaRepository, _Adaptador) _construir(String cuerpo, {int status = 200}) {
  final cliente = ApiClient(almacen: _Almacen());
  final adaptador = _Adaptador(cuerpo, status: status);
  cliente.dio.httpClientAdapter = adaptador;
  return (CajaRepository(cliente: cliente), adaptador);
}

void main() {
  test('los resumenes se piden por empresa', () async {
    final (repositorio, adaptador) = _construir(
      '[{"cajaId":1,"cajaNombre":"Caja Principal","saldoActual":5000,'
      '"totalIngresos":9000,"totalEgresos":4000,"totalMovimientos":2}]',
    );

    final resumenes = await repositorio.resumenes(7);

    expect(adaptador.peticiones.single.method, 'GET');
    expect(adaptador.peticiones.single.path, '/api/caja/resumen-todas/7');
    expect(resumenes.single.cajaNombre, 'Caja Principal');
    expect(resumenes.single.saldoActual, 5000);
  });

  test('los estados se piden por empresa', () async {
    final (repositorio, adaptador) = _construir(
      '[{"cajaId":2,"cajaNombre":"Caja 2","abierta":false,'
      '"requiereCierre":false,"apertura":null,"efectivoSugerido":1000}]',
    );

    final estados = await repositorio.estados(7);

    expect(adaptador.peticiones.single.path, '/api/caja/estados/7');
    expect(estados.single.cajaId, 2);
    expect(estados.single.cerrada, isTrue);
    expect(estados.single.efectivoSugerido, 1000);
  });

  test('los cierres se piden paginados con tamano uno', () async {
    final (repositorio, adaptador) = _construir(
      '{"content":[{"id":733,"cajaId":1,"cajaNombre":"Caja Principal",'
      '"estado":"CERRADA","fechaCierre":"2026-11-11T15:52:00",'
      '"efectivoContado":612500,"resultado":"FALTANTE"}],'
      '"number":0,"totalPages":1,"totalElements":1}',
    );

    final pagina = await repositorio.cierres(1);

    final peticion = adaptador.peticiones.single;
    expect(peticion.path, '/api/caja/cierres/1');
    expect(peticion.queryParameters, {'page': 0, 'size': 1});
    expect(pagina.items.single.id, 733);
    expect(pagina.items.single.efectivoContado, 612500);
    expect(pagina.items.single.resultado?.name, 'faltante');
  });

  test('los movimientos se piden con fecha descendente', () async {
    final (repositorio, adaptador) = _construir(
      '{"content":[{"id":1,"cajaId":1,"tipo":"INGRESO","monto":100}],'
      '"number":1,"totalPages":3,"totalElements":25}',
    );

    final pagina = await repositorio.movimientos(1, pagina: 1, tamano: 10);

    final peticion = adaptador.peticiones.single;
    expect(peticion.path, '/api/caja/movimientos/caja/1');
    expect(peticion.queryParameters, {
      'page': 1,
      'size': 10,
      'sort': 'fecha,desc',
    });
    expect(pagina.items.single.id, 1);
    expect(pagina.hayMas, isTrue);
  });

  test('las formas de pago se piden por empresa', () async {
    final (repositorio, adaptador) = _construir(
      '{"content":[{"id":1,"nombre":"Efectivo","tipo":"EFECTIVO",'
      '"active":true}]}',
    );

    final formas = await repositorio.formasDePago(7);

    final peticion = adaptador.peticiones.single;
    expect(peticion.path, '/api/formas-pago/listar-por-empresa/7');
    expect(peticion.queryParameters, {'page': 0, 'size': 200});
    expect(formas.single.nombre, 'Efectivo');
  });

  test('la configuracion trae moneda y simbolo', () async {
    final (repositorio, adaptador) = _construir(
      r'{"moneda":"COP","simboloMoneda":"$"}',
    );

    final configuracion = await repositorio.configuracion(7);

    expect(adaptador.peticiones.single.path, '/api/configuracion/7');
    expect(configuracion.moneda, 'COP');
    expect(configuracion.simboloMoneda, r'$');
  });

  test('abrir manda el efectivo inicial', () async {
    final (repositorio, adaptador) = _construir(
      '{"id":734,"cajaId":1,"cajaNombre":"Caja Principal",'
      '"estado":"ABIERTA","fechaApertura":"2026-11-11T16:00:00",'
      '"efectivoInicial":100000,"requiereCierre":false}',
    );

    final apertura = await repositorio.abrir(1, 100000);

    final peticion = adaptador.peticiones.single;
    expect(peticion.method, 'POST');
    expect(peticion.path, '/api/caja/abrir/1');
    expect(peticion.data, {'efectivoInicial': 100000});
    expect(apertura.id, 734);
    expect(apertura.abierta, isTrue);
  });

  test('cerrar manda el efectivo contado y lee el resultado', () async {
    final (repositorio, adaptador) = _construir(
      '{"apertura":{"id":734,"cajaId":1,"cajaNombre":"Caja Principal",'
      '"estado":"CERRADA","fechaCierre":"2026-11-11T18:00:00",'
      '"efectivoEsperado":500000,"efectivoContado":490000,'
      '"diferencia":-10000,"resultado":"FALTANTE"},'
      '"ingresosOtrosMedios":20000,"egresosOtrosMedios":0}',
    );

    final cierre = await repositorio.cerrar(1, 490000);

    final peticion = adaptador.peticiones.single;
    expect(peticion.method, 'POST');
    expect(peticion.path, '/api/caja/cerrar/1');
    expect(peticion.data, {'efectivoContado': 490000});
    expect(cierre.apertura.diferencia, -10000);
    expect(cierre.apertura.resultado?.name, 'faltante');
    expect(cierre.ingresosOtrosMedios, 20000);
  });

  test('reabrir no manda cuerpo', () async {
    final (repositorio, adaptador) = _construir(
      '{"id":734,"cajaId":1,"cajaNombre":"Caja Principal",'
      '"estado":"ABIERTA","fechaApertura":"2026-11-11T18:05:00",'
      '"efectivoInicial":100000}',
    );

    final apertura = await repositorio.reabrir(1);

    final peticion = adaptador.peticiones.single;
    expect(peticion.method, 'POST');
    expect(peticion.path, '/api/caja/reabrir/1');
    expect(peticion.data, isNull);
    expect(apertura.abierta, isTrue);
  });

  test('registrar movimiento manda el tipo y omite la referencia', () async {
    final (repositorio, adaptador) = _construir(
      '{"id":10,"cajaId":1,"tipo":"INGRESO","monto":5000,'
      '"descripcion":"Aporte","tipoReferencia":"AJUSTE"}',
    );

    final movimiento = await repositorio.registrarMovimiento(
      empresaId: 7,
      cajaId: 1,
      formaPagoId: 2,
      tipo: TipoMovimientoCaja.ingreso,
      monto: 5000,
      descripcion: 'Aporte',
    );

    final peticion = adaptador.peticiones.single;
    expect(peticion.method, 'POST');
    expect(peticion.path, '/api/caja/movimientos/registrar');
    final cuerpo = peticion.data as Map<String, dynamic>;
    expect(cuerpo['empresaId'], 7);
    expect(cuerpo['cajaId'], 1);
    expect(cuerpo['formaPagoId'], 2);
    expect(cuerpo['tipo'], 'INGRESO');
    expect(cuerpo['monto'], 5000);
    expect(cuerpo['descripcion'], 'Aporte');
    expect(cuerpo.containsKey('tipoReferencia'), isFalse);
    expect(movimiento.id, 10);
  });

  test('un gasto manda tipo EGRESO y referencia GASTO', () async {
    final (repositorio, adaptador) = _construir(
      '{"id":11,"cajaId":1,"tipo":"EGRESO","monto":45000,'
      '"descripcion":"Energía","tipoReferencia":"GASTO"}',
    );

    final movimiento = await repositorio.registrarMovimiento(
      empresaId: 7,
      cajaId: 1,
      formaPagoId: 1,
      tipo: TipoMovimientoCaja.egreso,
      monto: 45000,
      descripcion: 'Energía',
      tipoReferencia: TipoReferenciaMovimientoCaja.gasto,
    );

    final cuerpo = adaptador.peticiones.single.data as Map<String, dynamic>;
    expect(cuerpo['tipo'], 'EGRESO');
    expect(cuerpo['tipoReferencia'], 'GASTO');
    expect(movimiento.esGasto, isTrue);
  });

  test('crear caja manda nombre y saldo inicial opcional', () async {
    final (repositorio, adaptador) = _construir(
      '{"id":3,"empresaId":7,"nombre":"Caja 3","saldoInicial":5000,'
      '"saldoActual":5000}',
    );

    final caja = await repositorio.crearCaja(
      empresaId: 7,
      nombre: 'Caja 3',
      saldoInicial: 5000,
    );

    final cuerpo = adaptador.peticiones.single.data as Map<String, dynamic>;
    expect(cuerpo['empresaId'], 7);
    expect(cuerpo['nombre'], 'Caja 3');
    expect(cuerpo['saldoInicial'], 5000);
    expect(caja.id, 3);
  });

  test('crear caja sin saldo no manda el campo', () async {
    final (repositorio, adaptador) = _construir(
      '{"id":3,"empresaId":7,"nombre":"Caja 3","saldoInicial":0,'
      '"saldoActual":0}',
    );

    await repositorio.crearCaja(empresaId: 7, nombre: 'Caja 3');

    final cuerpo = adaptador.peticiones.single.data as Map<String, dynamic>;
    expect(cuerpo.containsKey('saldoInicial'), isFalse);
  });

  test('un 409 se convierte en ApiException con su mensaje', () async {
    final (repositorio, _) = _construir(
      '{"message":"La caja ya está abierta."}',
      status: 409,
    );

    await expectLater(
      repositorio.abrir(1, 0),
      throwsA(
        isA<ApiException>()
            .having((e) => e.status, 'status', 409)
            .having((e) => e.mensaje, 'mensaje', 'La caja ya está abierta.'),
      ),
    );
  });
}
