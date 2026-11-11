import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/features/pos/data/icono_categoria.dart';

void main() {
  test('una clave del catálogo de la web da su ícono', () {
    expect(iconoCategoria('Abarrotes y granos', clave: 'shopping-basket'),
        isNotEmpty);
    expect(iconoCategoria('Lácteos y huevos', clave: 'milk'), isNotEmpty);
    expect(iconoCategoria('Frutas y verduras', clave: 'apple'), isNotEmpty);
    expect(iconoCategoria('Aseo del hogar', clave: 'spray-can'), isNotEmpty);
    expect(iconoCategoria('Carnes y embutidos', clave: 'beef'), isNotEmpty);
  });

  test('una clave desconocida cae en la regla por palabra clave', () {
    expect(iconoCategoria('Lácteos', clave: 'no-existe'),
        iconoCategoria('Lácteos'));
  });

  test('sin clave se aplica la regla por palabra clave', () {
    expect(iconoCategoria('Lácteos y huevos'), iconoCategoria('Leche'));
    expect(iconoCategoria('Frutas y verduras'), iconoCategoria('Fruta'));
    expect(iconoCategoria('Aseo del hogar'), iconoCategoria('Limpieza'));
    expect(iconoCategoria('Carnes y embutidos'), iconoCategoria('Pollo'));
  });

  test('la regla ignora mayúsculas y tildes', () {
    expect(iconoCategoria('LÁCTEOS Y HUEVOS'), iconoCategoria('Leche'));
    expect(iconoCategoria('Bebidas'), iconoCategoria('Gaseosa'));
  });

  test('una categoría sin regla usa el ícono genérico', () {
    expect(iconoCategoria('Zapatería'), iconoCategoria('Sin coincidencia'));
  });
}
