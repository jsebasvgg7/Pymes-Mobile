import '../../../../core/format/numero.dart';

enum EstadoStock { disponible, bajo, agotado }

class InventarioItem {
  const InventarioItem({
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
  final String unidadMedida;
  final num cantidadActual;
  final num costoPromedio;
  final num stockMinimo;
  final num precioVenta;
  final bool stockBajo;

  bool get permiteDecimales => _unidadesDecimales.contains(unidadMedida);

  EstadoStock get estado {
    if (cantidadActual <= 0) return EstadoStock.agotado;
    if (cantidadActual <= stockMinimo) return EstadoStock.bajo;
    return EstadoStock.disponible;
  }

  factory InventarioItem.fromJson(Map<String, dynamic> json) {
    final categoria = _texto(json['categoriaNombre']);
    return InventarioItem(
      productoId: aNumero(json['productoId']).toInt(),
      nombre: _texto(json['productoNombre']),
      sku: _texto(json['productoSku']),
      categoria: categoria.isEmpty ? sinCategoria : categoria,
      unidadMedida: _texto(json['unidadMedida']).toUpperCase(),
      cantidadActual: aNumero(json['cantidadActual']),
      costoPromedio: aNumero(json['costoPromedio']),
      stockMinimo: aNumero(json['stockMinimo']),
      precioVenta: aNumero(json['precioVenta']),
      stockBajo: json['stockBajo'] == true,
    );
  }

  static List<InventarioItem> listaDesdeJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .whereType<Map<String, dynamic>>()
        .map(InventarioItem.fromJson)
        .toList();
  }
}

String _texto(dynamic valor) => valor is String ? valor.trim() : '';
