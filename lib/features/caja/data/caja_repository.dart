import '../../../core/network/api_client.dart';
import 'models/apertura_caja.dart';
import 'models/caja_creada.dart';
import 'models/cierre_caja_resultado.dart';
import 'models/configuracion_caja.dart';
import 'models/estado_caja.dart';
import 'models/forma_pago_caja.dart';
import 'models/movimiento_caja.dart';
import 'models/resumen_caja.dart';

class CajaRepository {
  CajaRepository({required this._cliente});

  final ApiClient _cliente;

  Future<List<ResumenCaja>> resumenes(int empresaId) async {
    final respuesta = await _cliente.get('/api/caja/resumen-todas/$empresaId');
    return ResumenCaja.listaDesdeJson(respuesta);
  }

  Future<List<EstadoCaja>> estados(int empresaId) async {
    final respuesta = await _cliente.get('/api/caja/estados/$empresaId');
    return EstadoCaja.listaDesdeJson(respuesta);
  }

  Future<PaginaCierresCaja> cierres(
    int cajaId, {
    int pagina = 0,
    int tamano = 1,
  }) async {
    final respuesta = await _cliente.get(
      '/api/caja/cierres/$cajaId',
      query: {'page': pagina, 'size': tamano},
    );
    return PaginaCierresCaja.desdeJson(respuesta);
  }

  Future<PaginaMovimientosCaja> movimientos(
    int cajaId, {
    int pagina = 0,
    int tamano = 20,
  }) async {
    final respuesta = await _cliente.get(
      '/api/caja/movimientos/caja/$cajaId',
      query: {'page': pagina, 'size': tamano, 'sort': 'fecha,desc'},
    );
    return PaginaMovimientosCaja.desdeJson(respuesta);
  }

  Future<List<FormaPagoCaja>> formasDePago(int empresaId) async {
    final respuesta = await _cliente.get(
      '/api/formas-pago/listar-por-empresa/$empresaId',
      query: {'page': 0, 'size': 200},
    );
    return FormaPagoCaja.listaDesdePagina(respuesta);
  }

  Future<ConfiguracionCaja> configuracion(int empresaId) async {
    final respuesta = await _cliente.get('/api/configuracion/$empresaId');
    return ConfiguracionCaja.fromJson(_mapa(respuesta));
  }

  Future<AperturaCaja> abrir(int cajaId, num efectivoInicial) async {
    final respuesta = await _cliente.post(
      '/api/caja/abrir/$cajaId',
      datos: {'efectivoInicial': efectivoInicial},
    );
    return AperturaCaja.fromJson(_mapa(respuesta));
  }

  Future<CierreCajaResultado> cerrar(int cajaId, num efectivoContado) async {
    final respuesta = await _cliente.post(
      '/api/caja/cerrar/$cajaId',
      datos: {'efectivoContado': efectivoContado},
    );
    return CierreCajaResultado.fromJson(_mapa(respuesta));
  }

  Future<AperturaCaja> reabrir(int cajaId) async {
    final respuesta = await _cliente.post('/api/caja/reabrir/$cajaId');
    return AperturaCaja.fromJson(_mapa(respuesta));
  }

  Future<MovimientoCaja> registrarMovimiento({
    required int empresaId,
    required int cajaId,
    required int formaPagoId,
    required TipoMovimientoCaja tipo,
    required num monto,
    required String descripcion,
    TipoReferenciaMovimientoCaja? tipoReferencia,
  }) async {
    final datos = <String, dynamic>{
      'empresaId': empresaId,
      'cajaId': cajaId,
      'formaPagoId': formaPagoId,
      'tipo': tipo.name.toUpperCase(),
      'monto': monto,
      'descripcion': descripcion,
    };
    if (tipoReferencia != null) {
      datos['tipoReferencia'] = tipoReferencia.name.toUpperCase();
    }
    final respuesta = await _cliente.post(
      '/api/caja/movimientos/registrar',
      datos: datos,
    );
    return MovimientoCaja.fromJson(_mapa(respuesta));
  }

  Future<CajaCreada> crearCaja({
    required int empresaId,
    required String nombre,
    num? saldoInicial,
  }) async {
    final datos = <String, dynamic>{'empresaId': empresaId, 'nombre': nombre};
    if (saldoInicial != null) {
      datos['saldoInicial'] = saldoInicial;
    }
    final respuesta = await _cliente.post('/api/caja/crear', datos: datos);
    return CajaCreada.fromJson(_mapa(respuesta));
  }
}

Map<String, dynamic> _mapa(dynamic json) {
  if (json is Map<String, dynamic>) return json;
  return <String, dynamic>{};
}
