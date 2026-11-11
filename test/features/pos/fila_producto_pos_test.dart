import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/app/theme.dart';
import 'package:pymes_erp_mobile/core/productos/producto_inventario.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/widgets/fila_producto_pos.dart';

void main() {
  testWidgets('la fila de producto es una tarjeta blanca con borde fino', (
    tester,
  ) async {
    const producto = ProductoInventario(
      productoId: 1,
      nombre: 'Lentejas',
      sku: 'SKU-1',
      categoria: 'Abarrotes',
      categoriaId: 1,
      unidadMedida: 'UNIDAD',
      cantidadActual: 10,
      costoPromedio: 500,
      stockMinimo: 5,
      precioVenta: 6800,
      stockBajo: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: construirTema(),
        home: Scaffold(
          body: FilaProductoPos(
            producto: producto,
            seleccionado: false,
            alSeleccionar: () {},
            simbolo: r'$',
            decimales: 0,
          ),
        ),
      ),
    );

    final tarjeta = tester.widget<Container>(
      find.descendant(
        of: find.byType(FilaProductoPos),
        matching: find.byType(Container),
      ),
    );
    final decoracion = tarjeta.decoration! as BoxDecoration;

    expect(decoracion.color, papel);
    expect(decoracion.borderRadius, BorderRadius.circular(16));
    expect(decoracion.border, Border.all(color: linea, width: 1));
  });

  testWidgets('usa la moneda configurada con decimales', (tester) async {
    const producto = ProductoInventario(
      productoId: 1,
      nombre: 'Lentejas',
      sku: 'SKU-1',
      categoria: 'Abarrotes',
      categoriaId: 1,
      unidadMedida: 'UNIDAD',
      cantidadActual: 10,
      costoPromedio: 500,
      stockMinimo: 5,
      precioVenta: 6800,
      stockBajo: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: construirTema(),
        home: Scaffold(
          body: FilaProductoPos(
            producto: producto,
            seleccionado: false,
            alSeleccionar: () {},
            simbolo: r'US$',
            decimales: 2,
          ),
        ),
      ),
    );

    expect(find.text(r'US$ 6.800,00'), findsOneWidget);
  });
}
