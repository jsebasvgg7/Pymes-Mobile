import '../../../core/network/api_client.dart';
import '../../../core/productos/producto_inventario.dart';

class InventarioRepository {
  InventarioRepository({required this._cliente});

  final ApiClient _cliente;

  Future<List<ProductoInventario>> listar(int empresaId) async {
    final respuesta = await _cliente.get(
      '/api/inventario/listar-por-empresa/$empresaId',
    );
    return ProductoInventario.listaDesdeJson(respuesta);
  }
}
