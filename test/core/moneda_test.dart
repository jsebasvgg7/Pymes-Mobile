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

  group('formato configurado', () {
    test('con dos decimales los muestra con coma', () {
      expect(
        formatearMonedaConfigurada(6800.5, simbolo: r'$', decimales: 2),
        r'$ 6.800,50',
      );
      expect(
        formatearMonedaConfigurada(1234, simbolo: r'$', decimales: 2),
        r'$ 1.234,00',
      );
    });

    test('usa el símbolo que le pasan', () {
      expect(
        formatearMonedaConfigurada(1500, simbolo: '€', decimales: 2),
        '€ 1.500,00',
      );
    });

    test('el signo va antes del símbolo', () {
      expect(
        formatearMonedaConfigurada(-1500, simbolo: r'$', decimales: 2),
        r'-$ 1.500,00',
      );
    });

    test('las monedas sin decimales quedan sin parte decimal', () {
      expect(decimalesDeMoneda('COP'), 0);
      expect(decimalesDeMoneda('CLP'), 0);
      expect(decimalesDeMoneda('JPY'), 0);
      expect(decimalesDeMoneda('PYG'), 0);
      expect(decimalesDeMoneda('USD'), 2);
      expect(decimalesDeMoneda('EUR'), 2);
    });
  });
}
