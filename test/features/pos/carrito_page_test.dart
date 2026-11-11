import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/app/theme.dart';
import 'package:pymes_erp_mobile/core/productos/producto_inventario.dart';
import 'package:pymes_erp_mobile/features/auth/data/auth_repository.dart';
import 'package:pymes_erp_mobile/features/auth/data/models/usuario.dart';
import 'package:pymes_erp_mobile/features/auth/presentation/auth_controller.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/ajustes_venta.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/categoria_pos.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/cliente_pos.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/estado_caja.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/forma_pago.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/venta_creada.dart';
import 'package:pymes_erp_mobile/features/pos/data/pos_repository.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/carrito_controller.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/carrito_page.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/factura_dialog.dart';
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

class _AuthFalso implements AuthRepository {
  static const Usuario _usuario = Usuario(
    id: 1,
    empresaId: 7,
    username: 'cajero',
    email: 'cajero@test.com',
  );

  @override
  Future<Usuario> login({
    required String email,
    required String password,
  }) async => _usuario;

  @override
  Future<Usuario> registrar({
    required String empresaNombre,
    required String username,
    required String email,
    required String password,
    required String codigoRegistro,
  }) async => _usuario;

  @override
  Future<Usuario?> restaurarSesion() async => _usuario;

  @override
  Future<void> cerrarSesion() async {}

  @override
  Future<CredencialesRecordadas?> leerRecordadas() async => null;

  @override
  Future<void> recordar(String correo, String clave) async {}

  @override
  Future<void> olvidarRecordadas() async {}
}

class _RepoFalso implements PosRepository {
  VentaCreada? venta;
  Completer<VentaCreada>? espera;
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
    if (espera != null) return espera!.future;
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

CarritoController _carrito({
  PosRepository? repositorio,
  AjustesVenta ajustes = const AjustesVenta(),
  String nombreEmpresa = '',
  bool cajaAbierta = true,
}) {
  final carrito =
      CarritoController(
        ajustes: ajustes,
        repositorio: repositorio,
        nombreEmpresa: nombreEmpresa,
        cajaAbierta: cajaAbierta,
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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final cargador = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Regular.otf'))
      ..addFont(rootBundle.load('assets/fonts/Inter-Medium.otf'))
      ..addFont(rootBundle.load('assets/fonts/Inter-SemiBold.otf'))
      ..addFont(rootBundle.load('assets/fonts/Inter-Bold.otf'));
    await cargador.load();
  });

