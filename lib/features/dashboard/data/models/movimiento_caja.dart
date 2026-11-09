import '../../../../core/format/fecha.dart';
import '../../../../core/format/numero.dart';

class MovimientoCaja {
  const MovimientoCaja({
    required this.id,
    required this.fecha,
    required this.esIngreso,
    required this.monto,
    required this.descripcion,
    required this.cajaNombre,
  });

  final int id;
  final DateTime? fecha;
  final bool esIngreso;
  final num monto;
  final String descripcion;
  final String cajaNombre;

  String get concepto {
    if (descripcion.isNotEmpty) return descripcion;
    return esIngreso ? 'Ingreso' : 'Egreso';
  }

  factory MovimientoCaja.fromJson(Map<String, dynamic> json) {
    return MovimientoCaja(
      id: aNumero(json['id']).toInt(),
      fecha: parsearFechaIso(json['fecha']),
      esIngreso: json['tipo'] == 'INGRESO',
      monto: aNumero(json['monto']),
      descripcion: (json['descripcion'] as String?)?.trim() ?? '',
      cajaNombre: (json['cajaNombre'] as String?)?.trim() ?? '',
    );
  }

  static List<MovimientoCaja> listaDesdePagina(dynamic json) {
    if (json is! Map) return const [];
    final contenido = json['content'];
    if (contenido is! List) return const [];
    return contenido
        .whereType<Map<String, dynamic>>()
        .map(MovimientoCaja.fromJson)
        .toList();
  }
}
