import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/productos/producto_inventario.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/ajustes_venta.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/cliente_pos.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/forma_pago.dart';
import 'package:pymes_erp_mobile/features/pos/presentation/carrito_controller.dart';

ProductoInventario _producto(
  int id,
  String nombre, {
  String unidad = 'UNIDAD',
  num cantidad = 10,
  num minimo = 5,
  num precio = 1000,
}) {
  return ProductoInventario(
    productoId: id,
    nombre: nombre,
    sku: 'SKU-$id',
    categoria: 'Abarrotes',
    categoriaId: 3,
    descripcion: '',
    unidadMedida: unidad,
    cantidadActual: cantidad,
    costoPromedio: 500,
    stockMinimo: minimo,
    precioVenta: precio,
    stockBajo: false,
  );
}

const FormaPago _efectivo = FormaPago(
  id: 1,
  nombre: 'Efectivo',
  tipo: TipoFormaPago.efectivo,
);

const FormaPago _credito = FormaPago(
  id: 2,
  nombre: 'Crédito',
  tipo: TipoFormaPago.credito,
);

const ClientePos _cliente = ClientePos(id: 8, nombre: 'Don Carlos');

CarritoController _controlador({AjustesVenta? ajustes}) {
  return CarritoController(
    ajustes: ajustes ?? const AjustesVenta(),
  )..cargarFormasDePago(const [_efectivo, _credito]);
}

