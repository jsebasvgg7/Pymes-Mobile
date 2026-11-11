import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/caja_repository.dart';
import '../data/models/apertura_caja.dart';
import '../data/models/cierre_caja_resultado.dart';
import '../data/models/estado_caja.dart';
import '../data/models/forma_pago_caja.dart';
import '../data/models/movimiento_caja.dart';
import '../data/models/resumen_caja.dart';

enum EstadoPantallaCaja { cargando, listo, error }

enum EstadoPantallaMovimientos { vacio, cargando, listo, error }

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
  int _versionMovimientos = 0;

  List<MovimientoCaja> _movimientos = const [];
  List<FormaPagoCaja> _formasPago = const [];
  EstadoPantallaMovimientos _estadoMovimientos =
      EstadoPantallaMovimientos.vacio;
  bool _cargandoMovimientos = false;
  int _paginaMovimientos = 0;
  int _totalPaginasMovimientos = 0;
  bool _cargandoMasMovimientos = false;

  EstadoPantallaCaja get estado => _estado;
  List<CajaVista> get cajas => _cajas;
  int? get seleccionadaId => _seleccionadaId;
  AperturaCaja? get ultimoCierre => _ultimoCierre;
  String? get error => _error;
  String? get errorAccion => _errorAccion;
  int? get codigoErrorAccion => _codigoErrorAccion;
  bool get procesandoAccion => _procesandoAccion;

  List<MovimientoCaja> get movimientos => _movimientos;
  List<FormaPagoCaja> get formasPago => _formasPago;
  EstadoPantallaMovimientos get estadoMovimientos => _estadoMovimientos;
  bool get cargandoMovimientos => _cargandoMovimientos;
  bool get hayMasMovimientos =>
      _paginaMovimientos + 1 < _totalPaginasMovimientos;
  bool get cargandoMasMovimientos => _cargandoMasMovimientos;

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

  Future<bool> crearCaja(String nombre, {num? saldoInicial}) async {
    final nombreLimpio = nombre.trim();
    if (nombreLimpio.isEmpty) {
      _errorAccion = 'Ingresa el nombre de la caja.';
      _codigoErrorAccion = null;
      _notificar();
      return false;
    }
    _errorAccion = null;
    _codigoErrorAccion = null;
    _procesandoAccion = true;
    _notificar();
    try {
      await _repositorio.crearCaja(
        empresaId: empresaId,
        nombre: nombreLimpio,
        saldoInicial: saldoInicial,
      );
      await _consultar();
      return true;
    } on ApiException catch (e) {
      _errorAccion = e.mensaje;
      _codigoErrorAccion = e.status;
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

  Future<void> seleccionarCaja(int cajaId) async {
    if (cajaId == _seleccionadaId) return;
    _seleccionadaId = cajaId;
    _ultimoCierre = null;
    _versionCierre++;
    _movimientos = const [];
    _paginaMovimientos = 0;
    _totalPaginasMovimientos = 0;
    _estadoMovimientos = EstadoPantallaMovimientos.vacio;
    _notificar();
    final caja = seleccionada;
    if (caja == null) return;
    if (!caja.abierta) {
      await _cargarUltimoCierre(caja.cajaId);
    }
    await cargarMovimientos(caja.cajaId);
    await cargarFormasPago();
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
      if (caja != null) {
        await cargarMovimientos(caja.cajaId);
        await cargarFormasPago();
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

  Future<void> cargarMovimientos(int cajaId) async {
    final version = ++_versionMovimientos;
    _cargandoMovimientos = true;
    _estadoMovimientos = EstadoPantallaMovimientos.cargando;
    _paginaMovimientos = 0;
    _notificar();
    try {
      final pagina = await _repositorio.movimientos(cajaId);
      if (_liberado ||
          version != _versionMovimientos ||
          cajaId != _seleccionadaId) {
        return;
      }
      _movimientos = List.unmodifiable(pagina.items);
      _paginaMovimientos = pagina.pagina;
      _totalPaginasMovimientos = pagina.totalPaginas;
      _estadoMovimientos = _movimientos.isEmpty
          ? EstadoPantallaMovimientos.vacio
          : EstadoPantallaMovimientos.listo;
    } catch (_) {
      if (_liberado ||
          version != _versionMovimientos ||
          cajaId != _seleccionadaId) {
        return;
      }
      _estadoMovimientos = EstadoPantallaMovimientos.error;
    }
    if (_liberado ||
        version != _versionMovimientos ||
        cajaId != _seleccionadaId) {
      return;
    }
    _cargandoMovimientos = false;
    _notificar();
  }

  Future<void> cargarMasMovimientos() async {
    final caja = seleccionada;
    if (caja == null) return;
    if (_cargandoMasMovimientos || !hayMasMovimientos) return;
    final version = _versionMovimientos;
    final pagina = _paginaMovimientos + 1;
    _cargandoMasMovimientos = true;
    _notificar();
    try {
      final resultado = await _repositorio.movimientos(
        caja.cajaId,
        pagina: pagina,
      );
      if (_liberado ||
          version != _versionMovimientos ||
          caja.cajaId != _seleccionadaId) {
        return;
      }
      _movimientos = List.unmodifiable([..._movimientos, ...resultado.items]);
      _paginaMovimientos = resultado.pagina;
      _totalPaginasMovimientos = resultado.totalPaginas;
      if (_movimientos.isNotEmpty) {
        _estadoMovimientos = EstadoPantallaMovimientos.listo;
      }
    } catch (_) {
      if (_liberado ||
          version != _versionMovimientos ||
          caja.cajaId != _seleccionadaId) {
        return;
      }
      _cargandoMasMovimientos = false;
      _notificar();
      rethrow;
    }
    _cargandoMasMovimientos = false;
    _notificar();
  }

  Future<void> cargarFormasPago() async {
    if (_formasPago.isNotEmpty) return;
    try {
      final formas = await _repositorio.formasDePago(empresaId);
      if (_liberado) return;
      _formasPago = List.unmodifiable(
        formas.where((f) => f.activo && !f.esCredito).toList(),
      );
      _notificar();
    } catch (_) {
      return;
    }
  }

  Future<bool> registrarMovimiento({
    required TipoMovimientoCaja tipo,
    required int formaPagoId,
    required num monto,
    required String descripcion,
    TipoReferenciaMovimientoCaja tipoReferencia =
        TipoReferenciaMovimientoCaja.ajuste,
  }) async {
    final caja = seleccionada;
    if (caja == null || !caja.abierta) return false;
    _errorAccion = null;
    _codigoErrorAccion = null;
    _procesandoAccion = true;
    _notificar();
    try {
      await _repositorio.registrarMovimiento(
        empresaId: empresaId,
        cajaId: caja.cajaId,
        formaPagoId: formaPagoId,
        tipo: tipo,
        monto: monto,
        descripcion: descripcion,
        tipoReferencia: tipoReferencia,
      );
      await _consultar();
      final cajaId = seleccionadaId ?? caja.cajaId;
      await cargarMovimientos(cajaId);
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
