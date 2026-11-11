import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/app/theme.dart';
import 'package:pymes_erp_mobile/core/productos/producto_inventario.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/widgets/fila_producto_pos.dart';

void main() {
  testWidgets('la fila de producto mide al menos 64 dp', (tester) async {
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
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(FilaProductoPos)).height,
      greaterThanOrEqualTo(64),
    );
  });
}
