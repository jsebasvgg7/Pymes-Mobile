import '../../../../core/format/numero.dart';

enum TipoFormaPagoCaja { efectivo, transferencia, tarjeta, credito, otro }

class FormaPagoCaja {
  const FormaPagoCaja({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.activo,
  });

  final int id;
  final String nombre;
  final TipoFormaPagoCaja tipo;
  final bool activo;

  bool get esEfectivo => tipo == TipoFormaPagoCaja.efectivo;

  bool get esCredito => tipo == TipoFormaPagoCaja.credito;

  factory FormaPagoCaja.fromJson(Map<String, dynamic> json) {
    return FormaPagoCaja(
      id: aNumero(json['id']).toInt(),
      nombre: (json['nombre'] as String?)?.trim() ?? '',
      tipo: _tipoDesde(json['tipo']),
      activo: json['active'] != false,
    );
  }

  static List<FormaPagoCaja> listaDesdePagina(dynamic json) {
    if (json is! Map) return const [];
    final contenido = json['content'];
    if (contenido is! List) return const [];
    return contenido
        .whereType<Map<String, dynamic>>()
        .map(FormaPagoCaja.fromJson)
        .toList();
  }
}

TipoFormaPagoCaja _tipoDesde(dynamic valor) {
  final texto = valor is String ? valor.toUpperCase() : '';
  for (final tipo in TipoFormaPagoCaja.values) {
    if (tipo.name.toUpperCase() == texto) return tipo;
  }
  return TipoFormaPagoCaja.otro;
}
