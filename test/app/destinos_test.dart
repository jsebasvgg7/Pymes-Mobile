import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/app/navegacion/destino.dart';
import 'package:pymes_erp_mobile/app/navegacion/destinos.dart';

List<String> _ids(GrupoDestino grupo) {
  return destinosDe(grupo).map((d) => d.id).toList();
}

void main() {
  test('los ids son únicos', () {
    final ids = destinos.map((d) => d.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('la barra inferior tiene los cuatro destinos del mockup', () {
    expect(_ids(GrupoDestino.barra), ['inicio', 'pos', 'inventario', 'caja']);
  });

  test('el menú más agrupa Operación y Catálogo', () {
    expect(_ids(GrupoDestino.operacion), ['pronosticos', 'compras']);
    expect(_ids(GrupoDestino.catalogo), [
      'productos',
      'categorias',
      'clientes',
      'proveedores',
    ]);
  });

  test('Administración tiene sus cuatro opciones', () {
    expect(_ids(GrupoDestino.administracion), [
      'reportes',
      'usuarios',
      'roles',
      'configuracion',
    ]);
  });

  test('solo Inicio está disponible en esta casilla', () {
    final disponibles = destinos.where((d) => d.disponible).map((d) => d.id);
    expect(disponibles.toList(), ['inicio']);
  });

  test('destinoPorId encuentra destinos y desconoce otros ids', () {
    expect(destinoPorId('inventario')?.nombre, 'Inventario');
    expect(destinoPorId('pos')?.id, 'pos');
    expect(destinoPorId('no-existe'), isNull);
  });

  test('destinoPorRuta encuentra Inicio y desconoce otras rutas', () {
    expect(destinoPorRuta('/')?.id, 'inicio');
    expect(destinoPorRuta('/otra'), isNull);
  });
}
