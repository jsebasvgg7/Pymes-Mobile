import '../../../core/network/api_client.dart';
import '../../../core/productos/producto_inventario.dart';
import 'models/ajustes_venta.dart';
import 'models/categoria_pos.dart';
import 'models/cliente_pos.dart';
import 'models/estado_caja.dart';
import 'models/forma_pago.dart';
import 'models/venta_creada.dart';

class LineaVenta {
  const LineaVenta({
    required this.productoId,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
  });

  final int productoId;
  final String descripcion;
  final num cantidad;
  final num precioUnitario;

  Map<String, dynamic> aJson() => {
    'productoId': productoId,
    'descripcion': descripcion,
    'cantidad': cantidad,
    'precioUnitario': precioUnitario,
  };
}

class PosRepository {
  PosRepository({required this._cliente});

  static const int _pagina = 200;

  final ApiClient _cliente;

  Future<List<ProductoInventario>> productos(int empresaId) async {
    final respuesta = await _cliente.get(
      '/api/productos/listar-por-empresa/$empresaId',
      query: {'page': 0, 'size': _pagina},
    );
    return ProductoInventario.listaDesdePagina(respuesta);
  }

  Future<List<CategoriaPos>> categorias(int empresaId) async {
    final respuesta = await _cliente.get(
      '/api/categorias-producto/listar-por-empresa/$empresaId',
      query: {'page': 0, 'size': _pagina},
    );
    return CategoriaPos.listaDesdePagina(respuesta);
  }

  Future<List<FormaPago>> formasDePago(int empresaId) async {
    final respuesta = await _cliente.get(
      '/api/formas-pago/listar-por-empresa/$empresaId',
      query: {'page': 0, 'size': _pagina},
    );
    return FormaPago.listaDesdePagina(respuesta);
  }

  Future<List<ClientePos>> clientes(int empresaId) async {
    final respuesta = await _cliente.get(
      '/api/clientes/listar-por-empresa/$empresaId',
      query: {'page': 0, 'size': _pagina},
    );
    return ClientePos.listaDesdePagina(respuesta);
  }

  Future<AjustesVenta> ajustes(int empresaId) async {
    final respuesta = await _cliente.get('/api/configuracion/$empresaId');
    return AjustesVenta.fromJson(respuesta as Map<String, dynamic>);
  }

  Future<List<EstadoCaja>> estadoDeCajas(int empresaId) async {
    final respuesta = await _cliente.get('/api/caja/estados/$empresaId');
    return EstadoCaja.listaDesdeJson(respuesta);
  }

  Future<String> nombreEmpresa(int empresaId) async {
    final respuesta = await _cliente.get('/api/empresas/$empresaId');
    final json = respuesta as Map<String, dynamic>;
    return (json['nombre'] as String?)?.trim() ?? '';
  }

  Future<VentaCreada> crearVenta({
    required int empresaId,
    required int formaPagoId,
    required List<LineaVenta> lineas,
    int? clienteId,
    num descuento = 0,
  }) async {
    final respuesta = await _cliente.post(
      '/api/facturas-venta/crear',
      datos: {
        'empresaId': empresaId,
        'formaPagoId': formaPagoId,
        'clienteId': ?clienteId,
        'descuento': descuento,
        'detalles': lineas.map((linea) => linea.aJson()).toList(),
      },
    );
    return VentaCreada.fromJson(respuesta as Map<String, dynamic>);
  }

  Future<VentaCreada> anularVenta(int facturaId) async {
    final respuesta = await _cliente.patch(
      '/api/facturas-venta/actualizar-estado/$facturaId',
      datos: {'estado': 'ANULADA'},
    );
    return VentaCreada.fromJson(respuesta as Map<String, dynamic>);
  }
}
