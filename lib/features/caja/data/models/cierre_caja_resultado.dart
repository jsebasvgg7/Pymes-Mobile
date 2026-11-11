import '../../../../core/format/numero.dart';
import 'apertura_caja.dart';

class CierreCajaResultado {
  const CierreCajaResultado({
    required this.apertura,
    required this.ingresosOtrosMedios,
    required this.egresosOtrosMedios,
  });

  final AperturaCaja apertura;
  final num ingresosOtrosMedios;
  final num egresosOtrosMedios;

  factory CierreCajaResultado.fromJson(Map<String, dynamic> json) {
    final apertura = json['apertura'];
    return CierreCajaResultado(
      apertura: apertura is Map<String, dynamic>
          ? AperturaCaja.fromJson(apertura)
          : AperturaCaja.fromJson(const {}),
      ingresosOtrosMedios: aNumero(json['ingresosOtrosMedios']),
      egresosOtrosMedios: aNumero(json['egresosOtrosMedios']),
    );
  }
}
