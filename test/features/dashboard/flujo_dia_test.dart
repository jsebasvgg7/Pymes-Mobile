import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/features/dashboard/data/models/flujo_dia.dart';

FlujoDia _dia(int mes, int dia, num ingreso, num egreso) {
  return FlujoDia(
    fecha: DateTime(2026, mes, dia),
    ingreso: ingreso,
    egreso: egreso,
  );
}

void main() {
  final hoy = DateTime(2026, 11, 9, 15, 30);

  group('listaDesdeJson', () {
    test('lee los días y tolera datos raros', () {
      final dias = FlujoDia.listaDesdeJson([
        {'fecha': '2026-11-08', 'ingreso': 1000, 'egreso': 200.5},
        {'fecha': '2026-11-09', 'ingreso': '500', 'egreso': null},
        {'fecha': 'mala', 'ingreso': 1, 'egreso': 1},
        'basura',
      ]);
      expect(dias.length, 2);
      expect(dias.first.fecha, DateTime(2026, 11, 8));
      expect(dias.first.egreso, 200.5);
      expect(dias.last.ingreso, 500);
      expect(dias.last.egreso, 0);
    });

    test('una respuesta que no es lista da vacío', () {
      expect(FlujoDia.listaDesdeJson({'a': 1}), isEmpty);
      expect(FlujoDia.listaDesdeJson(null), isEmpty);
    });
  });

  group('serie diaria', () {
    test('siete días terminando hoy, con ceros donde no hay datos', () {
      final serie = construirSerie(
        [_dia(11, 9, 1000, 200), _dia(11, 3, 50, 0)],
        PeriodoFlujo.diario,
        hoy,
      );
      expect(serie.length, 7);
      expect(serie.map((p) => p.etiqueta).toList(), [
        'Mar',
        'Mié',
        'Jue',
        'Vie',
        'Sáb',
        'Dom',
        'Lun',
      ]);
      expect(serie.first.ingreso, 50);
      expect(serie[3].ingreso, 0);
      expect(serie[3].egreso, 0);
      expect(serie.last.ingreso, 1000);
      expect(serie.last.egreso, 200);
    });

    test('ignora los días fuera de la ventana', () {
      final serie = construirSerie(
        [_dia(11, 2, 999, 999), _dia(11, 10, 777, 777)],
        PeriodoFlujo.diario,
        hoy,
      );
      expect(totalIngresosSerie(serie), 0);
      expect(totalEgresosSerie(serie), 0);
    });

    test('suma los registros repetidos del mismo día', () {
      final serie = construirSerie(
        [_dia(11, 9, 100, 10), _dia(11, 9, 50, 5)],
        PeriodoFlujo.diario,
        hoy,
      );
      expect(serie.last.ingreso, 150);
      expect(serie.last.egreso, 15);
    });

    test('cruza el cambio de mes con las etiquetas correctas', () {
      final serie = construirSerie(
        [_dia(10, 31, 70, 0)],
        PeriodoFlujo.diario,
        DateTime(2026, 11, 2),
      );
      expect(serie.length, 7);
      expect(serie[4].ingreso, 70);
      expect(serie[4].etiqueta, 'Sáb');
    });
  });

  group('serie semanal', () {
    test('cuatro semanas que empiezan en lunes, la última es la actual', () {
      final serie = construirSerie(
        [
          _dia(10, 18, 999, 999),
          _dia(10, 19, 10, 1),
          _dia(10, 25, 5, 1),
          _dia(10, 26, 7, 2),
          _dia(11, 1, 3, 0),
          _dia(11, 9, 100, 40),
        ],
        PeriodoFlujo.semanal,
        hoy,
      );
      expect(serie.map((p) => p.etiqueta).toList(), [
        '19 Oct',
        '26 Oct',
        '02 Nov',
        '09 Nov',
      ]);
      expect(serie[0].ingreso, 15);
      expect(serie[0].egreso, 2);
      expect(serie[1].ingreso, 10);
      expect(serie[1].egreso, 2);
      expect(serie[2].ingreso, 0);
      expect(serie[3].ingreso, 100);
      expect(serie[3].egreso, 40);
    });

    test('con hoy a mitad de semana, la semana actual empieza el lunes', () {
      final serie = construirSerie(
        [_dia(11, 9, 10, 0), _dia(11, 11, 20, 0)],
        PeriodoFlujo.semanal,
        DateTime(2026, 11, 11),
      );
      expect(serie.last.etiqueta, '09 Nov');
      expect(serie.last.ingreso, 30);
    });
  });

  test('los totales suman toda la serie', () {
    final serie = construirSerie(
      [_dia(11, 9, 100, 10), _dia(11, 8, 50, 5)],
      PeriodoFlujo.diario,
      hoy,
    );
    expect(totalIngresosSerie(serie), 150);
    expect(totalEgresosSerie(serie), 15);
  });
}
