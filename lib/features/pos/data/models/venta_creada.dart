import '../../../../core/format/fecha.dart';
import '../../../../core/format/numero.dart';

class DetalleVenta {
  const DetalleVenta({
    required this.productoId,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.totalLinea,
  });

  final int? productoId;
  final String descripcion;
  final num cantidad;
  final num precioUnitario;
  final num totalLinea;

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    final descripcion = (json['descripcion'] as String?)?.trim() ?? '';
    final productoNombre = (json['productoNombre'] as String?)?.trim() ?? '';
    return DetalleVenta(
      productoId: json['productoId'] == null
          ? null
          : aNumero(json['productoId']).toInt(),
      descripcion: descripcion.isNotEmpty ? descripcion : productoNombre,
      cantidad: aNumero(json['cantidad']),
      precioUnitario: aNumero(json['precioUnitario']),
      totalLinea: aNumero(json['totalLinea']),
    );
  }
}

class VentaCreada {
  const VentaCreada({
    required this.id,
    required this.numero,
    required this.estado,
    required this.subtotal,
    required this.descuento,
    required this.total,
    this.fechaEmision,
    this.clienteNombre = '',
    this.formaPagoNombre = '',
    this.detalles = const [],
  });

  final int id;
  final String numero;
  final String estado;
  final DateTime? fechaEmision;
  final String clienteNombre;
  final String formaPagoNombre;
  final num subtotal;
  final num descuento;
  final num total;
  final List<DetalleVenta> detalles;

  factory VentaCreada.fromJson(Map<String, dynamic> json) {
    final detalles = json['detalles'];
    return VentaCreada(
      id: aNumero(json['id']).toInt(),
      numero: (json['numero'] as String?)?.trim() ?? '',
      estado: (json['estado'] as String?)?.trim() ?? '',
      fechaEmision: parsearFechaIso(json['fechaEmision']),
      clienteNombre: (json['clienteNombre'] as String?)?.trim() ?? '',
      formaPagoNombre: (json['formaPagoNombre'] as String?)?.trim() ?? '',
      subtotal: aNumero(json['subtotal']),
      descuento: aNumero(json['descuento']),
      total: aNumero(json['total']),
      detalles: detalles is List
          ? detalles
                .whereType<Map<String, dynamic>>()
                .map(DetalleVenta.fromJson)
                .toList()
          : const <DetalleVenta>[],
    );
  }
}
