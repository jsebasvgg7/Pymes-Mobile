import '../../../core/network/api_client.dart';
import 'models/inventario_item.dart';

class InventarioRepository {
  InventarioRepository({required this._cliente});

  final ApiClient _cliente;

  Future<List<InventarioItem>> listar(int empresaId) async {
    final respuesta = await _cliente.get(
      '/api/inventario/listar-por-empresa/$empresaId',
    );
    return InventarioItem.listaDesdeJson(respuesta);
  }
}
