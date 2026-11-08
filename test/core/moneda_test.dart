import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/format/moneda.dart';

void main() {
  test('formatea con separador de miles y sin decimales', () {
    expect(formatearMoneda(1250000), r'$ 1.250.000');
    expect(formatearMoneda(1000), r'$ 1.000');
    expect(formatearMoneda(999), r'$ 999');
    expect(formatearMoneda(0), r'$ 0');
  });

  test('redondea los decimales', () {
    expect(formatearMoneda(1234.56), r'$ 1.235');
    expect(formatearMoneda(1234.4), r'$ 1.234');
  });

  test('muestra el signo en los negativos', () {
    expect(formatearMoneda(-1500), r'-$ 1.500');
    expect(formatearMoneda(-0.4), r'$ 0');
  });

  test('acepta enteros y decimales grandes', () {
    expect(formatearMoneda(1234567890), r'$ 1.234.567.890');
    expect(formatearMoneda(8000.0), r'$ 8.000');
  });
}
