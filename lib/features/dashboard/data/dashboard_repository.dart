import '../../../core/network/api_client.dart';
import 'models/dashboard_resumen.dart';
import 'models/flujo_dia.dart';
import 'models/movimiento_caja.dart';
import 'models/ventas_hoy.dart';

class DashboardDatos {
  const DashboardDatos({
    required this.resumen,
    required this.ventasHoy,
    this.flujo,
    this.movimientos,
  });

  final DashboardResumen resumen;
  final VentasHoy? ventasHoy;
  final List<FlujoDia>? flujo;
  final List<MovimientoCaja>? movimientos;
}

class DashboardRepository {
  DashboardRepository({required this._cliente});

  static const int _movimientosRecientes = 4;

  final ApiClient _cliente;

  Future<DashboardDatos> obtener(int empresaId) async {
    final ventas = _ventasHoy(empresaId);
    final flujo = _flujo(empresaId);
    final movimientos = _movimientos(empresaId);
    final respuesta = await _cliente.get('/api/dashboard/resumen/$empresaId');
    final resumen = DashboardResumen.fromJson(
      respuesta as Map<String, dynamic>,
    );
    return DashboardDatos(
      resumen: resumen,
      ventasHoy: await ventas,
      flujo: await flujo,
      movimientos: await movimientos,
    );
  }

  Future<VentasHoy?> _ventasHoy(int empresaId) async {
    try {
      final dia = _diaLocal(DateTime.now());
      final respuesta = await _cliente.get(
        '/api/facturas-venta/por-periodo/$empresaId',
        query: {'inicio': '${dia}T00:00:00', 'fin': '${dia}T23:59:59'},
      );
      return VentasHoy.desdeFacturas(respuesta as List<dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<List<FlujoDia>?> _flujo(int empresaId) async {
    try {
      final respuesta = await _cliente.get(
        '/api/caja/movimientos/flujo-diario/$empresaId',
        query: {'mesesAtras': 1},
      );
      return FlujoDia.listaDesdeJson(respuesta);
    } catch (_) {
      return null;
    }
  }

  Future<List<MovimientoCaja>?> _movimientos(int empresaId) async {
    try {
      final respuesta = await _cliente.get(
        '/api/caja/movimientos/empresa/$empresaId',
        query: {'page': 0, 'size': _movimientosRecientes, 'sort': 'fecha,desc'},
      );
      return MovimientoCaja.listaDesdePagina(respuesta);
    } catch (_) {
      return null;
    }
  }

  String _diaLocal(DateTime fecha) {
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');
    return '${fecha.year}-$mes-$dia';
  }
}
