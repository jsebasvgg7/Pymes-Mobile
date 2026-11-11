import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/network/api_client.dart';
import 'package:pymes_erp_mobile/core/network/api_exception.dart';
import 'package:pymes_erp_mobile/core/storage/session_storage.dart';
import 'package:pymes_erp_mobile/features/pos/data/models/forma_pago.dart';
import 'package:pymes_erp_mobile/features/pos/data/pos_repository.dart';

class _Almacen extends SessionStorage {
  @override
  Future<String?> leerToken() async => 'abc';
}

class _Adaptador implements HttpClientAdapter {
  _Adaptador(this.cuerpo, {this.status = 200, this.porPagina});

  final String cuerpo;
  final int status;
  final List<RequestOptions> peticiones = [];

  /// Cuerpo distinto por página, para probar la paginación.
  final List<String>? porPagina;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    peticiones.add(options);
    final pagina = options.queryParameters['page'] as int? ?? 0;
    final porPagina = this.porPagina;
    final respuesta = porPagina == null
        ? cuerpo
        : porPagina[min(pagina, porPagina.length - 1)];
    return ResponseBody.fromString(
      respuesta,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

PosRepository _construir(String cuerpo, {int status = 200}) {
  final cliente = ApiClient(almacen: _Almacen());
  final adaptador = _Adaptador(cuerpo, status: status);
  cliente.dio.httpClientAdapter = adaptador;
  return PosRepository(cliente: cliente);
}

void main() {
  test('los productos se piden paginados por la empresa', () async {
    final adaptador = _Adaptador(
      '{"content":[{"id":9,"nombre":"Lentejas","sku":"LEN-1",'
      '"categoriaId":3,"categoriaNombre":"Abarrotes y granos",'
      '"descripcion":"Lentejas 500 g","unidadMedida":"KILOGRAMO",'
      '"stockActual":15.5,"stockMinimo":5,"precioVenta":6800}]}',
    );
    final cliente = ApiClient(almacen: _Almacen());
    cliente.dio.httpClientAdapter = adaptador;
    final repositorio = PosRepository(cliente: cliente);

    final productos = await repositorio.productos(7);

    expect(
      adaptador.peticiones.first.path,
      '/api/productos/listar-por-empresa/7',
    );
    expect(adaptador.peticiones.first.queryParameters, {
      'page': 0,
      'size': 200,
    });
    expect(productos.length, 1);
    expect(productos.first.productoId, 9);
    expect(productos.first.nombre, 'Lentejas');
    expect(productos.first.categoriaId, 3);
    expect(productos.first.categoria, 'Abarrotes y granos');
    expect(productos.first.descripcion, 'Lentejas 500 g');
    expect(productos.first.unidadMedida, 'KILOGRAMO');
    expect(productos.first.cantidadActual, 15.5);
    expect(productos.first.precioVenta, 6800);
    expect(productos.first.permiteDecimales, isTrue);
  });

  test('las categorías traen su icono', () async {
    final repositorio = _construir(
      '{"content":[{"id":3,"nombre":"Abarrotes y granos","icono":"shopping-basket"},'
      '{"id":4,"nombre":"Lácteos y huevos","icono":null}]}',
    );

    final categorias = await repositorio.categorias(7);

    expect(categorias.length, 2);
    expect(categorias.first.id, 3);
    expect(categorias.first.icono, 'shopping-basket');
    expect(categorias.last.icono, isNull);
  });

  test('las formas de pago leen su tipo', () async {
    final repositorio = _construir(
      '{"content":[{"id":1,"nombre":"Efectivo","tipo":"EFECTIVO","active":true},'
      '{"id":2,"nombre":"Crédito","tipo":"CREDITO","active":true},'
      '{"id":3,"nombre":"Otro","tipo":"OTRO","active":false}]}',
    );

    final formas = await repositorio.formasDePago(7);

    expect(formas.length, 3);
    expect(formas.first.tipo, TipoFormaPago.efectivo);
    expect(formas.first.esEfectivo, isTrue);
    expect(formas.first.esCredito, isFalse);
    expect(formas[1].esCredito, isTrue);
    expect(formas.last.activo, isFalse);
    expect(formas.last.tipo, TipoFormaPago.otro);
  });

  test('los clientes traen nombre y documento', () async {
    final repositorio = _construir(
      '{"content":[{"id":8,"nombre":"Don Carlos","documento":"109999","active":true}]}',
    );

    final clientes = await repositorio.clientes(7);

    expect(clientes.length, 1);
    expect(clientes.first.id, 8);
    expect(clientes.first.nombre, 'Don Carlos');
    expect(clientes.first.documento, '109999');
  });

  test(
    'los ajustes traen moneda, cliente obligatorio y nombre del recibo',
    () async {
      final repositorio = _construir(
        '{"empresaId":7,"moneda":"COP","simboloMoneda":"\$",'
        '"clienteObligatorio":true,"nombreRecibo":"SuperMarket V",'
        '"mensajePieRecibo":"Gracias por su compra"}',
      );

      final ajustes = await repositorio.ajustes(7);

      expect(ajustes.moneda, 'COP');
      expect(ajustes.simboloMoneda, r'$');
      expect(ajustes.clienteObligatorio, isTrue);
      expect(ajustes.nombreRecibo, 'SuperMarket V');
      expect(ajustes.mensajePieRecibo, 'Gracias por su compra');
    },
  );

  test('los ajustes sin símbolo usan el del dólar', () async {
    final repositorio = _construir('{"moneda":"COP","simboloMoneda":""}');

    final ajustes = await repositorio.ajustes(7);

    expect(ajustes.simboloMoneda, r'$');
  });

  test('el estado de caja dice si hay apertura abierta', () async {
    final repositorio = _construir(
      '[{"cajaId":1,"cajaNombre":"Caja Principal","abierta":true,'
      '"requiereCierre":false},'
      '{"cajaId":2,"cajaNombre":"Caja 2","abierta":false,"requiereCierre":true}]',
    );

    final estados = await repositorio.estadoDeCajas(7);

    expect(estados.length, 2);
    expect(estados.first.abierta, isTrue);
    expect(estados.first.requiereCierre, isFalse);
    expect(estados.last.abierta, isFalse);
    expect(estados.last.requiereCierre, isTrue);
  });

  test('el nombre de la empresa se lee', () async {
    final repositorio = _construir('{"id":7,"nombre":"SuperMarket V"}');

    expect(await repositorio.nombreEmpresa(7), 'SuperMarket V');
  });

  test(
    'crear la venta manda empresa, forma de pago, descuento y detalles',
    () async {
      final adaptador = _Adaptador(
        '{"id":31,"numero":"FAC-20261110-29091","estado":"EMITIDA",'
        '"fechaEmision":"2026-11-10T18:57:12","clienteNombre":"Don Carlos",'
        '"formaPagoNombre":"Efectivo","subtotal":31400,"descuento":1000,'
        '"total":30400,"detalles":[{"productoId":9,"descripcion":"Lentejas",'
        '"cantidad":0.5,"precioUnitario":6800,"totalLinea":3400}]}',
      );
      final cliente = ApiClient(almacen: _Almacen());
      cliente.dio.httpClientAdapter = adaptador;
      final repositorio = PosRepository(cliente: cliente);

      final venta = await repositorio.crearVenta(
        empresaId: 7,
        formaPagoId: 1,
        clienteId: 8,
        descuento: 1000,
        lineas: const [
          LineaVenta(
            productoId: 9,
            descripcion: 'Lentejas',
            cantidad: 0.5,
            precioUnitario: 6800,
          ),
        ],
      );

      final peticion = adaptador.peticiones.first;
      expect(peticion.method, 'POST');
      expect(peticion.path, '/api/facturas-venta/crear');
      final cuerpo = peticion.data as Map<String, dynamic>;
      expect(cuerpo['empresaId'], 7);
      expect(cuerpo['formaPagoId'], 1);
      expect(cuerpo['clienteId'], 8);
      expect(cuerpo['descuento'], 1000);
      final detalles = cuerpo['detalles'] as List;
      expect(detalles.length, 1);
      expect((detalles.first as Map<String, dynamic>)['productoId'], 9);
      expect(detalles.first['cantidad'], 0.5);
      expect(detalles.first['descripcion'], 'Lentejas');
      expect(detalles.first.containsKey('impuestoIds'), isFalse);

      expect(venta.id, 31);
      expect(venta.numero, 'FAC-20261110-29091');
      expect(venta.estado, 'EMITIDA');
      expect(venta.clienteNombre, 'Don Carlos');
      expect(venta.formaPagoNombre, 'Efectivo');
      expect(venta.subtotal, 31400);
      expect(venta.descuento, 1000);
      expect(venta.total, 30400);
      expect(venta.fechaEmision, isNotNull);
      expect(venta.detalles.length, 1);
      expect(venta.detalles.first.totalLinea, 3400);
    },
  );

  test('crear la venta sin cliente no manda el campo', () async {
    final adaptador = _Adaptador('{"id":31,"total":1000}');
    final cliente = ApiClient(almacen: _Almacen());
    cliente.dio.httpClientAdapter = adaptador;
    final repositorio = PosRepository(cliente: cliente);

    await repositorio.crearVenta(
      empresaId: 7,
      formaPagoId: 1,
      lineas: const [
        LineaVenta(
          productoId: 9,
          descripcion: 'Lentejas',
          cantidad: 1,
          precioUnitario: 1000,
        ),
      ],
    );

    final cuerpo = adaptador.peticiones.first.data as Map<String, dynamic>;
    expect(cuerpo.containsKey('clienteId'), isFalse);
  });

  test('anular la venta manda un PATCH con el estado ANULADA', () async {
    final adaptador = _Adaptador(
      '{"id":31,"numero":"FAC-20261110-29091","estado":"ANULADA","total":30400}',
    );
    final cliente = ApiClient(almacen: _Almacen());
    cliente.dio.httpClientAdapter = adaptador;
    final repositorio = PosRepository(cliente: cliente);

    final venta = await repositorio.anularVenta(31);

    final peticion = adaptador.peticiones.first;
    expect(peticion.method, 'PATCH');
    expect(peticion.path, '/api/facturas-venta/actualizar-estado/31');
    expect((peticion.data as Map<String, dynamic>)['estado'], 'ANULADA');
    expect(venta.estado, 'ANULADA');
  });

  test('los productos traen todas las páginas del catálogo', () async {
    final adaptador = _Adaptador(
      '',
      porPagina: const [
        '{"content":[{"id":1,"nombre":"Lentejas","categoriaId":3}],'
            '"totalPages":3}',
        '{"content":[{"id":2,"nombre":"Arroz","categoriaId":3}],'
            '"totalPages":3}',
        '{"content":[{"id":3,"nombre":"Aceite","categoriaId":4}],'
            '"totalPages":3}',
      ],
    );
    final cliente = ApiClient(almacen: _Almacen());
    cliente.dio.httpClientAdapter = adaptador;
    final repositorio = PosRepository(cliente: cliente);

    final productos = await repositorio.productos(7);

    expect(adaptador.peticiones.length, 3);
    expect(
      adaptador.peticiones.map((p) => p.queryParameters['page']).toList(),
      [0, 1, 2],
    );
    expect(productos.map((p) => p.nombre).toList(), [
      'Lentejas',
      'Arroz',
      'Aceite',
    ]);
  });

  test('un catálogo de una sola página hace una sola petición', () async {
    final adaptador = _Adaptador(
      '{"content":[{"id":1,"nombre":"Lentejas"}],"totalPages":1}',
    );
    final cliente = ApiClient(almacen: _Almacen());
    cliente.dio.httpClientAdapter = adaptador;
    final repositorio = PosRepository(cliente: cliente);

    await repositorio.categorias(7);

    expect(adaptador.peticiones.length, 1);
  });

  test('un error del servidor se lanza como ApiException', () async {
    final repositorio = _construir(
      '{"message":"Stock insuficiente"}',
      status: 400,
    );

    await expectLater(
      repositorio.crearVenta(
        empresaId: 7,
        formaPagoId: 1,
        lineas: const [
          LineaVenta(
            productoId: 9,
            descripcion: 'Lentejas',
            cantidad: 1,
            precioUnitario: 100,
          ),
        ],
      ),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensaje,
          'mensaje',
          'Stock insuficiente',
        ),
      ),
    );
  });
}
