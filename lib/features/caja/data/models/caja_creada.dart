import '../../../../core/format/numero.dart';

class CajaCreada {
  const CajaCreada({
    required this.id,
    required this.empresaId,
    required this.nombre,
    required this.saldoInicial,
    required this.saldoActual,
  });

  final int id;
  final int empresaId;
  final String nombre;
  final num saldoInicial;
  final num saldoActual;

  factory CajaCreada.fromJson(Map<String, dynamic> json) {
    return CajaCreada(
      id: aNumero(json['id']).toInt(),
      empresaId: aNumero(json['empresaId']).toInt(),
      nombre: (json['nombre'] as String?)?.trim() ?? '',
      saldoInicial: aNumero(json['saldoInicial']),
      saldoActual: aNumero(json['saldoActual']),
    );
  }
}