void main() {
  group('regla 1: selección', () {
    test('un producto agotado no se puede agregar', () {
      final controlador = _controlador();
      final agotado = _producto(1, 'Arroz', cantidad: 0);

      expect(controlador.agregar(agotado), isFalse);
      expect(controlador.lineas, isEmpty);
    });

    test('al marcar entra con el paso: 0,5 en peso y 1 en las demás', () {
      final controlador = _controlador();

      controlador.agregar(_producto(1, 'Lentejas', unidad: 'KILOGRAMO'));
      controlador.agregar(_producto(2, 'Arroz'));

      expect(controlador.lineas.first.cantidad, 0.5);
      expect(controlador.lineas.last.cantidad, 1);
    });

    test('al marcar de nuevo suma el paso', () {
      final controlador = _controlador();
      final producto = _producto(1, 'Lentejas', unidad: 'KILOGRAMO');

      controlador.agregar(producto);
      controlador.agregar(producto);

      expect(controlador.lineas.single.cantidad, 1);
    });

    test('desmarcar quita el producto', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Arroz'));

      expect(controlador.quitar(1), isTrue);
      expect(controlador.lineas, isEmpty);
      expect(controlador.estaSeleccionado(1), isFalse);
    });

    test('quitar algo que no está no hace nada', () {
      final controlador = _controlador();

      expect(controlador.quitar(99), isFalse);
    });
  });

  group('regla 2: pasos y topes', () {
    test('el máximo es el stock', () {
      final controlador = _controlador();
      final producto = _producto(1, 'Lentejas', unidad: 'KILOGRAMO', cantidad: 1);

      controlador.agregar(producto);
      controlador.agregar(producto);
      controlador.agregar(producto);

      expect(controlador.lineas.single.cantidad, 1);
    });

    test('un producto con medio kilo de stock entra con 0,5', () {
      final controlador = _controlador();

      controlador.agregar(_producto(1, 'Lentejas', unidad: 'KILOGRAMO', cantidad: 0.5));

      expect(controlador.lineas.single.cantidad, 0.5);
    });

    test('la cantidad se redondea a tres decimales', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Lentejas', unidad: 'KILOGRAMO'));

      controlador.cambiarCantidad(1, 1.23456);

      expect(controlador.lineas.single.cantidad, 1.235);
    });

    test('no se puede superar el stock al cambiar la cantidad', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Lentejas', unidad: 'KILOGRAMO', cantidad: 4));

      controlador.cambiarCantidad(1, 99);

      expect(controlador.lineas.single.cantidad, 4);
    });

    test('bajar de la cantidad mínima no hace nada', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Lentejas', unidad: 'KILOGRAMO'));

      controlador.bajarCantidad(1);

      expect(controlador.lineas.single.cantidad, 0.5);
    });

    test('un producto entero no baja de 1 con el botón de restar', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Arroz'));

      controlador.bajarCantidad(1);

      expect(controlador.lineas.single.cantidad, 1);
    });

    test('subir y bajar mueven un paso', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Lentejas', unidad: 'KILOGRAMO'));

      controlador.subirCantidad(1);
      expect(controlador.lineas.single.cantidad, 1);

      controlador.bajarCantidad(1);
      expect(controlador.lineas.single.cantidad, 0.5);
    });

    test('quitar a cero desde el campo de cantidad sí elimina la línea', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Lentejas', unidad: 'KILOGRAMO'));

      controlador.cambiarCantidad(1, 0);

      expect(controlador.lineas, isEmpty);
    });
  });

  group('regla 3: unidades decimales', () {
    test('peso y volumen permiten decimales; las demás no', () {
      for (final unidad in ['KILOGRAMO', 'GRAMO', 'LITRO', 'MILILITRO']) {
        final producto = _producto(1, 'X', unidad: unidad);
        expect(CarritoController.cantidadValida(0.5, producto), isTrue);
      }
      for (final unidad in ['UNIDAD', 'CAJA', 'PAQUETE', 'HORA', 'SERVICIO']) {
        final producto = _producto(1, 'X', unidad: unidad);
        expect(CarritoController.cantidadValida(0.5, producto), isFalse);
      }
    });
  });

  group('regla 4 y 5: precio y redondeo', () {
    test('la línea usa el precio de venta', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Arroz', precio: 4200));

      expect(controlador.lineas.single.totalLinea, 4200);
    });

    test('la línea se redondea a dos decimales', () {
      final controlador = _controlador();
      controlador.agregar(
        _producto(1, 'Lentejas', unidad: 'KILOGRAMO', precio: 6800.55),
      );

      expect(controlador.lineas.single.totalLinea, 3400.28);
    });

    test('el subtotal suma las líneas ya redondeadas', () {
      final controlador = _controlador();
      controlador.agregar(
        _producto(1, 'Lentejas', unidad: 'KILOGRAMO', precio: 6800.55),
      );
      controlador.agregar(_producto(2, 'Arroz', precio: 4200));

      expect(controlador.subtotal, 7600.28);
    });

    test('el redondeo es a dos decimales como el del backend', () {
      expect(CarritoController.redondearMoneda(3400.275), 3400.28);
      expect(CarritoController.redondearMoneda(3400.274), 3400.27);
      expect(CarritoController.redondearMoneda(0.1 + 0.2), 0.3);
      expect(CarritoController.redondearMoneda(1000), 1000);
    });
  });

  group('regla 6: descuento', () {
    test('el total es el subtotal menos el descuento', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Arroz', precio: 10000));

      controlador.cambiarDescuento(2000);

      expect(controlador.subtotal, 10000);
      expect(controlador.descuento, 2000);
      expect(controlador.total, 8000);
    });

    test('el descuento no puede superar el subtotal', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Arroz', precio: 10000));

      controlador.cambiarDescuento(99999);

      expect(controlador.descuento, 10000);
      expect(controlador.total, 0);
    });

    test('el descuento no puede ser negativo', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Arroz', precio: 10000));

      controlador.cambiarDescuento(-500);

      expect(controlador.descuento, 0);
    });
  });

  group('regla 7: recibido y vuelto', () {
    test('el vuelto es el recibido menos el total', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Arroz', precio: 31400));

      controlador.cambiarRecibido(50000);

      expect(controlador.recibido, 50000);
      expect(controlador.vuelto, 18600);
      expect(controlador.faltaEfectivo, isFalse);
    });

    test('si falta dinero se avisa y no se puede finalizar', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Arroz', precio: 31400));

      controlador.cambiarRecibido(10000);

      expect(controlador.faltaEfectivo, isTrue);
      expect(controlador.puedeFinalizar, isFalse);
    });

    test('sin recibido no hay falta de efectivo', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Arroz', precio: 31400));

      controlador.cambiarRecibido(0);

      expect(controlador.faltaEfectivo, isFalse);
    });

    test('con tarjeta o crédito no hay recibido ni vuelto', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Arroz', precio: 31400));
      controlador.cambiarRecibido(50000);

      controlador.elegirFormaDePago(2);

      expect(controlador.esCredito, isTrue);
      expect(controlador.recibido, 0);
      expect(controlador.vuelto, 0);
    });

    test('el recibido no puede ser negativo', () {
      final controlador = _controlador();

      controlador.cambiarRecibido(-100);

      expect(controlador.recibido, 0);
    });
  });

  group('regla 8: crédito y cliente obligatorio', () {
    test('en crédito el cliente es obligatorio', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Arroz'));
      controlador.elegirFormaDePago(2);

      expect(controlador.faltaCliente, isTrue);
      expect(controlador.puedeFinalizar, isFalse);

      controlador.elegirCliente(8);

      expect(controlador.faltaCliente, isFalse);
      expect(controlador.puedeFinalizar, isTrue);
    });

    test('con clienteObligatorio el cliente hace falta siempre', () {
      final controlador = _controlador(
        ajustes: const AjustesVenta(clienteObligatorio: true),
      );
      controlador.agregar(_producto(1, 'Arroz'));

      expect(controlador.faltaCliente, isTrue);

      controlador.elegirCliente(8);

      expect(controlador.faltaCliente, isFalse);
    });

    test('sin cliente obligatorio no hace falta cliente en efectivo', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Arroz'));

      expect(controlador.faltaCliente, isFalse);
      expect(controlador.puedeFinalizar, isTrue);
    });
  });

  group('estado y limpieza', () {
    test('el carrito vacío no se puede finalizar', () {
      final controlador = _controlador();

      expect(controlador.vacio, isTrue);
      expect(controlador.puedeFinalizar, isFalse);
    });

    test('agregar y quitar deja el estado en listo y vacío', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Arroz'));
      expect(controlador.estado, EstadoVenta.listo);

      controlador.quitar(1);
      expect(controlador.estado, EstadoVenta.vacio);
    });

    test('limpiar vacía todo', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Arroz'));
      controlador.elegirCliente(8);
      controlador.cambiarDescuento(500);
      controlador.cambiarRecibido(5000);

      controlador.limpiar();

      expect(controlador.lineas, isEmpty);
      expect(controlador.clienteId, isNull);
      expect(controlador.descuento, 0);
      expect(controlador.recibido, 0);
      expect(controlador.estado, EstadoVenta.vacio);
    });

    test('cuenta los productos y las unidades', () {
      final controlador = _controlador();
      controlador.agregar(_producto(1, 'Lentejas', unidad: 'KILOGRAMO'));
      controlador.agregar(_producto(2, 'Arroz'));

      expect(controlador.cantidadProductos, 2);
      expect(controlador.unidadesTotales, 2);
    });

    test('las formas de pago activas se cargan y se elige la de efectivo', () {
      final controlador = CarritoController(ajustes: const AjustesVenta());
      controlador.cargarFormasDePago(const [_credito, _efectivo]);

      expect(controlador.formasDePago.length, 2);
      expect(controlador.formaPagoId, 1);
    });

    test('una forma de pago inactiva no se ofrece', () {
      final controlador = CarritoController(ajustes: const AjustesVenta());
      controlador.cargarFormasDePago(const [
        FormaPago(
          id: 3,
          nombre: 'Otro',
          tipo: TipoFormaPago.otro,
          activo: false,
        ),
        _efectivo,
      ]);

      expect(controlador.formasDePago.length, 1);
    });

    test('los clientes inactivos no se ofrecen', () {
      final controlador = _controlador();
      controlador.cargarClientes(const [
        ClientePos(id: 9, nombre: 'Inactivo', activo: false),
        _cliente,
      ]);

      expect(controlador.clientes.length, 1);
      expect(controlador.clientes.single.id, 8);
    });
  });
}
