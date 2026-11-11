import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/app/theme.dart';
import 'package:pymes_erp_mobile/core/productos/producto_inventario.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/ajustes_venta.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/categoria_pos.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/cliente_pos.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/estado_caja.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/forma_pago.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/venta_creada.dart';
import 'package:pymes_erp_mobile/features/pos/data/pos_repository.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/carrito_controller.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/carrito_page.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/ultimo_paso_sheet.dart';
import 'package:provider/provider.dart';

ProductoInventario _producto(
  int id,
  String nombre, {
  String unidad = 'UNIDAD',
  num cantidad = 10,
  num minimo = 2,
  num precio = 1000,
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
    stockMinimo: minimo,
    precioVenta: precio,
    stockBajo: false,
  );
}

class _RepoFalso implements PosRepository {
  VentaCreada? venta;
  bool boolCalled = false;
  bool anularCalled = false;

  @override
  Future<List<ProductoInventario>> productos(int empresaId) async => const [];

  @override
  Future<List<CategoriaPos>> categorias(int empresaId) async => const [];

  @override
  Future<List<FormaPago>> formasDePago(int empresaId) async => const [];

  @override
  Future<List<ClientePos>> clientes(int empresaId) async => const [];

  @override
  Future<AjustesVenta> ajustes(int empresaId) async => const AjustesVenta();

  @override
  Future<List<EstadoCaja>> estadoDeCajas(int empresaId) async => const [];

  @override
  Future<String> nombreEmpresa(int empresaId) async => 'SuperMarket V';

  @override
  Future<VentaCreada> crearVenta({
    required int empresaId,
    required int formaPagoId,
    required List<LineaVenta> lineas,
    int? clienteId,
    num descuento = 0,
  }) async {
    boolCalled = true;
    return venta ??
        VentaCreada(
          id: 31,
          numero: 'FAC-20261110-29091',
          estado: 'EMITIDA',
          subtotal: 1000,
          descuento: 0,
          total: 1000,
        );
  }

  @override
  Future<VentaCreada> anularVenta(int facturaId) async {
    anularCalled = true;
    return VentaCreada(
      id: facturaId,
      numero: 'FAC-20261110-29091',
      estado: 'ANULADA',
      subtotal: 1000,
      descuento: 0,
      total: 1000,
    );
  }
}

CarritoController _carrito({PosRepository? repositorio}) {
  final carrito = CarritoController(
    ajustes: const AjustesVenta(),
    repositorio: repositorio,
  )..cargarFormasDePago(const [
    FormaPago(id: 1, nombre: 'Efectivo', tipo: TipoFormaPago.efectivo),
  ]);
  return carrito;
}

Widget _envolver(CarritoController carrito, Widget hijo) {
  return ChangeNotifierProvider<CarritoController>.value(
    value: carrito,
    child: MaterialApp(theme: construirTema(), home: hijo),
  );
}

