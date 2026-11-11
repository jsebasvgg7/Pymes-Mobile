import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/productos/producto_inventario.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/ajustes_venta.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/categoria_pos.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/cliente_pos.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/estado_caja.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/forma_pago.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/venta_creada.dart';
import 'package:pymes_erp_mobile/features/pos/data/pos_repository.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/pos_controller.dart';

class _RepoFalso implements PosRepository {
  _RepoFalso({
    this.listaProductos = const [],
    this.listaCategorias = const [],
    this.listaFormas = const [],
    this.listaClientes = const [],
    this.listaCajas = const [],
    this.falla = false,
  });

  List<ProductoInventario> listaProductos;
  List<CategoriaPos> listaCategorias;
  List<FormaPago> listaFormas;
  List<ClientePos> listaClientes;
  AjustesVenta ajustesEmpresa = const AjustesVenta();
  List<EstadoCaja> listaCajas;
  bool falla;

  @override
  Future<List<ProductoInventario>> productos(int empresaId) async {
    if (falla) throw Exception('sin red');
    return listaProductos;
  }

  @override
  Future<List<CategoriaPos>> categorias(int empresaId) async =>
      listaCategorias;

  @override
  Future<List<FormaPago>> formasDePago(int empresaId) async => listaFormas;

  @override
  Future<List<ClientePos>> clientes(int empresaId) async => listaClientes;

  @override
  Future<AjustesVenta> ajustes(int empresaId) async => ajustesEmpresa;

  @override
  Future<List<EstadoCaja>> estadoDeCajas(int empresaId) async => listaCajas;

  @override
  Future<String> nombreEmpresa(int empresaId) async => 'SuperMarket V';

  @override
  Future<VentaCreada> crearVenta({
    required int empresaId,
    required int formaPagoId,
    required List<LineaVenta> lineas,
    int? clienteId,
    num descuento = 0,
  }) async => throw UnimplementedError();

  @override
  Future<VentaCreada> anularVenta(int facturaId) async =>
      throw UnimplementedError();
}

ProductoInventario _producto(
  int id,
  String nombre, {
  int? categoriaId,
  String categoria = 'Abarrotes',
  String sku = '',
  num cantidad = 10,
}) {
  return ProductoInventario(
    productoId: id,
    nombre: nombre,
    sku: sku,
    categoria: categoria,
    categoriaId: categoriaId,
    descripcion: '',
    unidadMedida: 'UNIDAD',
    cantidadActual: cantidad,
    costoPromedio: 500,
    stockMinimo: 5,
    precioVenta: 1000,
    stockBajo: false,
  );
}

PosController _controlador(_RepoFalso repo) {
  return PosController(repositorio: repo, empresaId: 7);
}

void main() {
  test('cargar deja el POS listo con los datos', () async {
    final repo = _RepoFalso(
      listaProductos: [_producto(1, 'Lentejas')],
      listaCategorias: const [CategoriaPos(id: 1, nombre: 'Abarrotes')],
      listaFormas: const [
        FormaPago(id: 1, nombre: 'Efectivo', tipo: TipoFormaPago.efectivo),
      ],
      listaClientes: const [ClientePos(id: 8, nombre: 'Don Carlos')],
      listaCajas: const [
        EstadoCaja(cajaId: 1, cajaNombre: 'Principal', abierta: true),
      ],
    );
    final controlador = _controlador(repo);

    await controlador.cargar();

    expect(controlador.estado, EstadoPos.listo);
    expect(controlador.productos.length, 1);
    expect(controlador.categorias.length, 1);
    expect(controlador.hayCajaAbierta, isTrue);
    expect(controlador.carrito.formasDePago.length, 1);
    expect(controlador.carrito.clientes.length, 1);
  });

  test('si la carga falla, el POS queda en error con mensaje', () async {
    final controlador = _controlador(_RepoFalso(falla: true));

    await controlador.cargar();

    expect(controlador.estado, EstadoPos.error);
    expect(controlador.error, isNotNull);
  });

  test('el buscador filtra por nombre, sku o categoría', () async {
    final repo = _RepoFalso(
      listaProductos: [
        _producto(1, 'Lentejas', sku: 'LEN-001', categoria: 'Granos'),
        _producto(2, 'Arroz', sku: 'ARR-002', categoria: 'Granos'),
        _producto(3, 'Leche', sku: 'LEC-003', categoria: 'Lácteos'),
      ],
    );
    final controlador = _controlador(repo);
    await controlador.cargar();

    controlador.buscar('len');
    expect(controlador.productosVisibles.length, 1);

    controlador.buscar('arr');
    expect(controlador.productosVisibles.single.nombre, 'Arroz');

    controlador.buscar('lácteos');
    expect(controlador.productosVisibles.single.nombre, 'Leche');

    controlador.buscar('');
    expect(controlador.productosVisibles.length, 3);
  });

  test('elegir categoría filtra y se puede quitar', () async {
    final repo = _RepoFalso(
      listaProductos: [
        _producto(1, 'Lentejas', categoriaId: 1),
        _producto(2, 'Leche', categoriaId: 2),
      ],
      listaCategorias: const [
        CategoriaPos(id: 1, nombre: 'Abarrotes'),
        CategoriaPos(id: 2, nombre: 'Lácteos'),
      ],
    );
    final controlador = _controlador(repo);
    await controlador.cargar();

    controlador.elegirCategoria(2);
    expect(controlador.productosVisibles.single.nombre, 'Leche');

    controlador.elegirCategoria(null);
    expect(controlador.productosVisibles.length, 2);
  });

  test('las categorías visibles son las que tienen productos', () async {
    final repo = _RepoFalso(
      listaProductos: [_producto(1, 'Lentejas', categoriaId: 1)],
      listaCategorias: const [
        CategoriaPos(id: 1, nombre: 'Abarrotes'),
        CategoriaPos(id: 9, nombre: 'Sin productos'),
      ],
    );
    final controlador = _controlador(repo);
    await controlador.cargar();

    expect(controlador.categoriasVisibles.length, 1);
    expect(controlador.categoriasVisibles.single.id, 1);
  });

  test('sin caja abierta se avisa, y con caja abierta no', () async {
    final cerrado = _controlador(
      _RepoFalso(
        listaCajas: const [
          EstadoCaja(cajaId: 1, cajaNombre: 'Principal', abierta: false),
        ],
      ),
    );
    await cerrado.cargar();

    expect(cerrado.sinCajaAbierta, isTrue);

    final abierto = _controlador(
      _RepoFalso(
        listaCajas: const [
          EstadoCaja(cajaId: 1, cajaNombre: 'Principal', abierta: true),
        ],
      ),
    );
    await abierto.cargar();

    expect(abierto.sinCajaAbierta, isFalse);
  });

  test('el carrito se comparte entre la pantalla y el controlador', () async {
    final controlador = _controlador(_RepoFalso());

    expect(controlador.carrito, same(controlador.carrito));
  });
}
