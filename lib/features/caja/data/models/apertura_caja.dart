import '../../../../core/format/fecha.dart';
import '../../../../core/format/numero.dart';

enum EstadoAperturaCaja { abierta, cerrada }

enum TipoCierreCaja { manual, automatico }

enum ResultadoCierreCaja { cuadrada, faltante, sobrante }

class AperturaCaja {
  const AperturaCaja({
    required this.id,
    required this.cajaId,
    required this.cajaNombre,
    required this.estado,
    required this.usuarioAperturaId,
    required this.usuarioAperturaNombre,
    required this.fechaApertura,
    required this.efectivoInicial,
    required this.usuarioCierreId,
    required this.usuarioCierreNombre,
    required this.fechaCierre,
    required this.efectivoEsperado,
    required this.efectivoContado,
    required this.diferencia,
    required this.tipoCierre,
    required this.resultado,
    required this.requiereCierre,
  });

  final int id;
  final int cajaId;
  final String cajaNombre;
  final EstadoAperturaCaja estado;
  final int? usuarioAperturaId;
  final String? usuarioAperturaNombre;
  final DateTime? fechaApertura;
  final num efectivoInicial;
  final int? usuarioCierreId;
  final String? usuarioCierreNombre;
  final DateTime? fechaCierre;
  final num? efectivoEsperado;
  final num? efectivoContado;
  final num? diferencia;
  final TipoCierreCaja? tipoCierre;
  final ResultadoCierreCaja? resultado;
  final bool requiereCierre;

  bool get abierta => estado == EstadoAperturaCaja.abierta;

  factory AperturaCaja.fromJson(Map<String, dynamic> json) {
    return AperturaCaja(
      id: aNumero(json['id']).toInt(),
      cajaId: aNumero(json['cajaId']).toInt(),
      cajaNombre: (json['cajaNombre'] as String?)?.trim() ?? '',
      estado: _estadoDesde(json['estado']),
      usuarioAperturaId: _enteroOpcional(json['usuarioAperturaId']),
      usuarioAperturaNombre: _textoOpcional(json['usuarioAperturaNombre']),
      fechaApertura: parsearFechaIso(json['fechaApertura']),
      efectivoInicial: aNumero(json['efectivoInicial']),
      usuarioCierreId: _enteroOpcional(json['usuarioCierreId']),
      usuarioCierreNombre: _textoOpcional(json['usuarioCierreNombre']),
      fechaCierre: parsearFechaIso(json['fechaCierre']),
      efectivoEsperado: _numeroOpcional(json['efectivoEsperado']),
      efectivoContado: _numeroOpcional(json['efectivoContado']),
      diferencia: _numeroOpcional(json['diferencia']),
      tipoCierre: _tipoCierreDesde(json['tipoCierre']),
      resultado: _resultadoDesde(json['resultado']),
      requiereCierre: json['requiereCierre'] == true,
    );
  }
}

class PaginaCierresCaja {
  const PaginaCierresCaja({
    required this.items,
    this.pagina = 0,
    this.totalPaginas = 0,
    this.totalElementos = 0,
  });

  final List<AperturaCaja> items;
  final int pagina;
  final int totalPaginas;
  final int totalElementos;

  bool get hayMas => pagina + 1 < totalPaginas;

  factory PaginaCierresCaja.desdeJson(dynamic json) {
    if (json is! Map) return const PaginaCierresCaja(items: []);
    final contenido = json['content'];
    return PaginaCierresCaja(
      items: contenido is List
          ? contenido
                .whereType<Map<String, dynamic>>()
                .map(AperturaCaja.fromJson)
                .toList()
          : const [],
      pagina: aNumero(json['number']).toInt(),
      totalPaginas: aNumero(json['totalPages']).toInt(),
      totalElementos: aNumero(json['totalElements']).toInt(),
    );
  }
}

EstadoAperturaCaja _estadoDesde(dynamic valor) {
  final texto = valor is String ? valor.toUpperCase() : '';
  for (final estado in EstadoAperturaCaja.values) {
    if (estado.name.toUpperCase() == texto) return estado;
  }
  return EstadoAperturaCaja.cerrada;
}

TipoCierreCaja? _tipoCierreDesde(dynamic valor) {
  final texto = valor is String ? valor.toUpperCase() : '';
  for (final tipo in TipoCierreCaja.values) {
    if (tipo.name.toUpperCase() == texto) return tipo;
  }
  return null;
}

ResultadoCierreCaja? _resultadoDesde(dynamic valor) {
  final texto = valor is String ? valor.toUpperCase() : '';
  for (final resultado in ResultadoCierreCaja.values) {
    if (resultado.name.toUpperCase() == texto) return resultado;
  }
  return null;
}

int? _enteroOpcional(dynamic valor) {
  if (valor == null) return null;
  return aNumero(valor).toInt();
}

num? _numeroOpcional(dynamic valor) {
  if (valor == null) return null;
  return aNumero(valor);
}

String? _textoOpcional(dynamic valor) {
  if (valor is! String) return null;
  final texto = valor.trim();
  return texto.isEmpty ? null : texto;
}
