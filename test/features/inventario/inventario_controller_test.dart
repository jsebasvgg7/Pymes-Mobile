import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/network/api_exception.dart';
import 'package:pymes_erp_mobile/features/inventario/data/inventario_repository.dart';
import 'package:pymes_erp_mobile/features/inventario/data/models/inventario_item.dart';
import 'package:pymes_erp_mobile/features/inventario/presentation/inventario_controller.dart';

class _RepoFalso implements InventarioRepository {
  _RepoFalso(this.accion);

  Future<List<InventarioItem>> Function(int empresaId) accion;
  int llamadas = 0;

  @override
  Future<List<InventarioItem>> listar(int empresaId) {
    llamadas++;
    return accion(empresaId);
  }
}

InventarioItem _item(
  int id,
  String nombre, {
  String sku = '',
  String categoria = 'Bebidas',
  num cantidad = 10,
  num minimo = 5,
  String unidad = 'UNIDAD',
}) {
  return InventarioItem(
    productoId: id,
    nombre: nombre,
    sku: sku,
    categoria: categoria,
    unidadMedida: unidad,
    cantidadActual: cantidad,
    costoPromedio: 1000,
    stockMinimo: minimo,
    precioVenta: 2000,
    stockBajo: cantidad <= minimo,
  );
}

List<InventarioItem> _catalogo() => [
  _item(1, 'Gaseosa', sku: 'BEB-001', cantidad: 20),
  _item(2, 'Arroz', sku: 'ABA-001', categoria: 'Abarrotes', cantidad: 3),
  _item(3, 'Ñame', sku: 'ABA-002', categoria: 'Abarrotes', cantidad: 0),
  _item(4, 'Café molido', sku: 'ABA-003', categoria: 'Abarrotes', cantidad: 8),
  _item(5, 'Leche', sku: 'LAC-001', categoria: 'Lácteos', cantidad: 1.5),
];

List<String> _nombres(InventarioController c) =>
    c.visibles.map((i) => i.nombre).toList();

