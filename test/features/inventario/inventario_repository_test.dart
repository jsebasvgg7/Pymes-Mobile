import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/network/api_client.dart';
import 'package:pymes_erp_mobile/core/network/api_exception.dart';
import 'package:pymes_erp_mobile/core/storage/session_storage.dart';
import 'package:pymes_erp_mobile/features/inventario/data/inventario_repository.dart';
import 'package:pymes_erp_mobile/features/inventario/data/models/inventario_item.dart';

class _Almacen extends SessionStorage {
  @override
  Future<String?> leerToken() async => 'abc';
}

class _Adaptador implements HttpClientAdapter {
  _Adaptador({this.status = 200, this.cuerpo = _lista});

  static const String _lista =
      '[{"id":1,"empresaId":7,"productoId":9,"productoNombre":"Gaseosa",'
      '"productoSku":"BEB-002","categoriaNombre":"Bebidas",'
      '"unidadMedida":"UNIDAD","cantidadActual":12,"costoPromedio":3200.5,'
      '"stockMinimo":5,"precioVenta":4500,"stockBajo":false},'
      '{"id":2,"empresaId":7,"productoId":10,"productoNombre":"Arroz",'
      '"productoSku":"ABA-001","categoriaNombre":null,'
      '"unidadMedida":"KILOGRAMO","cantidadActual":2.5,"costoPromedio":2800,'
      '"stockMinimo":10,"precioVenta":3500,"stockBajo":true}]';

  final int status;
  final String cuerpo;
  final List<RequestOptions> peticiones = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    peticiones.add(options);
    return ResponseBody.fromString(
      status == 200 ? cuerpo : '{}',
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

(InventarioRepository, _Adaptador) _construir(_Adaptador adaptador) {
  final cliente = ApiClient(almacen: _Almacen());
  cliente.dio.httpClientAdapter = adaptador;
  return (InventarioRepository(cliente: cliente), adaptador);
}

void main() {
  test('pide el inventario de la empresa del usuario', () async {
    final (repositorio, adaptador) = _construir(_Adaptador());
    await repositorio.listar(7);
    expect(adaptador.peticiones.length, 1);
    expect(adaptador.peticiones.first.method, 'GET');
    expect(
      adaptador.peticiones.first.path,
      '/api/inventario/listar-por-empresa/7',
    );
  });

  test('convierte la respuesta en ítems de inventario', () async {
    final (repositorio, _) = _construir(_Adaptador());
    final lista = await repositorio.listar(7);
    expect(lista.length, 2);
    expect(lista.first.nombre, 'Gaseosa');
    expect(lista.first.estado, EstadoStock.disponible);
    expect(lista.last.categoria, InventarioItem.sinCategoria);
    expect(lista.last.cantidadActual, 2.5);
    expect(lista.last.permiteDecimales, isTrue);
    expect(lista.last.estado, EstadoStock.bajo);
  });

  test('una lista vacía no es un error', () async {
    final (repositorio, _) = _construir(_Adaptador(cuerpo: '[]'));
    expect(await repositorio.listar(7), isEmpty);
  });

  test('si el backend responde 403, se lanza el error', () async {
    final (repositorio, _) = _construir(_Adaptador(status: 403));
    expect(
      repositorio.listar(7),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 403)),
    );
  });
}
