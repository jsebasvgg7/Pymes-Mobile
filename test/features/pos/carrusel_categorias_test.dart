import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pymes_erp_mobile/app/theme.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/categoria_pos.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/widgets/carrusel_categorias.dart';

const List<CategoriaPos> _categorias = [
  CategoriaPos(id: 1, nombre: 'Abarrotes y granos', icono: 'shopping-basket'),
  CategoriaPos(id: 2, nombre: 'Lácteos y huevos', icono: 'milk'),
  CategoriaPos(id: 3, nombre: 'Frutas y verduras', icono: 'apple'),
];

void main() {
  testWidgets('los círculos están tan juntos como en el mockup', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: construirTema(),
        home: Scaffold(
          body: CarruselCategorias(
            categorias: _categorias,
            categoriaElegida: null,
            alElegir: (_) {},
          ),
        ),
      ),
    );

    final circulos = find.byType(HugeIcon);
    final centros = <double>[];
    for (final icono in circulos.evaluate()) {
      centros.add(tester.getRect(find.byWidget(icono.widget)).center.dx);
    }
    centros.sort();

    expect(centros.length, 4);
    for (var i = 1; i < centros.length; i++) {
      expect(
        centros[i] - centros[i - 1],
        closeTo(73, 1.5),
        reason: 'distancia entre las categorías ${i - 1} y $i',
      );
    }
  });

  testWidgets('el carrusel deja 20 dp de margen a cada lado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: construirTema(),
        home: Scaffold(
          body: CarruselCategorias(
            categorias: _categorias,
            categoriaElegida: null,
            alElegir: (_) {},
          ),
        ),
      ),
    );

    final lista = tester.getRect(find.byType(ListView));
    final ancho = tester.view.physicalSize.width / tester.view.devicePixelRatio;

    expect(lista.left, 20);
    expect(lista.right, ancho - 20);
  });

  testWidgets('todos los círculos son grises, incluso el elegido', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: construirTema(),
        home: Scaffold(
          body: CarruselCategorias(
            categorias: _categorias,
            categoriaElegida: null,
            alElegir: (_) {},
          ),
        ),
      ),
    );

    final fondos = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.color)
        .toList();

    expect(fondos, isNotEmpty);
    for (final color in fondos) {
      expect(color, tintaPrincipal.withValues(alpha: 0.07));
    }
  });
}
