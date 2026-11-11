import '../../../../core/format/numero.dart';

class ResumenCaja {
  const ResumenCaja({
    required this.cajaId,
    required this.cajaNombre,
    required this.saldoInicial,
    required this.saldoActual,
    required this.totalIngresos,
    required this.totalEgresos,
    required this.totalMovimientos,
  });

  final int cajaId;
  final String cajaNombre;
  final num saldoInicial;
  final num saldoActual;
  final num totalIngresos;
  final num totalEgresos;
  final int totalMovimientos;

  factory ResumenCaja.fromJson(Map<String, dynamic> json) {
    return ResumenCaja(
      cajaId: aNumero(json['cajaId']).toInt(),
      cajaNombre: (json['cajaNombre'] as String?)?.trim() ?? '',
      saldoInicial: aNumero(json['saldoInicial']),
      saldoActual: aNumero(json['saldoActual']),
      totalIngresos: aNumero(json['totalIngresos']),
      totalEgresos: aNumero(json['totalEgresos']),
      totalMovimientos: aNumero(json['totalMovimientos']).toInt(),
    );
  }

  static List<ResumenCaja> listaDesdeJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .whereType<Map<String, dynamic>>()
        .map(ResumenCaja.fromJson)
        .toList();
  }
}