void main() {
  group('pantalla del carrito', () {
    testWidgets('con el carrito vacio muestra el estado vacio', (tester) async {
      final carrito = CarritoController(ajustes: const AjustesVenta());

      await tester.pumpWidget(_envolver(carrito, const CarritoPage()));

      expect(find.text('Tu carrito esta vacio'), findsOneWidget);
      expect(find.text('Subtotal'), findsNothing);
    });

    testWidgets('muestra las lineas con su total y el precio por unidad', (
      tester,
    ) async {
      final carrito = CarritoController(ajustes: const AjustesVenta());
      carrito.agregar(
        _producto(1, 'Lentejas', unidad: 'KILOGRAMO', cantidad: 15.5, precio: 6800),
      );

      await tester.pumpWidget(_envolver(carrito, const CarritoPage()));

      expect(find.text('Lentejas'), findsOneWidget);
      expect(find.text('Stock: 15,5 kg'), findsOneWidget);
      expect(find.text(r'$ 3.400'), findsNWidgets(3));
      expect(find.text(r'$ 6.800 / kg'), findsOneWidget);
      expect(find.text('1 productos'), findsOneWidget);
    });

    testWidgets('el boton Ultimo paso lleva el total', (tester) async {
      final carrito = CarritoController(ajustes: const AjustesVenta());
      carrito.agregar(_producto(1, 'Arroz', precio: 4200));

      await tester.pumpWidget(_envolver(carrito, const CarritoPage()));

      expect(find.text('Ultimo paso'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text(r'$ 4.200'), findsNWidgets(3));
    });

    testWidgets('el boton de sumar sube la cantidad', (tester) async {
      final carrito = CarritoController(ajustes: const AjustesVenta());
      carrito.agregar(_producto(1, 'Arroz'));

      await tester.pumpWidget(_envolver(carrito, const CarritoPage()));

      expect(find.text('1 '), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Sumar'));
      await tester.pump();

      expect(carrito.lineas.first.cantidad, 2);
      expect(find.text('2 '), findsOneWidget);
    });

    testWidgets('el boton de restar esta deshabilitado en la cantidad minima', (
      tester,
    ) async {
      final carrito = CarritoController(ajustes: const AjustesVenta());
      carrito.agregar(_producto(1, 'Arroz'));

      await tester.pumpWidget(_envolver(carrito, const CarritoPage()));

      final boton = tester.widget<Semantics>(
        find.bySemanticsLabel('Restar').first,
      );

      expect(boton.properties.enabled, isFalse);
    });

    testWidgets('deslizar una tarjeta quita el producto', (tester) async {
      final carrito = CarritoController(ajustes: const AjustesVenta());
      carrito.agregar(_producto(1, 'Arroz'));

      await tester.pumpWidget(_envolver(carrito, const CarritoPage()));

      expect(find.text('Arroz'), findsOneWidget);

      await tester.drag(find.text('Arroz'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Arroz'), findsNothing);
      expect(carrito.lineas, isEmpty);
    });
  });

  group('hoja de ultimo paso', () {
    testWidgets('muestra el subtotal, el descuento y el total', (tester) async {
      final carrito = CarritoController(ajustes: const AjustesVenta());
      carrito.agregar(_producto(1, 'Arroz', precio: 4200));

      await tester.pumpWidget(
        _envolver(
          carrito,
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => mostrarUltimoPaso(context, carrito),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Ultimo paso'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Descuento'), findsOneWidget);
      expect(find.text('Cliente'), findsOneWidget);
      expect(find.text('Metodo de pago'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Finalizar venta'), findsOneWidget);
    });

    testWidgets('con efectivo muestra recibido y vuelto', (tester) async {
      final carrito = _carrito()
        ..cargarClientes(const [ClientePos(id: 8, nombre: 'Don Carlos')])
        ..agregar(_producto(1, 'Arroz', precio: 4200));

      await tester.pumpWidget(
        _envolver(
          carrito,
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => mostrarUltimoPaso(context, carrito),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Recibido'), findsOneWidget);
      expect(find.text('Vuelto'), findsOneWidget);
      expect(find.text('Efectivo'), findsOneWidget);
    });
  });

  group('registrar y anular la venta', () {
    test('registrar la venta la deja guardada', () async {
      final repo = _RepoFalso();
      final carrito = _carrito(repositorio: repo);
      carrito.agregar(_producto(1, 'Arroz', precio: 4200));

      final venta = await carrito.registrarVenta(7);

      expect(repo.boolCalled, isTrue);
      expect(venta, isNotNull);
      expect(venta!.numero, 'FAC-20261110-29091');
      expect(carrito.ventaRegistrada, isNotNull);
    });

    test('anular la venta cambia su estado', () async {
      final repo = _RepoFalso();
      final carrito = _carrito(repositorio: repo);
      carrito.agregar(_producto(1, 'Arroz', precio: 4200));
      await carrito.registrarVenta(7);

      final ok = await carrito.anularVenta();

      expect(repo.anularCalled, isTrue);
      expect(ok, isTrue);
      expect(carrito.ventaRegistrada!.estado, 'ANULADA');
    });

    test('nueva venta limpia el carrito y la venta guardada', () async {
      final repo = _RepoFalso();
      final carrito = _carrito(repositorio: repo);
      carrito.agregar(_producto(1, 'Arroz', precio: 4200));
      await carrito.registrarVenta(7);

      carrito.nuevaVenta();

      expect(carrito.lineas, isEmpty);
      expect(carrito.ventaRegistrada, isNull);
    });

    test('sin repositorio no se registra nada', () async {
      final carrito = CarritoController(ajustes: const AjustesVenta());
      carrito.agregar(_producto(1, 'Arroz', precio: 4200));

      final venta = await carrito.registrarVenta(7);

      expect(venta, isNull);
      expect(carrito.ventaRegistrada, isNull);
    });
  });
}
