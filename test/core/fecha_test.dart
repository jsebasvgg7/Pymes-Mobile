import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/format/fecha.dart';

void main() {
  final ahora = DateTime(2026, 11, 9, 15, 30);

  test('formatea hora y día con dos dígitos', () {
    expect(formatearHora(DateTime(2026, 11, 9, 9, 5)), '09:05');
    expect(formatearDiaMes(DateTime(2026, 11, 3)), '03 Nov');
  });

  test('mes y día de la semana abreviados', () {
    expect(mesCorto(1), 'Ene');
    expect(mesCorto(12), 'Dic');
    expect(diaSemanaCorto(DateTime.monday), 'Lun');
    expect(diaSemanaCorto(DateTime.wednesday), 'Mié');
    expect(diaSemanaCorto(DateTime.sunday), 'Dom');
  });

  test('etiqueta de movimiento: hoy, ayer y fechas anteriores', () {
    expect(etiquetaMovimiento(DateTime(2026, 11, 9, 14, 5), ahora), 'Hoy 14:05');
    expect(etiquetaMovimiento(DateTime(2026, 11, 8, 9, 10), ahora), 'Ayer 09:10');
    expect(etiquetaMovimiento(DateTime(2026, 11, 1, 9, 10), ahora), '01 Nov');
  });

  test('ayer se calcula por día aunque cruce el mes', () {
    final primero = DateTime(2026, 12, 1, 8);
    expect(
      etiquetaMovimiento(DateTime(2026, 11, 30, 23, 59), primero),
      'Ayer 23:59',
    );
  });

  test('parsea fechas ISO, con más de seis decimales y descarta lo ilegible', () {
    expect(parsearFechaIso('2026-11-08T14:30:15'), DateTime(2026, 11, 8, 14, 30, 15));
    expect(
      parsearFechaIso('2026-11-08T14:30:15.123456789'),
      DateTime(2026, 11, 8, 14, 30, 15, 123, 456),
    );
    expect(parsearFechaIso('no es fecha'), isNull);
    expect(parsearFechaIso(null), isNull);
    expect(parsearFechaIso(''), isNull);
    expect(parsearFechaIso(20261108), isNull);
  });

  test('soloFecha descarta la hora', () {
    expect(soloFecha(DateTime(2026, 11, 9, 23, 59)), DateTime(2026, 11, 9));
  });
}
