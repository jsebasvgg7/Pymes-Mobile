import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/apertura_caja.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/caja_creada.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/cierre_caja_resultado.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/configuracion_caja.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/estado_caja.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/forma_pago_caja.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/movimiento_caja.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/resumen_caja.dart';

const String _resumenes = r'''[
  {"cajaId":1,"cajaNombre":"Caja Principal","saldoInicial":10000.0,
   "saldoActual":59748038.0,"totalIngresos":524769008.0,
   "totalEgresos":471020970.0,"totalMovimientos":18805},
  {"cajaId":2,"cajaNombre":"Caja 2","saldoInicial":316155.0,
   "saldoActual":316155.0,"totalIngresos":0.0,"totalEgresos":0.0,
   "totalMovimientos":0}
]''';

const String _estados = r'''[
  {"cajaId":1,"cajaNombre":"Caja Principal","abierta":true,
   "requiereCierre":true,
   "apertura":{"id":733,"cajaId":1,"cajaNombre":"Caja Principal",
     "estado":"ABIERTA","usuarioAperturaId":1,
     "usuarioAperturaNombre":"Don Carlos",
     "fechaApertura":"2026-11-10T18:51:14.154841","efectivoInicial":0.0,
     "usuarioCierreId":null,"usuarioCierreNombre":null,"fechaCierre":null,
     "efectivoEsperado":null,"efectivoContado":null,"diferencia":null,
     "tipoCierre":null,"resultado":null,"requiereCierre":true},
   "efectivoSugerido":10000.0},
  {"cajaId":2,"cajaNombre":"Caja 2","abierta":false,"requiereCierre":false,
   "apertura":null,"efectivoSugerido":316155.0}
]''';

const String _movimientos = r'''{
  "content":[
    {"id":132188,"createdAt":"2026-11-11T15:19:00","updatedAt":"2026-11-11T15:19:00",
     "active":true,"empresaId":1,"cajaId":1,"cajaNombre":"Caja Principal",
     "formaPagoId":1,"formaPagoNombre":"Efectivo","fecha":"2026-11-11T15:19:00",
     "tipo":"INGRESO","monto":14500.0,
     "descripcion":"Venta factura #FAC-20261111-29100",
     "tipoReferencia":"VENTA","referenciaId":29100},
    {"id":132187,"createdAt":"2026-11-11T15:14:00","updatedAt":"2026-11-11T15:14:00",
     "active":true,"empresaId":1,"cajaId":1,"cajaNombre":"Caja Principal",
     "formaPagoId":1,"formaPagoNombre":"Efectivo","fecha":"2026-11-11T15:14:00",
     "tipo":"EGRESO","monto":45000.0,
     "descripcion":"Pago de energía del local",
     "tipoReferencia":"GASTO","referenciaId":null}
  ],
  "totalPages":950,"number":0,"totalElements":18905
}''';

const String _cierre = r'''{
  "apertura":{"id":733,"cajaId":1,"cajaNombre":"Caja Principal",
    "estado":"CERRADA","usuarioAperturaId":1,
    "usuarioAperturaNombre":"Don Carlos",
    "fechaApertura":"2026-11-11T08:00:00",
    "efectivoInicial":100000.0,"usuarioCierreId":1,
    "usuarioCierreNombre":"Don Carlos","fechaCierre":"2026-11-11T15:52:00",
    "efectivoEsperado":628000.0,"efectivoContado":612500.0,
    "diferencia":-15500.0,"tipoCierre":"MANUAL","resultado":"FALTANTE",
    "requiereCierre":false},
  "ingresosOtrosMedios":209390.0,"egresosOtrosMedios":0.0
}''';

const String _formas = r'''{"content":[
  {"id":1,"nombre":"Efectivo","tipo":"EFECTIVO","active":true},
  {"id":2,"nombre":"Tarjeta","tipo":"TARJETA","active":true},
  {"id":3,"nombre":"Transferencia","tipo":"TRANSFERENCIA","active":true},
  {"id":4,"nombre":"Crédito","tipo":"CREDITO","active":true}
],"totalPages":1,"totalElements":4}''';

const String _configuracion =
    r'''{"empresaId":1,"moneda":"COP","simboloMoneda":"$"}''';

const String _cajaCreada =
    r'''{"id":3,"empresaId":1,"nombre":"Caja 3","saldoInicial":0.0,"saldoActual":0.0}''';

dynamic _json(String texto) => jsonDecode(texto);

