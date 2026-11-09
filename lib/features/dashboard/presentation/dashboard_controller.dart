import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/dashboard_repository.dart';
import '../data/models/dashboard_resumen.dart';
import '../data/models/flujo_dia.dart';
import '../data/models/movimiento_caja.dart';
import '../data/models/ventas_hoy.dart';

enum EstadoDashboard { cargando, listo, error }

class DashboardController extends ChangeNotifier {
  DashboardController({
    required this._repositorio,
    required this.empresaId,
    DateTime Function()? ahora,
  }) : _ahora = ahora ?? DateTime.now;

  final DashboardRepository _repositorio;
  final int empresaId;
  final DateTime Function() _ahora;

  EstadoDashboard _estado = EstadoDashboard.cargando;
  DashboardResumen? _resumen;
  VentasHoy? _ventasHoy;
  List<FlujoDia>? _flujo;
  List<MovimientoCaja>? _movimientos;
  PeriodoFlujo _periodoFlujo = PeriodoFlujo.diario;
  DateTime? _actualizadoEn;
  String? _error;
  bool _liberado = false;

  EstadoDashboard get estado => _estado;
  DashboardResumen? get resumen => _resumen;
  VentasHoy? get ventasHoy => _ventasHoy;
  List<MovimientoCaja>? get movimientos => _movimientos;
  PeriodoFlujo get periodoFlujo => _periodoFlujo;
  DateTime? get actualizadoEn => _actualizadoEn;

  List<PuntoFlujo>? get serieFlujo {
    final flujo = _flujo;
    if (flujo == null) return null;
    return construirSerie(flujo, _periodoFlujo, _ahora());
  }

  String? get error => _error;

  Future<void> cargar() async {
    _estado = EstadoDashboard.cargando;
    _error = null;
    _notificar();
    await _consultar();
  }

  Future<bool> refrescar() => _consultar();

  void cambiarPeriodo(PeriodoFlujo periodo) {
    if (periodo == _periodoFlujo) return;
    _periodoFlujo = periodo;
    _notificar();
  }

  Future<bool> _consultar() async {
    try {
      final datos = await _repositorio.obtener(empresaId);
      _resumen = datos.resumen;
      _ventasHoy = datos.ventasHoy;
      _flujo = datos.flujo;
      _movimientos = datos.movimientos;
      _actualizadoEn = datos.resumen.fechaConsulta ?? _ahora();
      _estado = EstadoDashboard.listo;
      _error = null;
      _notificar();
      return true;
    } on ApiException catch (e) {
      return _fallar(e.mensaje);
    } catch (_) {
      return _fallar('Ocurrió un error inesperado. Intenta de nuevo.');
    }
  }

  bool _fallar(String mensaje) {
    _error = mensaje;
    if (_resumen == null) _estado = EstadoDashboard.error;
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
