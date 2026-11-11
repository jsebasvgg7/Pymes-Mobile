import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/app/theme.dart';
import 'package:pymes_erp_mobile/features/inventario/data/inventario_repository.dart';
import 'package:pymes_erp_mobile/core/productos/producto_inventario.dart';
import 'package:pymes_erp_mobile/features/inventario/presentation/inventario_controller.dart';
import 'package:pymes_erp_mobile/features/inventario/presentation/widgets/barra_filtros.dart';
import 'package:pymes_erp_mobile/features/inventario/presentation/widgets/hoja_filtros.dart';
import 'package:pymes_erp_mobile/features/inventario/presentation/widgets/hoja_orden.dart';
import 'package:pymes_erp_mobile/features/inventario/presentation/widgets/insignia_stock.dart';
import 'package:pymes_erp_mobile/features/inventario/presentation/widgets/opcion_chip.dart';
import 'package:pymes_erp_mobile/features/inventario/presentation/widgets/tarjeta_producto.dart';

class _RepoFalso implements InventarioRepository {
  _RepoFalso(this.items);

  final List<ProductoInventario> items;

  @override
  Future<List<ProductoInventario>> listar(int empresaId) async => items;
}

ProductoInventario _item(
  int id,
  String nombre, {
  String categoria = 'Bebidas',
  String? sku,
  num cantidad = 10,
  num minimo = 5,
  String unidad = 'UNIDAD',
}) {
  return ProductoInventario(
    productoId: id,
    nombre: nombre,
    sku: sku ?? 'SKU-$id',
    categoria: categoria,
    unidadMedida: unidad,
    cantidadActual: cantidad,
    costoPromedio: 1000,
    stockMinimo: minimo,
    precioVenta: 4500,
    stockBajo: false,
  );
}

Widget _envolver(Widget hijo) {
  return MaterialApp(theme: construirTema(), home: Scaffold(body: hijo));
}

Future<InventarioController> _controlador() async {
  final controlador = InventarioController(
    repositorio: _RepoFalso([
      _item(1, 'Gaseosa', cantidad: 20),
      _item(2, 'Arroz', categoria: 'Abarrotes', cantidad: 3),
      _item(3, 'Ñame', categoria: 'Abarrotes', cantidad: 0),
    ]),
    empresaId: 1,
  );
  await controlador.cargar();
  return controlador;
}

void main() {
  group('InsigniaStock', () {
    testWidgets('muestra la etiqueta de cada estado', (tester) async {
      for (final estado in EstadoStock.values) {
        await tester.pumpWidget(_envolver(InsigniaStock(estado: estado)));
        expect(find.text(etiquetaEstadoStock(estado)), findsOneWidget);
      }
    });

    test('cada estado tiene su color', () {
      expect(colorEstadoStock(EstadoStock.disponible), positivo);
      expect(colorEstadoStock(EstadoStock.bajo), atencion);
      expect(colorEstadoStock(EstadoStock.agotado), negativo);
    });
  });

  group('TarjetaProducto', () {
    testWidgets('muestra nombre, sku, categoría, cantidad y estado', (
      tester,
    ) async {
      await tester.pumpWidget(
        _envolver(TarjetaProducto(item: _item(1, 'Gaseosa', cantidad: 20))),
      );
      expect(find.text('Gaseosa'), findsOneWidget);
      expect(find.text('SKU-1 · Bebidas'), findsOneWidget);
      expect(find.textContaining('20'), findsWidgets);
      expect(find.text('Disponible'), findsOneWidget);
      expect(find.text('Mínimo 5'), findsOneWidget);
    });

    testWidgets('muestra decimales con coma en productos por peso', (
      tester,
    ) async {
      await tester.pumpWidget(
        _envolver(
          TarjetaProducto(
            item: _item(2, 'Arroz', cantidad: 2.5, unidad: 'KILOGRAMO'),
          ),
        ),
      );
      expect(find.textContaining('2,5'), findsWidgets);
      expect(find.textContaining('kg'), findsWidgets);
      expect(find.text('Stock bajo'), findsOneWidget);
    });

    testWidgets('sin sku solo muestra la categoría', (tester) async {
      await tester.pumpWidget(
        _envolver(TarjetaProducto(item: _item(3, 'Sal', sku: ''))),
      );
      expect(find.text('Bebidas'), findsOneWidget);
    });

    testWidgets('un producto en cero se marca sin stock', (tester) async {
      await tester.pumpWidget(
        _envolver(TarjetaProducto(item: _item(4, 'Ñame', cantidad: 0))),
      );
      expect(find.text('Sin stock'), findsOneWidget);
    });
  });

  group('OpcionChip', () {
    testWidgets('avisa al tocarlo', (tester) async {
      var toques = 0;
      await tester.pumpWidget(
        _envolver(
          OpcionChip(
            etiqueta: 'Todos',
            seleccionada: false,
            alTocar: () => toques++,
          ),
        ),
      );
      await tester.tap(find.text('Todos'));
      expect(toques, 1);
    });
  });

  group('hojas', () {
    testWidgets('la hoja de filtros aplica el estado y la categoría', (
      tester,
    ) async {
      final controlador = await _controlador();
      await tester.pumpWidget(
        _envolver(
          Builder(
            builder: (contexto) => TextButton(
              onPressed: () => mostrarHojaFiltros(contexto, controlador),
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Filtrar'), findsOneWidget);
      expect(find.text('Ver 3 productos'), findsOneWidget);

      await tester.tap(find.text('Stock bajo'));
      await tester.pumpAndSettle();
      expect(controlador.filtro, FiltroStock.stockBajo);
      expect(find.text('Ver 1 producto'), findsOneWidget);

      await tester.tap(find.text('Abarrotes'));
      await tester.pumpAndSettle();
      expect(controlador.categoria, 'Abarrotes');
    });

    testWidgets('Limpiar en la hoja quita estado y categoría', (tester) async {
      final controlador = await _controlador();
      controlador.filtrar(FiltroStock.agotados);
      controlador.elegirCategoria('Abarrotes');
      await tester.pumpWidget(
        _envolver(
          Builder(
            builder: (contexto) => TextButton(
              onPressed: () => mostrarHojaFiltros(contexto, controlador),
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Limpiar'));
      await tester.pumpAndSettle();
      expect(controlador.filtro, FiltroStock.todos);
      expect(controlador.categoria, isNull);
    });

    testWidgets('la hoja de orden cambia el orden y se cierra', (tester) async {
      final controlador = await _controlador();
      await tester.pumpWidget(
        _envolver(
          Builder(
            builder: (contexto) => TextButton(
              onPressed: () => mostrarHojaOrden(contexto, controlador),
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Ordenar por'), findsOneWidget);
      await tester.tap(find.text('Menor stock'));
      await tester.pumpAndSettle();

      expect(controlador.orden, OrdenInventario.menorStock);
      expect(find.text('Ordenar por'), findsNothing);
    });

    testWidgets('la barra de filtros deja un margen inferior de 6 px', (
      tester,
    ) async {
      final controlador = await _controlador();
      await tester.pumpWidget(
        _envolver(
          BarraFiltros(
            campo: TextEditingController(),
            alBuscar: (_) {},
            alFiltrar: () {},
            alOrdenar: () {},
            filtrosActivos: false,
          ),
        ),
      );

      final relleno = tester.widget<Padding>(
        find.descendant(
          of: find.byType(BarraFiltros),
          matching: find.byType(Padding),
        ).first,
      );

      expect(relleno.padding, const EdgeInsets.fromLTRB(20, 16, 20, 6));
      expect(controlador.filtro, FiltroStock.todos);
    });
  });
}