void main() {
  Future<InventarioController> construir({
    List<InventarioItem>? items,
    FiltroStock filtroInicial = FiltroStock.todos,
  }) async {
    final repo = _RepoFalso((_) async => items ?? _catalogo());
    final controlador = InventarioController(
      repositorio: repo,
      empresaId: 7,
      filtroInicial: filtroInicial,
    );
    await controlador.cargar();
    return controlador;
  }

  group('carga', () {
    test('empieza cargando y pide la empresa del usuario', () async {
      int? pedida;
      final repo = _RepoFalso((id) async {
        pedida = id;
        return _catalogo();
      });
      final controlador = InventarioController(
        repositorio: repo,
        empresaId: 7,
      );
      expect(controlador.estado, EstadoInventario.cargando);
      await controlador.cargar();
      expect(pedida, 7);
      expect(controlador.estado, EstadoInventario.listo);
      expect(controlador.total, 5);
    });

    test('ordena por nombre sin distinguir tildes ni mayúsculas', () async {
      final controlador = await construir();
      expect(_nombres(controlador), [
        'Arroz',
        'Café molido',
        'Gaseosa',
        'Leche',
        'Ñame',
      ]);
    });

    test('un catálogo vacío es un estado listo sin ítems', () async {
      final controlador = await construir(items: const []);
      expect(controlador.estado, EstadoInventario.listo);
      expect(controlador.total, 0);
      expect(controlador.visibles, isEmpty);
    });

    test('si falla la primera carga queda en error con el mensaje', () async {
      final repo = _RepoFalso(
        (_) async => throw const ApiException('Sin conexión'),
      );
      final controlador = InventarioController(
        repositorio: repo,
        empresaId: 7,
      );
      await controlador.cargar();
      expect(controlador.estado, EstadoInventario.error);
      expect(controlador.error, 'Sin conexión');
    });

    test('un error inesperado usa el mensaje genérico', () async {
      final repo = _RepoFalso((_) async => throw StateError('x'));
      final controlador = InventarioController(
        repositorio: repo,
        empresaId: 7,
      );
      await controlador.cargar();
      expect(controlador.estado, EstadoInventario.error);
      expect(
        controlador.error,
        'Ocurrió un error inesperado. Intenta de nuevo.',
      );
    });

    test('reintentar tras un error carga los datos', () async {
      var falla = true;
      final repo = _RepoFalso((_) async {
        if (falla) throw const ApiException('Sin conexión');
        return _catalogo();
      });
      final controlador = InventarioController(
        repositorio: repo,
        empresaId: 7,
      );
      await controlador.cargar();
      expect(controlador.estado, EstadoInventario.error);
      falla = false;
      await controlador.cargar();
      expect(controlador.estado, EstadoInventario.listo);
      expect(controlador.error, isNull);
      expect(controlador.total, 5);
    });
  });

  group('refrescar', () {
    test('actualiza la lista y devuelve verdadero', () async {
      var items = _catalogo();
      final repo = _RepoFalso((_) async => items);
      final controlador = InventarioController(
        repositorio: repo,
        empresaId: 7,
      );
      await controlador.cargar();
      items = [_item(9, 'Nuevo')];
      expect(await controlador.refrescar(), isTrue);
      expect(_nombres(controlador), ['Nuevo']);
    });

    test('si falla conserva los datos y devuelve falso', () async {
      var falla = false;
      final repo = _RepoFalso((_) async {
        if (falla) throw const ApiException('Sin conexión');
        return _catalogo();
      });
      final controlador = InventarioController(
        repositorio: repo,
        empresaId: 7,
      );
      await controlador.cargar();
      falla = true;
      expect(await controlador.refrescar(), isFalse);
      expect(controlador.estado, EstadoInventario.listo);
      expect(controlador.total, 5);
      expect(controlador.error, 'Sin conexión');
    });

    test('mantiene la búsqueda y el filtro al refrescar', () async {
      final controlador = await construir();
      controlador.buscar('arroz');
      controlador.filtrar(FiltroStock.stockBajo);
      await controlador.refrescar();
      expect(_nombres(controlador), ['Arroz']);
    });
  });

  group('búsqueda', () {
    test('busca por nombre, sku y categoría', () async {
      final controlador = await construir();
      controlador.buscar('gaseosa');
      expect(_nombres(controlador), ['Gaseosa']);
      controlador.buscar('LAC-001');
      expect(_nombres(controlador), ['Leche']);
      controlador.buscar('abarrotes');
      expect(_nombres(controlador), ['Arroz', 'Café molido', 'Ñame']);
    });

    test('ignora tildes y mayúsculas', () async {
      final controlador = await construir();
      controlador.buscar('CAFE');
      expect(_nombres(controlador), ['Café molido']);
      controlador.buscar('lacteos');
      expect(_nombres(controlador), ['Leche']);
      controlador.buscar('name');
      expect(_nombres(controlador), ['Ñame']);
    });

    test('con varias palabras exige todas', () async {
      final controlador = await construir();
      controlador.buscar('abarrotes cafe');
      expect(_nombres(controlador), ['Café molido']);
      controlador.buscar('abarrotes gaseosa');
      expect(_nombres(controlador), isEmpty);
    });

    test('un texto vacío o de espacios muestra todo', () async {
      final controlador = await construir();
      controlador.buscar('arroz');
      controlador.buscar('   ');
      expect(controlador.visibles.length, 5);
      expect(controlador.hayFiltros, isFalse);
    });

    test('guarda el texto escrito tal cual', () async {
      final controlador = await construir();
      controlador.buscar('Arr');
      expect(controlador.busqueda, 'Arr');
    });
  });

  group('filtros', () {
    test('Stock bajo muestra solo los que tienen existencias bajas', () async {
      final controlador = await construir();
      controlador.filtrar(FiltroStock.stockBajo);
      expect(_nombres(controlador), ['Arroz', 'Leche']);
    });

    test('una cantidad igual al mínimo no entra en Stock bajo', () async {
      final controlador = await construir(
        items: [
          _item(1, 'Justo', cantidad: 5, minimo: 5),
          _item(2, 'Debajo', cantidad: 4, minimo: 5),
        ],
      );
      controlador.filtrar(FiltroStock.stockBajo);
      expect(_nombres(controlador), ['Debajo']);
    });

    test('Sin stock muestra solo los agotados', () async {
      final controlador = await construir();
      controlador.filtrar(FiltroStock.agotados);
      expect(_nombres(controlador), ['Ñame']);
    });

    test('el filtro inicial se aplica al cargar', () async {
      final controlador = await construir(filtroInicial: FiltroStock.stockBajo);
      expect(controlador.filtro, FiltroStock.stockBajo);
      expect(_nombres(controlador), ['Arroz', 'Leche']);
    });

    test('filtra por categoría', () async {
      final controlador = await construir();
      controlador.elegirCategoria('Abarrotes');
      expect(_nombres(controlador), ['Arroz', 'Café molido', 'Ñame']);
    });

    test('combina búsqueda, filtro y categoría', () async {
      final controlador = await construir();
      controlador.elegirCategoria('Abarrotes');
      controlador.filtrar(FiltroStock.stockBajo);
      expect(_nombres(controlador), ['Arroz']);
      controlador.buscar('leche');
      expect(_nombres(controlador), isEmpty);
    });

    test('las categorías salen sin repetir y ordenadas', () async {
      final controlador = await construir();
      expect(controlador.categorias, ['Abarrotes', 'Bebidas', 'Lácteos']);
    });

    test('si la categoría elegida desaparece al refrescar, se quita', () async {
      var items = _catalogo();
      final repo = _RepoFalso((_) async => items);
      final controlador = InventarioController(
        repositorio: repo,
        empresaId: 7,
      );
      await controlador.cargar();
      controlador.elegirCategoria('Lácteos');
      items = _catalogo().where((i) => i.categoria != 'Lácteos').toList();
      await controlador.refrescar();
      expect(controlador.categoria, isNull);
      expect(controlador.visibles.length, 4);
    });

    test('limpiar quita búsqueda, filtro y categoría pero no el orden', () async {
      final controlador = await construir();
      controlador.ordenar(OrdenInventario.mayorStock);
      controlador.buscar('a');
      controlador.filtrar(FiltroStock.agotados);
      controlador.elegirCategoria('Abarrotes');
      expect(controlador.hayFiltros, isTrue);
      controlador.limpiarFiltros();
      expect(controlador.busqueda, '');
      expect(controlador.filtro, FiltroStock.todos);
      expect(controlador.categoria, isNull);
      expect(controlador.hayFiltros, isFalse);
      expect(controlador.orden, OrdenInventario.mayorStock);
      expect(controlador.visibles.length, 5);
    });
  });

  group('orden', () {
    test('Nombre Z-A invierte el orden', () async {
      final controlador = await construir();
      controlador.ordenar(OrdenInventario.nombreDesc);
      expect(_nombres(controlador), [
        'Ñame',
        'Leche',
        'Gaseosa',
        'Café molido',
        'Arroz',
      ]);
    });

    test('Menor stock empieza por los agotados', () async {
      final controlador = await construir();
      controlador.ordenar(OrdenInventario.menorStock);
      expect(_nombres(controlador), [
        'Ñame',
        'Leche',
        'Arroz',
        'Café molido',
        'Gaseosa',
      ]);
    });

    test('Mayor stock empieza por los que más tienen', () async {
      final controlador = await construir();
      controlador.ordenar(OrdenInventario.mayorStock);
      expect(_nombres(controlador), [
        'Gaseosa',
        'Café molido',
        'Arroz',
        'Leche',
        'Ñame',
      ]);
    });

    test('con la misma cantidad desempata por nombre', () async {
      final controlador = await construir(
        items: [
          _item(1, 'Zeta', cantidad: 4),
          _item(2, 'Alfa', cantidad: 4),
          _item(3, 'Media', cantidad: 4),
        ],
      );
      controlador.ordenar(OrdenInventario.menorStock);
      expect(_nombres(controlador), ['Alfa', 'Media', 'Zeta']);
    });

    test('con el mismo nombre desempata por id de producto', () async {
      final controlador = await construir(
        items: [_item(8, 'Igual'), _item(3, 'Igual'), _item(5, 'Igual')],
      );
      expect(controlador.visibles.map((i) => i.productoId), [3, 5, 8]);
    });

    test('el orden se conserva al filtrar', () async {
      final controlador = await construir();
      controlador.ordenar(OrdenInventario.mayorStock);
      controlador.elegirCategoria('Abarrotes');
      expect(_nombres(controlador), ['Café molido', 'Arroz', 'Ñame']);
    });
  });

  group('notificaciones', () {
    test('avisa al cambiar búsqueda, filtro, categoría y orden', () async {
      final controlador = await construir();
      var avisos = 0;
      controlador.addListener(() => avisos++);
      controlador.buscar('a');
      controlador.filtrar(FiltroStock.stockBajo);
      controlador.elegirCategoria('Abarrotes');
      controlador.ordenar(OrdenInventario.nombreDesc);
      expect(avisos, 4);
    });

    test('no avisa si el valor no cambia', () async {
      final controlador = await construir();
      var avisos = 0;
      controlador.addListener(() => avisos++);
      controlador.buscar('');
      controlador.filtrar(FiltroStock.todos);
      controlador.elegirCategoria(null);
      controlador.ordenar(OrdenInventario.nombreAsc);
      controlador.limpiarFiltros();
      expect(avisos, 0);
    });

    test('no notifica después de liberar el controlador', () async {
      final repo = _RepoFalso((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return _catalogo();
      });
      final controlador = InventarioController(
        repositorio: repo,
        empresaId: 7,
      );
      final carga = controlador.cargar();
      controlador.dispose();
      await expectLater(carga, completes);
    });
  });
}
