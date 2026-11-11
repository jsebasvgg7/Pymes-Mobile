import '../../../../core/format/numero.dart';

enum TipoFormaPago { efectivo, transferencia, tarjeta, credito, otro }

class FormaPago {
  const FormaPago({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.activo = true,
  });

  final int id;
  final String nombre;
  final TipoFormaPago tipo;
  final bool activo;

  bool get esCredito => tipo == TipoFormaPago.credito;

  bool get esEfectivo => tipo == TipoFormaPago.efectivo;

  factory FormaPago.fromJson(Map<String, dynamic> json) {
    return FormaPago(
      id: aNumero(json['id']).toInt(),
      nombre: (json['nombre'] as String?)?.trim() ?? '',
      tipo: _tipoDesde(json['tipo']),
      activo: json['active'] != false,
    );
  }

  static List<FormaPago> listaDesdePagina(dynamic json) {
    if (json is! Map) return const [];
    final contenido = json['content'];
    if (contenido is! List) return const [];
    return contenido
        .whereType<Map<String, dynamic>>()
        .map(FormaPago.fromJson)
        .toList();
  }
}

TipoFormaPago _tipoDesde(dynamic valor) {
  final texto = valor is String ? valor.toUpperCase() : '';
  for (final tipo in TipoFormaPago.values) {
    if (tipo.name.toUpperCase() == texto) return tipo;
  }
  return TipoFormaPago.otro;
}
