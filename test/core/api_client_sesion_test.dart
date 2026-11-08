import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/network/api_client.dart';
import 'package:pymes_erp_mobile/core/network/api_exception.dart';
import 'package:pymes_erp_mobile/core/storage/session_storage.dart';

class _AlmacenFalso extends SessionStorage {
  _AlmacenFalso(this._token);

  final String? _token;

  @override
  Future<String?> leerToken() async => _token;
}

class _AdaptadorFalso implements HttpClientAdapter {
  _AdaptadorFalso(this._status);

  final int _status;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{}',
      _status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiClient _construir({
  required String? token,
  required int status,
  required void Function() alExpirar,
}) {
  final cliente = ApiClient(
    almacen: _AlmacenFalso(token),
    alSesionExpirada: alExpirar,
  );
  cliente.dio.httpClientAdapter = _AdaptadorFalso(status);
  return cliente;
}

void main() {
  test('un 401 con token avisa que la sesión expiró', () async {
    var llamadas = 0;
    final cliente = _construir(
      token: 'abc',
      status: 401,
      alExpirar: () => llamadas++,
    );

    await expectLater(
      cliente.get('/api/dashboard/resumen/1'),
      throwsA(isA<ApiException>()),
    );
    expect(llamadas, 1);
  });

  test('un 401 sin token no avisa que la sesión expiró', () async {
    var llamadas = 0;
    final cliente = _construir(
      token: null,
      status: 401,
      alExpirar: () => llamadas++,
    );

    await expectLater(
      cliente.post('/api/auth/login', datos: {}),
      throwsA(isA<ApiException>()),
    );
    expect(llamadas, 0);
  });

  test('un 403 con token no avisa que la sesión expiró', () async {
    var llamadas = 0;
    final cliente = _construir(
      token: 'abc',
      status: 403,
      alExpirar: () => llamadas++,
    );

    await expectLater(
      cliente.get('/api/dashboard/resumen/2'),
      throwsA(isA<ApiException>()),
    );
    expect(llamadas, 0);
  });
}
