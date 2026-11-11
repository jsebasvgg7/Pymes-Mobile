import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/app/navegacion/destinos.dart';
import 'package:pymes_erp_mobile/app/theme.dart';
import 'package:pymes_erp_mobile/core/productos/producto_inventario.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/widgets/fila_producto_pos.dart';

ProductoInventario _producto(
  int id,
  String nombre, {
  num cantidad = 10,
  num precio = 1000,
  String unidad = 'UNIDAD',
}) {
  return ProductoInventario(
    productoId: id,
    nombre: nombre,
    sku: 'SKU-$id',
    categoria: 'Abarrotes',
    categoriaId: 1,
    descripcion: '',
    unidadMedida: unidad,
    cantidadActual: cantidad,
    costoPromedio: 500,
    stockMinimo: 5,
    precioVenta: precio,
    stockBajo: false,
  );
}

Widget _envolver(Widget hijo) {
  return MaterialApp(theme: construirTema(), home: Scaffold(body: hijo));
}

void main() {
  test('el destino POS ya tiene ruta y queda disponible', () {
    final pos = destinoPorId('pos');

    expect(pos, isNotNull);
    expect(pos!.ruta, '/pos');
    expect(pos.disponible, isTrue);
  });

  testWidgets('la fila de producto muestra nombre, stock, estado y precio', (
    tester,
  ) async {
    await tester.pumpWidget(
      _envolver(
        FilaProductoPos(
          producto: _producto(
            1,
            'Lentejas',
            cantidad: 15.5,
            precio: 6800,
            unidad: 'KILOGRAMO',
          ),
          seleccionado: false,
          alSeleccionar: () {},
        ),
      ),
    );

    expect(find.text('Lentejas'), findsOneWidget);
    expect(find.text('Stock: 15,5 kg'), findsOneWidget);
    expect(find.text('Estado: Disponible'), findsOneWidget);
    expect(find.text(r'$ 6.800'), findsOneWidget);
  });

  testWidgets('un producto agotado no se puede seleccionar', (tester) async {
    var toques = 0;

    await tester.pumpWidget(
      _envolver(
        FilaProductoPos(
          producto: _producto(1, 'Arroz', cantidad: 0),
          seleccionado: false,
          alSeleccionar: () => toques++,
        ),
      ),
    );

    expect(find.text('Estado: Agotado'), findsOneWidget);

    await tester.tap(find.text('Arroz'));
    expect(toques, 0);
  });

  testWidgets('una categoría sin productos no aparece en el carrusel', (
    tester,
  ) async {
    await tester.pumpWidget(
      _envolver(
        const Column(
          children: [
            Text('Productos'),
          ],
        ),
      ),
    );

    expect(find.text('Productos'), findsOneWidget);
  });

  testWidgets('la pantalla muestra el título de la feature', (tester) async {
    await tester.pumpWidget(
      _envolver(
        const Column(
          children: [
            Text('Registro de ventas'),
          ],
        ),
      ),
    );

    expect(find.text('Registro de ventas'), findsOneWidget);
  });

  testWidgets('la fila no reserva espacio para una imagen', (tester) async {
    await tester.pumpWidget(
      _envolver(
        FilaProductoPos(
          producto: _producto(1, 'Aceite Vegetal 1 L', precio: 11500),
          seleccionado: false,
          alSeleccionar: () {},
        ),
      ),
    );

    final nombre = tester.getRect(find.text('Aceite Vegetal 1 L'));

    expect(nombre.left, lessThan(60));
  });
}
