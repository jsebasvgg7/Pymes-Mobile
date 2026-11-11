import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/caja_repository.dart';
import '../data/models/apertura_caja.dart';
import '../data/models/cierre_caja_resultado.dart';
import '../data/models/estado_caja.dart';
import '../data/models/resumen_caja.dart';

enum EstadoPantallaCaja { cargando, listo, error }

class CajaVista {
  const CajaVista({required this.resumen, this.estado});

  final ResumenCaja resumen;
  final EstadoCaja? estado;

  int get cajaId => resumen.cajaId;

  String get nombre {
    if (resumen.cajaNombre.isNotEmpty) return resumen.cajaNombre;
    return estado?.cajaNombre ?? '';
  }

  bool get abierta => estado?.abierta ?? false;

  bool get cierrePendiente => estado?.cierrePendiente ?? false;
}

class CajaController extends ChangeNotifier {
  CajaController({
    required this._repositorio,
    required this.empresaId,
    DateTime Function()? ahora,
  }) : _ahora = ahora ?? DateTime.now;

  final CajaRepository _repositorio;
  final int empresaId;
  final DateTime Function() _ahora;

  EstadoPantallaCaja _estado = EstadoPantallaCaja.cargando;
  List<CajaVista> _cajas = const [];
  int? _seleccionadaId;
  AperturaCaja? _ultimoCierre;
  String? _error;
  String? _errorAccion;
  int? _codigoErrorAccion;
  bool _procesandoAccion = false;
  bool _hayDatos = false;
  bool _liberado = false;
  int _versionCierre = 0;

  EstadoPantallaCaja get estado => _estado;
  List<CajaVista> get cajas => _cajas;
  int? get seleccionadaId => _seleccionadaId;
  AperturaCaja? get ultimoCierre => _ultimoCierre;
  String? get error => _error;
  String? get errorAccion => _errorAccion;
  int? get codigoErrorAccion => _codigoErrorAccion;
  bool get procesandoAccion => _procesandoAccion;

  CajaVista? get seleccionada {
    final id = _seleccionadaId;
    if (id == null) return null;
    for (final caja in _cajas) {
      if (caja.cajaId == id) return caja;
    }
    return null;
  }

  bool get abierta => seleccionada?.abierta ?? false;

  bool get cierrePendiente => seleccionada?.cierrePendiente ?? false;

  bool get puedeReabrir {
    if (abierta) return false;
    final fecha = _ultimoCierre?.fechaCierre;
    if (fecha == null) return false;
    final hoy = _ahora();
    return fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day;
  }

  Future<void> cargar() async {
    _estado = EstadoPantallaCaja.cargando;
    _error = null;
    _notificar();
    await _consultar();
  }

  Future<bool> refrescar() => _consultar();

  Future<bool> _ejecutarAccion(Future<void> Function() accion) async {
    _errorAccion = null;
    _codigoErrorAccion = null;
    _procesandoAccion = true;
    _notificar();
    try {
      await accion();
      return true;
    } on ApiException catch (e) {
      _errorAccion = e.mensaje;
      _codigoErrorAccion = e.status;
      if (e.status == 409) await _consultar();
      _notificar();
      return false;
    } catch (_) {
      _errorAccion = 'Ocurrió un error inesperado. Intenta de nuevo.';
      _codigoErrorAccion = null;
      _notificar();
      return false;
    } finally {
      _procesandoAccion = false;
    }
  }

  Future<bool> abrirCaja(num efectivoInicial) async {
    final caja = seleccionada;
    if (caja == null || caja.abierta) return false;
    return _ejecutarAccion(() async {
      await _repositorio.abrir(caja.cajaId, efectivoInicial);
    });
  }

  Future<CierreCajaResultado?> cerrarCaja(num efectivoContado) async {
    final caja = seleccionada;
    if (caja == null || !caja.abierta) return null;
    _errorAccion = null;
    _codigoErrorAccion = null;
    _procesandoAccion = true;
    _notificar();
    try {
      final resultado = await _repositorio.cerrar(caja.cajaId, efectivoContado);
      await _consultar();
      return resultado;
    } on ApiException catch (e) {
      _errorAccion = e.mensaje;
      _codigoErrorAccion = e.status;
      if (e.status == 409) await _consultar();
      _notificar();
      return null;
    } catch (_) {
      _errorAccion = 'Ocurrió un error inesperado. Intenta de nuevo.';
      _codigoErrorAccion = null;
      _notificar();
      return null;
    } finally {
      _procesandoAccion = false;
    }
  }

  Future<bool> reabrirCaja() async {
    if (!puedeReabrir) {
      _errorAccion = 'Solo puedes reabrir el último cierre del mismo día.';
      _codigoErrorAccion = null;
      _notificar();
      return false;
    }
    final caja = seleccionada;
    if (caja == null || caja.abierta) return false;
    return _ejecutarAccion(() async {
      await _repositorio.reabrir(caja.cajaId);
    });
  }

  Future<void> seleccionarCaja(int cajaId) async {
    if (cajaId == _seleccionadaId) return;
    _seleccionadaId = cajaId;
    _ultimoCierre = null;
    _versionCierre++;
    _notificar();
    final caja = seleccionada;
    if (caja == null || caja.abierta) return;
    await _cargarUltimoCierre(caja.cajaId);
  }

  Future<bool> _consultar() async {
    try {
      final resumenesFuturo = _repositorio.resumenes(empresaId);
      final estadosFuturo = _repositorio.estados(empresaId);
      final resumenes = await resumenesFuturo;
      final estados = await estadosFuturo;
      final porCaja = {for (final estado in estados) estado.cajaId: estado};
      final cajas = resumenes
          .map(
            (resumen) =>
                CajaVista(resumen: resumen, estado: porCaja[resumen.cajaId]),
          )
          .toList();
      _cajas = List.unmodifiable(cajas);
      final seleccionadaExiste = cajas.any(
        (caja) => caja.cajaId == _seleccionadaId,
      );
      if (!seleccionadaExiste) {
        _seleccionadaId = cajas.isEmpty ? null : cajas.first.cajaId;
      }
      _ultimoCierre = null;
      _versionCierre++;
      _hayDatos = true;
      _estado = EstadoPantallaCaja.listo;
      _error = null;
      _notificar();
      final caja = seleccionada;
      if (caja != null && !caja.abierta) {
        await _cargarUltimoCierre(caja.cajaId);
      }
      return true;
    } on ApiException catch (e) {
      return _fallar(e.mensaje);
    } catch (_) {
      return _fallar('Ocurrió un error inesperado. Intenta de nuevo.');
    }
  }

  Future<void> _cargarUltimoCierre(int cajaId) async {
    final version = ++_versionCierre;
    try {
      final pagina = await _repositorio.cierres(cajaId);
      if (_liberado || version != _versionCierre || cajaId != _seleccionadaId) {
        return;
      }
      _ultimoCierre = pagina.items.isEmpty ? null : pagina.items.first;
      _notificar();
    } catch (_) {
      if (_liberado || version != _versionCierre || cajaId != _seleccionadaId) {
        return;
      }
      _ultimoCierre = null;
      _notificar();
    }
  }

  bool _fallar(String mensaje) {
    _error = mensaje;
    if (!_hayDatos) _estado = EstadoPantallaCaja.error;
    _notificar();
    return false;
  }

  void _notificar() {
    if (!_liberado) notifyListeners();
  }

  @override
  void dispose() {
    _liberado = true;
    super.dispose();
  }
}
