import '../../../../core/format/numero.dart';

class EstadoCaja {
  const EstadoCaja({
    required this.cajaId,
    required this.cajaNombre,
    required this.abierta,
    this.requiereCierre = false,
  });

  final int cajaId;
  final String cajaNombre;
  final bool abierta;
  final bool requiereCierre;

  factory EstadoCaja.fromJson(Map<String, dynamic> json) {
    return EstadoCaja(
      cajaId: aNumero(json['cajaId']).toInt(),
      cajaNombre: (json['cajaNombre'] as String?)?.trim() ?? '',
      abierta: json['abierta'] == true,
      requiereCierre: json['requiereCierre'] == true,
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