void main() {
  test('los resumenes traen saldos y totales historicos', () {
    final lista = ResumenCaja.listaDesdeJson(_json(_resumenes));

    expect(lista, hasLength(2));
    expect(lista.first.cajaId, 1);
    expect(lista.first.cajaNombre, 'Caja Principal');
    expect(lista.first.saldoActual, 59748038);
    expect(lista.first.totalIngresos, 524769008);
    expect(lista.first.totalEgresos, 471020970);
    expect(lista.first.totalMovimientos, 18805);
    expect(lista.last.totalMovimientos, 0);
  });

  test('los estados reconocen caja abierta y cierre pendiente', () {
    final lista = EstadoCaja.listaDesdeJson(_json(_estados));

    expect(lista, hasLength(2));
    expect(lista.first.abierta, isTrue);
    expect(lista.first.cierrePendiente, isTrue);
    expect(lista.first.apertura, isNotNull);
    expect(lista.first.apertura!.id, 733);
    expect(lista.first.apertura!.estado, EstadoAperturaCaja.abierta);
    expect(lista.first.apertura!.usuarioAperturaNombre, 'Don Carlos');
    expect(lista.first.efectivoSugerido, 10000);
    expect(lista.last.cerrada, isTrue);
    expect(lista.last.apertura, isNull);
    expect(lista.last.efectivoSugerido, 316155);
  });

  test('una apertura cerrada trae resultado, diferencia y tipo de cierre', () {
    final apertura = AperturaCaja.fromJson(
      (_json(_cierre) as Map<String, dynamic>)['apertura']
          as Map<String, dynamic>,
    );

    expect(apertura.abierta, isFalse);
    expect(apertura.fechaApertura, DateTime(2026, 11, 11, 8));
    expect(apertura.fechaCierre, DateTime(2026, 11, 11, 15, 52));
    expect(apertura.efectivoEsperado, 628000);
    expect(apertura.efectivoContado, 612500);
    expect(apertura.diferencia, -15500);
    expect(apertura.tipoCierre, TipoCierreCaja.manual);
    expect(apertura.resultado, ResultadoCierreCaja.faltante);
    expect(apertura.requiereCierre, isFalse);
  });

  test('el cierre trae otros medios y el resultado de la apertura', () {
    final cierre = CierreCajaResultado.fromJson(
      _json(_cierre) as Map<String, dynamic>,
    );

    expect(cierre.apertura.resultado, ResultadoCierreCaja.faltante);
    expect(cierre.apertura.diferencia, -15500);
    expect(cierre.ingresosOtrosMedios, 209390);
    expect(cierre.egresosOtrosMedios, 0);
  });

  test('los movimientos separan titulo, codigo y gasto', () {
    final pagina = PaginaMovimientosCaja.desdeJson(_json(_movimientos));

    expect(pagina.items, hasLength(2));
    expect(pagina.pagina, 0);
    expect(pagina.totalPaginas, 950);
    expect(pagina.totalElementos, 18905);
    expect(pagina.hayMas, isTrue);

    final venta = pagina.items.first;
    expect(venta.tipo, TipoMovimientoCaja.ingreso);
    expect(venta.esIngreso, isTrue);
    expect(venta.formaPagoNombre, 'Efectivo');
    expect(venta.titulo, 'Venta factura');
    expect(venta.codigo, '#FAC-20261111-29100');
    expect(venta.fecha, DateTime(2026, 11, 11, 15, 19));
    expect(venta.referenciaId, 29100);

    final gasto = pagina.items.last;
    expect(gasto.tipo, TipoMovimientoCaja.egreso);
    expect(gasto.esGasto, isTrue);
    expect(gasto.tipoReferencia, TipoReferenciaMovimientoCaja.gasto);
    expect(gasto.titulo, 'Pago de energía del local');
    expect(gasto.codigo, isNull);
    expect(gasto.referenciaId, isNull);
  });

  test('un movimiento sin descripcion usa el tipo como concepto', () {
    final movimiento = MovimientoCaja.fromJson({
      'id': 1,
      'tipo': 'EGRESO',
      'monto': 2000,
    });

    expect(movimiento.concepto, 'Egreso');
    expect(movimiento.titulo, 'Egreso');
    expect(movimiento.codigo, isNull);
    expect(movimiento.tipoReferencia, TipoReferenciaMovimientoCaja.ajuste);
  });

  test('las formas de pago leen tipo y estado activo', () {
    final formas = FormaPagoCaja.listaDesdePagina(_json(_formas));

    expect(formas, hasLength(4));
    expect(formas.first.esEfectivo, isTrue);
    expect(formas[1].tipo, TipoFormaPagoCaja.tarjeta);
    expect(formas[2].tipo, TipoFormaPagoCaja.transferencia);
    expect(formas.last.esCredito, isTrue);
    expect(formas.every((f) => f.activo), isTrue);
  });

  test('la configuracion usa COP y dollar si faltan datos', () {
    final configuracion = ConfiguracionCaja.fromJson(
      _json(_configuracion) as Map<String, dynamic>,
    );
    final vacia = ConfiguracionCaja.fromJson(const {});

    expect(configuracion.moneda, 'COP');
    expect(configuracion.simboloMoneda, r'$');
    expect(vacia.moneda, 'COP');
    expect(vacia.simboloMoneda, r'$');
  });

  test('la caja creada trae id, empresa y saldos', () {
    final caja = CajaCreada.fromJson(
      _json(_cajaCreada) as Map<String, dynamic>,
    );

    expect(caja.id, 3);
    expect(caja.empresaId, 1);
    expect(caja.nombre, 'Caja 3');
    expect(caja.saldoInicial, 0);
    expect(caja.saldoActual, 0);
  });

  test('una pagina sin contenido queda vacia y sin mas paginas', () {
    final pagina = PaginaCierresCaja.desdeJson({
      'content': [],
      'totalPages': 0,
      'number': 0,
      'totalElements': 0,
    });

    expect(pagina.items, isEmpty);
    expect(pagina.hayMas, isFalse);
  });
}
