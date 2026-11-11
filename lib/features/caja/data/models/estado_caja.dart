import 'apertura_caja.dart';

class EstadoCaja {
  const EstadoCaja({
    required this.cajaId,
    required this.cajaNombre,
    required this.abierta,
    required this.requiereCierre,
    required this.apertura,
    required this.efectivoSugerido,
  });

  final int cajaId;
  final String cajaNombre;
  final bool abierta;
  final bool requiereCierre;
  final AperturaCaja? apertura;
  final num? efectivoSugerido;

  bool get cerrada => !abierta;

  bool get cierrePendiente => abierta && requiereCierre;

  factory EstadoCaja.fromJson(Map<String, dynamic> json) {
    final apertura = json['apertura'];
    return EstadoCaja(
      cajaId: _entero(json['cajaId']),
      cajaNombre: (json['cajaNombre'] as String?)?.trim() ?? '',
      abierta: json['abierta'] == true,
      requiereCierre: json['requiereCierre'] == true,
      apertura: apertura is Map<String, dynamic>
          ? AperturaCaja.fromJson(apertura)
          : null,
      efectivoSugerido: _numeroOpcional(json['efectivoSugerido']),
    );
  }

  static List<EstadoCaja> listaDesdeJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .whereType<Map<String, dynamic>>()
        .map(EstadoCaja.fromJson)
        .toList();
  }
}

int _entero(dynamic valor) {
  final numero = valor is num ? valor : num.tryParse('$valor');
  return (numero ?? 0).toInt();
}

num? _numeroOpcional(dynamic valor) {
  if (valor == null) return null;
  if (valor is num) return valor;
  return num.tryParse('$valor');
}
