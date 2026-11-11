import '../format/numero.dart';

enum EstadoStock { disponible, bajo, agotado }

class ProductoInventario {
  const ProductoInventario({
    required this.productoId,
    required this.nombre,
    required this.sku,
    required this.categoria,
    required this.unidadMedida,
    required this.cantidadActual,
    required this.costoPromedio,
    required this.stockMinimo,
    required this.precioVenta,
    required this.stockBajo,
    this.categoriaId,
    this.descripcion = '',
  });

  static const String sinCategoria = 'Sin categoría';

  static const Set<String> _unidadesDecimales = {
    'KILOGRAMO',
    'GRAMO',
    'LITRO',
    'MILILITRO',
  };

  final int productoId;
  final String nombre;
  final String sku;
  final String categoria;
  final int? categoriaId;
  final String descripcion;
  final String unidadMedida;
  final num cantidadActual;
  final num costoPromedio;
  final num stockMinimo;
  final num precioVenta;
  final bool stockBajo;

  bool get permiteDecimales => _unidadesDecimales.contains(unidadMedida);

  bool get agotado => cantidadActual <= 0;

  EstadoStock get estado {
    if (agotado) return EstadoStock.agotado;
    if (cantidadActual <= stockMinimo) return EstadoStock.bajo;
    return EstadoStock.disponible;
  }

  factory ProductoInventario.fromJson(Map<String, dynamic> json) {
    final categoria = _texto(json['categoriaNombre']);
    final id = json['categoriaId'];
    return ProductoInventario(
      productoId: aNumero(json['productoId'] ?? json['id']).toInt(),
      nombre: _texto(json['productoNombre'] ?? json['nombre']),
      sku: _texto(json['productoSku'] ?? json['sku']),
      categoria: categoria.isEmpty ? sinCategoria : categoria,
      categoriaId: id is num ? id.toInt() : null,
      descripcion: _texto(json['descripcion']),
      unidadMedida: _texto(json['unidadMedida']).toUpperCase(),
      cantidadActual: aNumero(json['cantidadActual'] ?? json['stockActual']),
      costoPromedio: aNumero(json['costoPromedio']),
      stockMinimo: aNumero(json['stockMinimo']),
      precioVenta: aNumero(json['precioVenta']),
      stockBajo: json['stockBajo'] == true,
    );
  }

  static List<ProductoInventario> listaDesdeJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .whereType<Map<String, dynamic>>()
        .map(ProductoInventario.fromJson)
        .toList();
  }

  static List<ProductoInventario> listaDesdePagina(dynamic json) {
    if (json is! Map) return const [];
    final contenido = json['content'];
    if (contenido is! List) return const [];
    return contenido
        .whereType<Map<String, dynamic>>()
        .map(ProductoInventario.fromJson)
        .toList();
  }
}

String _texto(dynamic valor) => valor is String ? valor.trim() : '';
