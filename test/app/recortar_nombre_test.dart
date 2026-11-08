import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/app/navegacion/recortar_nombre.dart';

void main() {
  test('deja igual un nombre corto', () {
    expect(recortarNombre('Don Carlos'), 'Don Carlos');
  });

  test('deja igual un nombre de exactamente 16 caracteres', () {
    expect(recortarNombre('1234567890123456'), '1234567890123456');
  });

  test('corta un nombre largo y agrega puntos suspensivos', () {
    expect(recortarNombre('Don Carlos Alberto Pérez'), 'Don Carlos Alber…');
  });

  test('quita espacios sobrantes antes de cortar', () {
    expect(recortarNombre('  Ana  '), 'Ana');
    expect(recortarNombre('Maria de los Angeles Ruiz'), 'Maria de los Ang…');
  });

  test('respeta el máximo recibido', () {
    expect(recortarNombre('Sebastian', maximo: 4), 'Seba…');
  });
}
