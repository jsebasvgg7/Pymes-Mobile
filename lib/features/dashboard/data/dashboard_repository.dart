import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'models/dashboard_resumen.dart';
import 'models/ventas_hoy.dart';

class DashboardDatos {
  const DashboardDatos({required this.resumen, required this.ventasHoy});

  final DashboardResumen resumen;
  final VentasHoy? ventasHoy;
}

class DashboardRepository {
  DashboardRepository({required this._cliente});

  final ApiClient _cliente;

  Future<DashboardDatos> obtener(int empresaId) async {
    final ventas = _ventasHoy(empresaId);
    final respuesta = await _cliente.get('/api/dashboard/resumen/$empresaId');
    final resumen = DashboardResumen.fromJson(
      respuesta as Map<String, dynamic>,
    );
    return DashboardDatos(resumen: resumen, ventasHoy: await ventas);
  }

  Future<VentasHoy?> _ventasHoy(int empresaId) async {
    try {
      final dia = _diaLocal(DateTime.now());
      final respuesta = await _cliente.get(
        '/api/facturas-venta/por-periodo/$empresaId',
        query: {'inicio': '${dia}T00:00:00', 'fin': '${dia}T23:59:59'},
      );
      return VentasHoy.desdeFacturas(respuesta as List<dynamic>);
    } on ApiException {
      return null;
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
