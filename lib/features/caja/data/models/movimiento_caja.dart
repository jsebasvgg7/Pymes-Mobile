import '../../../../core/format/fecha.dart';
import '../../../../core/format/numero.dart';

enum TipoMovimientoCaja { ingreso, egreso }

enum TipoReferenciaMovimientoCaja { ajuste, gasto, venta, compra, otro }

class MovimientoCaja {
  const MovimientoCaja({
    required this.id,
    required this.cajaId,
    required this.cajaNombre,
    required this.formaPagoId,
    required this.formaPagoNombre,
    required this.fecha,
    required this.tipo,
    required this.monto,
    required this.descripcion,
    required this.tipoReferencia,
    required this.referenciaId,
  });

  final int id;
  final int cajaId;
  final String cajaNombre;
  final int? formaPagoId;
  final String formaPagoNombre;
  final DateTime? fecha;
  final TipoMovimientoCaja tipo;
  final num monto;
  final String descripcion;
  final TipoReferenciaMovimientoCaja tipoReferencia;
  final int? referenciaId;

  bool get esIngreso => tipo == TipoMovimientoCaja.ingreso;

  bool get esGasto => tipoReferencia == TipoReferenciaMovimientoCaja.gasto;

  String get concepto {
    if (descripcion.isNotEmpty) return descripcion;
    return esIngreso ? 'Ingreso' : 'Egreso';
  }

  String get titulo {
    final base = concepto;
    final indice = base.indexOf('#');
    if (indice <= 0) return base;
    final antes = base.substring(0, indice).trim();
    return antes.isEmpty ? base : antes;
  }

  String? get codigo {
    final base = concepto;
    final indice = base.indexOf('#');
    if (indice <= 0) return null;
    final resto = base.substring(indice).trim();
    return resto.length > 1 ? resto : null;
  }

  factory MovimientoCaja.fromJson(Map<String, dynamic> json) {
    return MovimientoCaja(
      id: aNumero(json['id']).toInt(),
      cajaId: aNumero(json['cajaId']).toInt(),
      cajaNombre: (json['cajaNombre'] as String?)?.trim() ?? '',
      formaPagoId: _enteroOpcional(json['formaPagoId']),
      formaPagoNombre: (json['formaPagoNombre'] as String?)?.trim() ?? '',
      fecha: parsearFechaIso(json['fecha']),
      tipo: _tipoDesde(json['tipo']),
      monto: aNumero(json['monto']),
      descripcion: (json['descripcion'] as String?)?.trim() ?? '',
      tipoReferencia: _referenciaDesde(json['tipoReferencia']),
      referenciaId: _enteroOpcional(json['referenciaId']),
    );
  }
}

class PaginaMovimientosCaja {
  const PaginaMovimientosCaja({
    required this.items,
    this.pagina = 0,
    this.totalPaginas = 0,
    this.totalElementos = 0,
  });

  final List<MovimientoCaja> items;
  final int pagina;
  final int totalPaginas;
  final int totalElementos;

  bool get hayMas => pagina + 1 < totalPaginas;

  factory PaginaMovimientosCaja.desdeJson(dynamic json) {
    if (json is! Map) return const PaginaMovimientosCaja(items: []);
    final contenido = json['content'];
    return PaginaMovimientosCaja(
      items: contenido is List
          ? contenido
                .whereType<Map<String, dynamic>>()
                .map(MovimientoCaja.fromJson)
                .toList()
          : const [],
      pagina: aNumero(json['number']).toInt(),
      totalPaginas: aNumero(json['totalPages']).toInt(),
      totalElementos: aNumero(json['totalElements']).toInt(),
    );
  }
}

TipoMovimientoCaja _tipoDesde(dynamic valor) {
  final texto = valor is String ? valor.toUpperCase() : '';
  return texto == 'INGRESO'
      ? TipoMovimientoCaja.ingreso
      : TipoMovimientoCaja.egreso;
}

TipoReferenciaMovimientoCaja _referenciaDesde(dynamic valor) {
  final texto = valor is String ? valor.toUpperCase() : '';
  for (final referencia in TipoReferenciaMovimientoCaja.values) {
    if (referencia.name.toUpperCase() == texto) return referencia;
  }
  return TipoReferenciaMovimientoCaja.ajuste;
}

int? _enteroOpcional(dynamic valor) {
  if (valor == null) return null;
  return aNumero(valor).toInt();
}
