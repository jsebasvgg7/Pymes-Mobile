import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/network/api_client.dart';
import 'package:pymes_erp_mobile/core/network/api_exception.dart';
import 'package:pymes_erp_mobile/core/storage/session_storage.dart';
import 'package:pymes_erp_mobile/features/caja/data/caja_repository.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/apertura_caja.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/estado_caja.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/resumen_caja.dart';
import 'package:pymes_erp_mobile/features/caja/presentation/caja_controller.dart';

class _RepoFalso extends CajaRepository {
  _RepoFalso({
    Future<List<ResumenCaja>> Function(int empresaId)? resumenesAccion,
    Future<List<EstadoCaja>> Function(int empresaId)? estadosAccion,
    Future<PaginaCierresCaja> Function(int cajaId)? cierresAccion,
  }) : resumenesAccion = resumenesAccion ?? ((_) async => const []),
       estadosAccion = estadosAccion ?? ((_) async => const []),
       cierresAccion =
           cierresAccion ?? ((_) async => const PaginaCierresCaja(items: [])),
       super(cliente: ApiClient(almacen: SessionStorage()));

  Future<List<ResumenCaja>> Function(int empresaId) resumenesAccion;
  Future<List<EstadoCaja>> Function(int empresaId) estadosAccion;
  Future<PaginaCierresCaja> Function(int cajaId) cierresAccion;
  int llamadasResumenes = 0;
  int llamadasEstados = 0;
  int llamadasCierres = 0;
  int empresaPedida = 0;

  @override
  Future<List<ResumenCaja>> resumenes(int empresaId) {
    llamadasResumenes++;
    empresaPedida = empresaId;
    return resumenesAccion(empresaId);
  }

  @override
  Future<List<EstadoCaja>> estados(int empresaId) {
    llamadasEstados++;
    return estadosAccion(empresaId);
  }

  @override
  Future<PaginaCierresCaja> cierres(
    int cajaId, {
    int pagina = 0,
    int tamano = 1,
  }) {
    llamadasCierres++;
    return cierresAccion(cajaId);
  }
}

ResumenCaja _resumen(
  int id,
  String nombre, {
  num saldo = 100000,
  num ingresos = 50000,
  num egresos = 20000,
  int movimientos = 3,
}) {
  return ResumenCaja(
    cajaId: id,
    cajaNombre: nombre,
    saldoInicial: 0,
    saldoActual: saldo,
    totalIngresos: ingresos,
    totalEgresos: egresos,
    totalMovimientos: movimientos,
  );
}

EstadoCaja _estado(
  int id,
  String nombre, {
  bool abierta = true,
  bool requiereCierre = false,
}) {
  return EstadoCaja(
    cajaId: id,
    cajaNombre: nombre,
    abierta: abierta,
    requiereCierre: requiereCierre,
    apertura: null,
    efectivoSugerido: null,
  );
}

AperturaCaja _cierre(int id, {num? diferencia = -15500, DateTime? fecha}) {
  return AperturaCaja(
    id: id,
    cajaId: 1,
    cajaNombre: 'Caja Principal',
    estado: EstadoAperturaCaja.cerrada,
    usuarioAperturaId: null,
    usuarioAperturaNombre: null,
    fechaApertura: null,
    efectivoInicial: 0,
    usuarioCierreId: null,
    usuarioCierreNombre: null,
    fechaCierre: fecha ?? DateTime(2026, 11, 11, 15, 52),
    efectivoEsperado: 500000,
    efectivoContado: 484500,
    diferencia: diferencia,
    tipoCierre: TipoCierreCaja.manual,
    resultado: ResultadoCierreCaja.faltante,
    requiereCierre: false,
  );
}

Future<CajaController> _construir(_RepoFalso repo) async {
  final controlador = CajaController(repositorio: repo, empresaId: 7);
  await controlador.cargar();
  return controlador;
}

