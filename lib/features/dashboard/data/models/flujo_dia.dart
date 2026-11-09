import '../../../../core/format/fecha.dart';
import '../../../../core/format/numero.dart';

enum PeriodoFlujo { diario, semanal }

class FlujoDia {
  const FlujoDia({
    required this.fecha,
    required this.ingreso,
    required this.egreso,
  });

  final DateTime fecha;
  final num ingreso;
  final num egreso;

  static List<FlujoDia> listaDesdeJson(dynamic json) {
    if (json is! List) return const [];
    final dias = <FlujoDia>[];
    for (final item in json) {
      if (item is! Map) continue;
      final fecha = parsearFechaIso(item['fecha']);
      if (fecha == null) continue;
      dias.add(
        FlujoDia(
          fecha: soloFecha(fecha),
          ingreso: aNumero(item['ingreso']),
          egreso: aNumero(item['egreso']),
        ),
      );
    }
    return dias;
  }
}

class PuntoFlujo {
  const PuntoFlujo({
    required this.etiqueta,
    required this.ingreso,
    required this.egreso,
  });

  final String etiqueta;
  final num ingreso;
  final num egreso;
}

List<PuntoFlujo> construirSerie(
  List<FlujoDia> dias,
  PeriodoFlujo periodo,
  DateTime hoy,
) {
  final fin = soloFecha(hoy);
  return periodo == PeriodoFlujo.diario
      ? _serieDiaria(dias, fin)
      : _serieSemanal(dias, fin);
}

List<PuntoFlujo> _serieDiaria(List<FlujoDia> dias, DateTime fin) {
  final serie = <PuntoFlujo>[];
  for (var atras = 6; atras >= 0; atras--) {
    final dia = DateTime(fin.year, fin.month, fin.day - atras);
    num ingreso = 0;
    num egreso = 0;
    for (final d in dias) {
      if (soloFecha(d.fecha) == dia) {
        ingreso += d.ingreso;
        egreso += d.egreso;
      }
    }
    serie.add(
      PuntoFlujo(
        etiqueta: diaSemanaCorto(dia.weekday),
        ingreso: ingreso,
        egreso: egreso,
      ),
    );
  }
  return serie;
}

List<PuntoFlujo> _serieSemanal(List<FlujoDia> dias, DateTime fin) {
  final lunesActual = DateTime(fin.year, fin.month, fin.day - (fin.weekday - 1));
  final serie = <PuntoFlujo>[];
  for (var atras = 3; atras >= 0; atras--) {
    final inicio = DateTime(
      lunesActual.year,
      lunesActual.month,
      lunesActual.day - 7 * atras,
    );
    final limite = DateTime(inicio.year, inicio.month, inicio.day + 7);
    num ingreso = 0;
    num egreso = 0;
    for (final d in dias) {
      final dia = soloFecha(d.fecha);
      if (!dia.isBefore(inicio) && dia.isBefore(limite)) {
        ingreso += d.ingreso;
        egreso += d.egreso;
      }
    }
    serie.add(
      PuntoFlujo(
        etiqueta: formatearDiaMes(inicio),
        ingreso: ingreso,
        egreso: egreso,
      ),
    );
  }
  return serie;
}

num totalIngresosSerie(List<PuntoFlujo> serie) {
  return serie.fold<num>(0, (a, p) => a + p.ingreso);
}

num totalEgresosSerie(List<PuntoFlujo> serie) {
  return serie.fold<num>(0, (a, p) => a + p.egreso);
}
