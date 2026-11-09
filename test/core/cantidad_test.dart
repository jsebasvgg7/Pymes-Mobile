import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/format/cantidad.dart';

void main() {
  group('formatearCantidad sin decimales', () {
    test('muestra enteros con separador de miles', () {
      expect(formatearCantidad(12, decimales: false), '12');
      expect(formatearCantidad(1234, decimales: false), '1.234');
      expect(formatearCantidad(1234567, decimales: false), '1.234.567');
    });

    test('redondea y conserva el signo', () {
      expect(formatearCantidad(2.4, decimales: false), '2');
      expect(formatearCantidad(-2, decimales: false), '-2');
    });

    test('un valor que redondea a cero no lleva signo', () {
      expect(formatearCantidad(-0.3, decimales: false), '0');
    });
  });

  group('formatearCantidad con decimales', () {
    test('usa coma decimal y quita ceros sobrantes', () {
      expect(formatearCantidad(2.5, decimales: true), '2,5');
      expect(formatearCantidad(7.25, decimales: true), '7,25');
      expect(formatearCantidad(3, decimales: true), '3');
      expect(formatearCantidad(3.0, decimales: true), '3');
    });

    test('admite hasta tres decimales', () {
      expect(formatearCantidad(0.333, decimales: true), '0,333');
      expect(formatearCantidad(1.0004, decimales: true), '1');
    });

    test('agrupa los miles y conserva el signo', () {
      expect(formatearCantidad(1234.5, decimales: true), '1.234,5');
      expect(formatearCantidad(-1.5, decimales: true), '-1,5');
    });

    test('un valor que redondea a cero no lleva signo', () {
      expect(formatearCantidad(-0.0004, decimales: true), '0');
    });
  });

  group('abreviarUnidad', () {
    test('abrevia peso y volumen', () {
      expect(abreviarUnidad('KILOGRAMO', 2), 'kg');
      expect(abreviarUnidad('GRAMO', 2), 'g');
      expect(abreviarUnidad('LITRO', 2), 'L');
      expect(abreviarUnidad('MILILITRO', 2), 'mL');
    });

    test('unidad usa und', () {
      expect(abreviarUnidad('UNIDAD', 1), 'und');
      expect(abreviarUnidad('UNIDAD', 8), 'und');
    });

    test('caja y paquete cambian entre singular y plural', () {
      expect(abreviarUnidad('CAJA', 1), 'caja');
      expect(abreviarUnidad('CAJA', 3), 'cajas');
      expect(abreviarUnidad('PAQUETE', 1), 'paquete');
      expect(abreviarUnidad('PAQUETE', 0), 'paquetes');
    });

    test('una unidad desconocida cae en und', () {
      expect(abreviarUnidad('OTRA', 1), 'und');
    });
  });
}