void main() {
  test('carga resumenes y estados, y elige la primera caja', () async {
    final repo = _RepoFalso(
      resumenesAccion: (_) async => [
        _resumen(1, 'Caja Principal'),
        _resumen(2, 'Caja 2'),
      ],
      estadosAccion: (_) async => [
        _estado(1, 'Caja Principal'),
        _estado(2, 'Caja 2', abierta: false),
      ],
    );

    final c = await _construir(repo);

    expect(c.estado, EstadoPantallaCaja.listo);
    expect(repo.empresaPedida, 7);
    expect(c.cajas.length, 2);
    expect(c.seleccionadaId, 1);
    expect(c.seleccionada!.nombre, 'Caja Principal');
    expect(c.abierta, isTrue);
    expect(c.error, isNull);
    expect(repo.llamadasCierres, 0);
  });

  test(
    'marca el cierre pendiente y usa el nombre del estado si falta',
    () async {
      final repo = _RepoFalso(
        resumenesAccion: (_) async => [_resumen(1, '')],
        estadosAccion: (_) async => [
          _estado(1, 'Caja Principal', requiereCierre: true),
        ],
      );

      final c = await _construir(repo);

      expect(c.seleccionada!.nombre, 'Caja Principal');
      expect(c.cierrePendiente, isTrue);
    },
  );

  test('carga el ultimo cierre de una caja cerrada', () async {
    final repo = _RepoFalso(
      resumenesAccion: (_) async => [_resumen(1, 'Caja Principal')],
      estadosAccion: (_) async => [
        _estado(1, 'Caja Principal', abierta: false),
      ],
      cierresAccion: (_) async => PaginaCierresCaja(items: [_cierre(733)]),
    );

    final c = await _construir(repo);

    expect(repo.llamadasCierres, 1);
    expect(c.ultimoCierre!.id, 733);
    expect(c.ultimoCierre!.diferencia, -15500);
  });

  test('al cambiar a una caja abierta limpia el cierre y no lo pide', () async {
    final repo = _RepoFalso(
      resumenesAccion: (_) async => [
        _resumen(1, 'Caja Principal'),
        _resumen(2, 'Caja 2'),
      ],
      estadosAccion: (_) async => [
        _estado(1, 'Caja Principal', abierta: false),
        _estado(2, 'Caja 2'),
      ],
      cierresAccion: (_) async => PaginaCierresCaja(items: [_cierre(733)]),
    );
    final c = await _construir(repo);
    expect(c.ultimoCierre, isNotNull);

    await c.seleccionarCaja(2);

    expect(c.seleccionadaId, 2);
    expect(c.abierta, isTrue);
    expect(c.ultimoCierre, isNull);
    expect(repo.llamadasCierres, 1);
  });

  test('al cambiar a otra caja cerrada pide su ultimo cierre', () async {
    final repo = _RepoFalso(
      resumenesAccion: (_) async => [
        _resumen(1, 'Caja Principal'),
        _resumen(2, 'Caja 2'),
      ],
      estadosAccion: (_) async => [
        _estado(1, 'Caja Principal'),
        _estado(2, 'Caja 2', abierta: false),
      ],
      cierresAccion: (_) async => PaginaCierresCaja(items: [_cierre(740)]),
    );
    final c = await _construir(repo);

    await c.seleccionarCaja(2);

    expect(c.seleccionadaId, 2);
    expect(c.abierta, isFalse);
    expect(c.ultimoCierre!.id, 740);
    expect(repo.llamadasCierres, 1);
  });

  test('refrescar conserva la caja elegida', () async {
    var resumenes = [
      _resumen(1, 'Caja Principal', saldo: 100),
      _resumen(2, 'Caja 2', saldo: 200),
    ];
    final repo = _RepoFalso(
      resumenesAccion: (_) async => resumenes,
      estadosAccion: (_) async => [
        _estado(1, 'Caja Principal'),
        _estado(2, 'Caja 2'),
      ],
    );
    final c = await _construir(repo);
    await c.seleccionarCaja(2);
    resumenes = [
      _resumen(1, 'Caja Principal', saldo: 300),
      _resumen(2, 'Caja 2', saldo: 400),
    ];

    expect(await c.refrescar(), isTrue);

    expect(c.seleccionadaId, 2);
    expect(c.seleccionada!.resumen.saldoActual, 400);
  });

  test('si la caja elegida desaparece vuelve a la primera', () async {
    var resumenes = [_resumen(1, 'Caja Principal'), _resumen(2, 'Caja 2')];
    final repo = _RepoFalso(
      resumenesAccion: (_) async => resumenes,
      estadosAccion: (_) async => [_estado(1, 'Caja Principal')],
    );
    final c = await _construir(repo);
    await c.seleccionarCaja(2);
    resumenes = [_resumen(1, 'Caja Principal')];

    await c.refrescar();

    expect(c.seleccionadaId, 1);
  });

  test('sin cajas queda listo y sin seleccion', () async {
    final c = await _construir(_RepoFalso());

    expect(c.estado, EstadoPantallaCaja.listo);
    expect(c.cajas, isEmpty);
    expect(c.seleccionada, isNull);
    expect(c.abierta, isFalse);
  });

  test('si falla la carga inicial queda en error con el mensaje', () async {
    final repo = _RepoFalso(
      resumenesAccion: (_) async => throw const ApiException('Sin conexión'),
    );
    final c = CajaController(repositorio: repo, empresaId: 7);

    expect(c.estado, EstadoPantallaCaja.cargando);
    await c.cargar();

    expect(c.estado, EstadoPantallaCaja.error);
    expect(c.error, 'Sin conexión');
  });

  test('un error inesperado usa el mensaje generico', () async {
    final repo = _RepoFalso(
      resumenesAccion: (_) async => throw StateError('x'),
    );
    final c = CajaController(repositorio: repo, empresaId: 7);

    await c.cargar();

    expect(c.estado, EstadoPantallaCaja.error);
    expect(c.error, 'Ocurrió un error inesperado. Intenta de nuevo.');
  });

  test('refrescar con error conserva los datos y devuelve falso', () async {
    var falla = false;
    final repo = _RepoFalso(
      resumenesAccion: (_) async {
        if (falla) throw const ApiException('Sin conexión');
        return [_resumen(1, 'Caja Principal')];
      },
      estadosAccion: (_) async => [_estado(1, 'Caja Principal')],
    );
    final c = await _construir(repo);
    falla = true;

    final exito = await c.refrescar();

    expect(exito, isFalse);
    expect(c.estado, EstadoPantallaCaja.listo);
    expect(c.cajas.length, 1);
    expect(c.error, 'Sin conexión');
  });

  test('si falla el ultimo cierre la pantalla sigue lista', () async {
    final repo = _RepoFalso(
      resumenesAccion: (_) async => [_resumen(1, 'Caja Principal')],
      estadosAccion: (_) async => [
        _estado(1, 'Caja Principal', abierta: false),
      ],
      cierresAccion: (_) async => throw const ApiException('Sin conexión'),
    );

    final c = await _construir(repo);

    expect(c.estado, EstadoPantallaCaja.listo);
    expect(c.ultimoCierre, isNull);
  });

  test('no notifica despues de liberar el controlador', () async {
    final espera = Completer<List<ResumenCaja>>();
    final repo = _RepoFalso(resumenesAccion: (_) => espera.future);
    final c = CajaController(repositorio: repo, empresaId: 7);
    final carga = c.cargar();
    c.dispose();
    espera.complete([_resumen(1, 'Caja Principal')]);
    await expectLater(carga, completes);
  });
}