  group('pantalla del carrito', () {
    testWidgets('con el carrito vacio muestra el estado vacio', (tester) async {
      final carrito = CarritoController(ajustes: const AjustesVenta());

      await tester.pumpWidget(_envolver(carrito, const CarritoPage()));

      expect(find.text('Tu carrito está vacío'), findsOneWidget);
      expect(find.text('Subtotal'), findsNothing);
    });

    testWidgets('muestra las lineas con su total y el precio por unidad', (
      tester,
    ) async {
      final carrito = CarritoController(ajustes: const AjustesVenta());
      carrito.agregar(
        _producto(
          1,
          'Lentejas',
          unidad: 'KILOGRAMO',
          cantidad: 15.5,
          precio: 6800,
        ),
      );

      await tester.pumpWidget(_envolver(carrito, const CarritoPage()));

      expect(find.text('Lentejas'), findsOneWidget);
      expect(find.textContaining('Stock: 15,5 kg'), findsOneWidget);
      expect(find.text(r'$ 3.400'), findsNWidgets(2));
      expect(find.textContaining(r'$ 6.800 / kg'), findsOneWidget);
      expect(find.text('1 Producto'), findsOneWidget);
    });

    testWidgets('el pie muestra el subtotal y el boton Último paso', (
      tester,
    ) async {
      final carrito = CarritoController(ajustes: const AjustesVenta());
      carrito.agregar(_producto(1, 'Arroz', precio: 4200));

      await tester.pumpWidget(_envolver(carrito, const CarritoPage()));

      expect(find.text('Último paso'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text(r'$ 4.200'), findsNWidgets(2));
    });

    testWidgets('el boton de sumar sube la cantidad', (tester) async {
      final carrito = CarritoController(ajustes: const AjustesVenta());
      carrito.agregar(_producto(1, 'Arroz'));

      await tester.pumpWidget(_envolver(carrito, const CarritoPage()));

      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Sumar'));
      await tester.pump();

      expect(carrito.lineas.first.cantidad, 2);
      expect(find.text('2'), findsOneWidget);
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

    testWidgets('la papelera quita el producto', (tester) async {
      final carrito = CarritoController(ajustes: const AjustesVenta());
      carrito.agregar(_producto(1, 'Arroz'));

      await tester.pumpWidget(_envolver(carrito, const CarritoPage()));

      expect(find.text('Arroz'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Quitar Arroz'));
      await tester.pumpAndSettle();

      expect(find.text('Arroz'), findsNothing);
      expect(carrito.lineas, isEmpty);
    });
  });

  testWidgets('no muestra anular la venta en el carrito', (tester) async {
    final repo = _RepoFalso();
    final carrito = _carrito(repositorio: repo)
      ..agregar(_producto(1, 'Arroz', precio: 4200));
    await carrito.registrarVenta(7);

    await tester.pumpWidget(_envolver(carrito, const CarritoPage()));
    await tester.pumpAndSettle();

    expect(find.text('Anular la venta'), findsNothing);
    expect(find.text('Último paso'), findsOneWidget);
  });

  testWidgets('muestra la moneda configurada en el carrito', (tester) async {
    final carrito = _carrito(
      ajustes: const AjustesVenta(moneda: 'USD', simboloMoneda: 'US\$'),
    )..agregar(_producto(1, 'Arroz', precio: 6800));

    await tester.pumpWidget(_envolver(carrito, const CarritoPage()));
    await tester.pumpAndSettle();

    expect(find.text('US\$ 6.800,00'), findsNWidgets(2));
  });

  testWidgets('permite escribir una cantidad decimal manualmente', (
    tester,
  ) async {
    final carrito = _carrito()
      ..agregar(
        _producto(
          1,
          'Lentejas',
          unidad: 'KILOGRAMO',
          cantidad: 10,
          precio: 1000,
        ),
      );

    await tester.pumpWidget(_envolver(carrito, const CarritoPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Editar cantidad de Lentejas'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1,3');
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    expect(carrito.lineas.single.cantidad, 1.3);
    expect(find.text('1,3'), findsOneWidget);
    expect(find.text(r'$ 1.300'), findsNWidgets(2));
  });

  testWidgets('no permite superar el stock al editar la cantidad', (
    tester,
  ) async {
    final carrito = _carrito()
      ..agregar(
        _producto(
          1,
          'Lentejas',
          unidad: 'KILOGRAMO',
          cantidad: 10,
          precio: 1000,
        ),
      );

    await tester.pumpWidget(_envolver(carrito, const CarritoPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Editar cantidad de Lentejas'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '99');
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    expect(find.text('El máximo disponible es 10 kg.'), findsOneWidget);
    expect(carrito.lineas.single.cantidad, 0.5);
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

      expect(find.text('Último paso'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Descuento'), findsOneWidget);
      expect(find.text('Cliente'), findsOneWidget);
      expect(find.text('Método de pago'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Finalizar venta'), findsOneWidget);
    });

    testWidgets('alinea los valores y controles a la derecha', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final carrito = _carrito()
        ..cargarClientes(const [ClientePos(id: 8, nombre: 'Don Carlos')])
        ..agregar(_producto(1, 'Arroz', precio: 4200))
        ..cambiarDescuento(200);

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

      final subtotal = tester.getRect(find.text(r'$ 4.200'));
      final total = tester.getRect(find.text(r'$ 4.000'));
      final cliente = tester.getRect(find.text('Sin cliente'));
      final metodo = tester.getRect(find.text('Efectivo'));

      expect(subtotal.right, closeTo(370, 1));
      expect(total.right, closeTo(370, 1));
      expect(cliente.right, greaterThan(300));
      expect(metodo.right, greaterThan(300));
      expect(tester.getRect(find.text('Cliente')).left, closeTo(20, 1));
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

    testWidgets('con la caja cerrada avisa y bloquea el finalizar', (
      tester,
    ) async {
      final carrito = _carrito(cajaAbierta: false)
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

      expect(
        find.text('La caja está cerrada. Ábrela para registrar ventas.'),
        findsOneWidget,
      );
      final boton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Finalizar venta'),
      );
      expect(boton.onPressed, isNull);
    });

    testWidgets('mientras envia deshabilita campos, selectores y cancelar', (
      tester,
    ) async {
      final auth = AuthController(repositorio: _AuthFalso());
      await auth.restaurar();
      final repo = _RepoFalso();
      final espera = Completer<VentaCreada>();
      repo.espera = espera;
      final carrito = _carrito(repositorio: repo)
        ..agregar(_producto(1, 'Arroz', precio: 4200));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthController>.value(value: auth),
            ChangeNotifierProvider<CarritoController>.value(value: carrito),
          ],
          child: MaterialApp(
            theme: construirTema(),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => mostrarUltimoPaso(context, carrito),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finalizar venta'));
      await tester.pump();

      expect(carrito.enviando, isTrue);
      final campos = tester.widgetList<TextField>(find.byType(TextField));
      expect(campos, isNotEmpty);
      for (final campo in campos) {
        expect(campo.enabled, isFalse);
      }
      final selector = tester.widget<PopupMenuButton<int>>(
        find.byType(PopupMenuButton<int>).first,
      );
      expect(selector.enabled, isFalse);
      final cancelar = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Cancelar'),
      );
      expect(cancelar.onPressed, isNull);

      espera.complete(
        const VentaCreada(
          id: 31,
          numero: 'FAC-20261110-29091',
          estado: 'EMITIDA',
          subtotal: 4200,
          descuento: 0,
          total: 4200,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Venta registrada'), findsOneWidget);
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

  testWidgets('la factura no desborda en una pantalla pequena', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final carrito = _carrito();
    final venta = VentaCreada(
      id: 1,
      numero: 'FAC-20261111-00001',
      estado: 'EMITIDA',
      subtotal: 60000,
      descuento: 0,
      total: 60000,
      fechaEmision: DateTime(2026, 11, 11, 18, 57),
      formaPagoNombre: 'Efectivo',
      detalles: [
        for (var i = 1; i <= 12; i++)
          DetalleVenta(
            productoId: i,
            descripcion: 'Producto $i',
            cantidad: 1,
            precioUnitario: 5000,
            totalLinea: 5000,
          ),
      ],
    );

    await tester.pumpWidget(
      _envolver(
        carrito,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => mostrarFactura(context, venta, carrito),
              child: const Text('abrir factura'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir factura'));
    await tester.pumpAndSettle();

    expect(find.text('Venta registrada'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final fecha = tester.getRect(find.text('11/11/2026 6:57 p. m.'));
    final precio = tester.getRect(find.text(r'$ 5.000').first);
    final nuevaVenta = tester.getRect(find.text('Nueva venta'));

    expect(fecha.right, closeTo(316, 1));
    expect(fecha.height, lessThan(24));
    expect(precio.right, closeTo(316, 1));
    expect(nuevaVenta.height, lessThan(24));

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -800),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nueva venta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la factura comparte y solo se cierra con Nueva venta', (
    tester,
  ) async {
    final carrito =
        _carrito(
            nombreEmpresa: 'SuperMarket V',
            ajustes: const AjustesVenta(
              mensajePieRecibo: 'Gracias por su compra.',
            ),
          )
          ..agregar(_producto(1, 'Arroz', precio: 4200))
          ..cambiarDescuento(200)
          ..cambiarRecibido(5000);
    final venta = VentaCreada(
      id: 1,
      numero: 'FAC-20261111-00001',
      estado: 'EMITIDA',
      subtotal: 4200,
      descuento: 200,
      total: 4000,
      fechaEmision: DateTime(2026, 11, 11, 18, 57),
      clienteNombre: 'Yesenia Cassiani Díaz',
      formaPagoNombre: 'Efectivo',
      detalles: const [
        DetalleVenta(
          productoId: 1,
          descripcion: 'Arroz',
          cantidad: 1,
          precioUnitario: 4200,
          totalLinea: 4200,
        ),
      ],
    );
    String? compartido;
    var nuevaVenta = false;

    await tester.pumpWidget(
      _envolver(
        carrito,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => mostrarFactura(
                context,
                venta,
                carrito,
                alNuevaVenta: () => nuevaVenta = true,
                alCompartir: (texto) async => compartido = texto,
              ),
              child: const Text('abrir factura'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir factura'));
    await tester.pumpAndSettle();

    expect(find.text('SuperMarket V'), findsOneWidget);
    expect(find.text('Yesenia Cassiani Díaz'), findsOneWidget);
    expect(find.text('Descuento'), findsOneWidget);
    expect(find.text('Gracias por su compra.'), findsOneWidget);
    expect(find.text('Compartir'), findsOneWidget);
    expect(find.text('Nueva venta'), findsOneWidget);
    expect(find.text('Cerrar'), findsNothing);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Venta registrada'), findsOneWidget);

    await tester.ensureVisible(find.text('Compartir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compartir'));
    await tester.pump();
    expect(compartido, contains('Recibo FAC-20261111-00001'));
    expect(compartido, contains('Cliente: Yesenia Cassiani Díaz'));
    expect(compartido, contains('Gracias por su compra.'));

    await tester.ensureVisible(find.text('Nueva venta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nueva venta'));
    await tester.pumpAndSettle();

    expect(nuevaVenta, isTrue);
    expect(find.text('Venta registrada'), findsNothing);
    expect(carrito.vacio, isTrue);
  });
}
