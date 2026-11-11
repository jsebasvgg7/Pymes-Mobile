import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/productos/producto_inventario.dart';

Map<String, dynamic> _json({
  Object? cantidad = 12,
  Object? stockBajo = false,
  Object? unidad = 'UNIDAD',
  Object? categoria = 'Bebidas',
  Object? minimo = 5,
}) {
  return {
    'id': 1,
    'empresaId': 4,
    'productoId': 9,
    'productoNombre': '  Gaseosa 1.5 L  ',
    'productoSku': 'BEB-002',
    'categoriaNombre': categoria,
    'unidadMedida': unidad,
    'cantidadActual': cantidad,
    'costoPromedio': 3200.5,
    'stockMinimo': minimo,
    'precioVenta': 4500,
    'stockBajo': stockBajo,
  };
}

void main() {
  test('lee los campos del inventario y recorta los textos', () {
    final item = ProductoInventario.fromJson(_json());
    expect(item.productoId, 9);
    expect(item.nombre, 'Gaseosa 1.5 L');
    expect(item.sku, 'BEB-002');
    expect(item.categoria, 'Bebidas');
    expect(item.unidadMedida, 'UNIDAD');
    expect(item.cantidadActual, 12);
    expect(item.costoPromedio, 3200.5);
    expect(item.stockMinimo, 5);
    expect(item.precioVenta, 4500);
    expect(item.stockBajo, isFalse);
  });

  test('conserva las cantidades decimales', () {
    final item = ProductoInventario.fromJson(
      _json(cantidad: 2.5, unidad: 'KILOGRAMO'),
    );
    expect(item.cantidadActual, 2.5);
  });

  test('acepta números enviados como texto', () {
    final item = ProductoInventario.fromJson(_json(cantidad: '7.250'));
    expect(item.cantidadActual, 7.25);
  });

  test('sin categoría ni sku usa los valores de respaldo', () {
    final json = _json(categoria: null)..['productoSku'] = null;
    final item = ProductoInventario.fromJson(json);
    expect(item.categoria, ProductoInventario.sinCategoria);
    expect(item.sku, '');
  });

  test('campos ausentes no rompen la lectura', () {
    final item = ProductoInventario.fromJson(<String, dynamic>{});
    expect(item.productoId, 0);
    expect(item.nombre, '');
    expect(item.cantidadActual, 0);
    expect(item.stockBajo, isFalse);
  });

  group('estado', () {
    test('disponible cuando hay stock y no está bajo', () {
      expect(ProductoInventario.fromJson(_json()).estado, EstadoStock.disponible);
    });

    test('bajo cuando la cantidad es menor al mínimo', () {
      final item = ProductoInventario.fromJson(_json(cantidad: 3, stockBajo: true));
      expect(item.estado, EstadoStock.bajo);
    });

    test('bajo aunque el backend no marque stockBajo', () {
      final item = ProductoInventario.fromJson(_json(cantidad: 4));
      expect(item.estado, EstadoStock.bajo);
    });

    test('una cantidad igual al mínimo sí es stock bajo', () {
      final item = ProductoInventario.fromJson(_json(cantidad: 5, stockBajo: true));
      expect(item.estado, EstadoStock.bajo);
    });

    test('el criterio coincide con el de la web: bajo si cantidad <= mínimo', () {
      for (final cantidad in [1, 4.99, 5]) {
        final item = ProductoInventario.fromJson(_json(cantidad: cantidad));
        expect(
          item.estado,
          EstadoStock.bajo,
          reason: 'cantidad $cantidad con mínimo 5',
        );
      }
      final item = ProductoInventario.fromJson(_json(cantidad: 5.01));
      expect(item.estado, EstadoStock.disponible);
    });

    test('con mínimo cero nunca es stock bajo mientras haya existencias', () {
      final item = ProductoInventario.fromJson(_json(cantidad: 1, minimo: 0));
      expect(item.estado, EstadoStock.disponible);
    });

    test('decimales por debajo del mínimo son stock bajo', () {
      final item = ProductoInventario.fromJson(
        _json(cantidad: 4.999, unidad: 'KILOGRAMO'),
      );
      expect(item.estado, EstadoStock.bajo);
    });

    test('agotado cuando la cantidad es cero, aunque stockBajo sea verdadero', () {
      final item = ProductoInventario.fromJson(_json(cantidad: 0, stockBajo: true));
      expect(item.estado, EstadoStock.agotado);
    });

    test('agotado con cantidad negativa', () {
      final item = ProductoInventario.fromJson(_json(cantidad: -2, stockBajo: true));
      expect(item.estado, EstadoStock.agotado);
    });
  });

  group('permiteDecimales', () {
    test('es verdadero para peso y volumen', () {
      for (final unidad in ['KILOGRAMO', 'GRAMO', 'LITRO', 'MILILITRO']) {
        expect(
          ProductoInventario.fromJson(_json(unidad: unidad)).permiteDecimales,
          isTrue,
          reason: unidad,
        );
      }
    });

    test('es falso para unidades enteras', () {
      for (final unidad in ['UNIDAD', 'CAJA', 'PAQUETE', 'HORA', 'SERVICIO']) {
        expect(
          ProductoInventario.fromJson(_json(unidad: unidad)).permiteDecimales,
          isFalse,
          reason: unidad,
        );
      }
    });

    test('ignora mayúsculas en la unidad recibida', () {
      final item = ProductoInventario.fromJson(_json(unidad: 'litro'));
      expect(item.unidadMedida, 'LITRO');
      expect(item.permiteDecimales, isTrue);
    });
  });

  group('listaDesdeJson', () {
    test('convierte una lista de objetos', () {
      final lista = ProductoInventario.listaDesdeJson([_json(), _json()]);
      expect(lista.length, 2);
    });

    test('descarta elementos que no son objetos', () {
      final lista = ProductoInventario.listaDesdeJson([_json(), 'x', null, 3]);
      expect(lista.length, 1);
    });

    test('una respuesta que no es lista da una lista vacía', () {
      expect(ProductoInventario.listaDesdeJson(null), isEmpty);
      expect(ProductoInventario.listaDesdeJson(<String, dynamic>{}), isEmpty);
    });
  });
}
