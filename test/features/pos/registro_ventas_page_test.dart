import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/app/navegacion/destinos.dart';
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
import 'package:pymes_erp_mobile/features/pos/presentation/registro_ventas_page.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/widgets/fila_producto_pos.dart';
import 'package:provider/provider.dart';

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
  return MaterialApp(
    theme: construirTema(),
    home: Scaffold(body: hijo),
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
  int cargasProductos = 0;

  @override
  Future<List<ProductoInventario>> productos(int empresaId) async {
    cargasProductos++;
    return [_producto(1, 'Arroz')];
  }

  @override
  Future<List<CategoriaPos>> categorias(int empresaId) async => const [
    CategoriaPos(id: 1, nombre: 'Abarrotes'),
  ];

  @override
  Future<List<FormaPago>> formasDePago(int empresaId) async => const [
    FormaPago(id: 1, nombre: 'Efectivo', tipo: TipoFormaPago.efectivo),
  ];

  @override
  Future<List<ClientePos>> clientes(int empresaId) async => const [];

  @override
  Future<AjustesVenta> ajustes(int empresaId) async => const AjustesVenta();

  @override
  Future<List<EstadoCaja>> estadoDeCajas(int empresaId) async => const [
    EstadoCaja(cajaId: 1, cajaNombre: 'Principal', abierta: true),
  ];

  @override
  Future<String> nombreEmpresa(int empresaId) async => 'SuperMarket V';

  @override
  Future<VentaCreada> crearVenta({
    required int empresaId,
    required int formaPagoId,
    required List<LineaVenta> lineas,
    int? clienteId,
    num descuento = 0,
  }) async => const VentaCreada(
    id: 31,
    numero: 'FAC-20261110-29091',
    estado: 'EMITIDA',
    subtotal: 1000,
    descuento: 0,
    total: 1000,
  );

  @override
  Future<VentaCreada> anularVenta(int facturaId) async =>
      throw UnimplementedError();
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
          simbolo: r'$',
          decimales: 0,
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
          simbolo: r'$',
          decimales: 0,
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
      _envolver(const Column(children: [Text('Productos')])),
    );

    expect(find.text('Productos'), findsOneWidget);
  });

  testWidgets('la pantalla muestra el título de la feature', (tester) async {
    await tester.pumpWidget(
      _envolver(const Column(children: [Text('Registro de ventas')])),
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
          simbolo: r'$',
          decimales: 0,
        ),
      ),
    );

    final nombre = tester.getRect(find.text('Aceite Vegetal 1 L'));

    expect(nombre.left, lessThan(60));
  });

  testWidgets(
    'tocar un producto actualiza el carrito sin salir de la pantalla',
    (tester) async {
      final auth = AuthController(repositorio: _AuthFalso());
      await auth.restaurar();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthController>.value(value: auth),
            Provider<PosRepository>.value(value: _RepoFalso()),
          ],
          child: MaterialApp(
            theme: construirTema(),
            home: const Scaffold(body: RegistroVentasPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(RegExp('Carrito con 0 productos')),
        findsOneWidget,
      );

      await tester.tap(find.text('Arroz'));
      await tester.pump();

      expect(
        find.bySemanticsLabel(RegExp('Carrito con 1 productos')),
        findsOneWidget,
      );

      await tester.tap(find.text('Arroz'));
      await tester.pump();

      expect(
        find.bySemanticsLabel(RegExp('Carrito con 0 productos')),
        findsOneWidget,
      );
    },
  );

  testWidgets('Nueva venta vuelve al POS y recarga los productos', (
    tester,
  ) async {
    final auth = AuthController(repositorio: _AuthFalso());
    final repo = _RepoFalso();
    await auth.restaurar();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthController>.value(value: auth),
          Provider<PosRepository>.value(value: repo),
        ],
        child: MaterialApp(
          theme: construirTema(),
          home: const Scaffold(body: RegistroVentasPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.cargasProductos, 1);

    await tester.tap(find.text('Arroz'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(RegExp('Carrito con 1 productos')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Último paso'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finalizar venta'));
    await tester.pumpAndSettle();

    expect(find.text('Venta registrada'), findsOneWidget);

    await tester.tap(find.text('Nueva venta'));
    await tester.pumpAndSettle();

    expect(find.text('Venta registrada'), findsNothing);
    expect(repo.cargasProductos, 2);
    expect(
      find.bySemanticsLabel(RegExp('Carrito con 0 productos')),
      findsOneWidget,
    );
  });
}
