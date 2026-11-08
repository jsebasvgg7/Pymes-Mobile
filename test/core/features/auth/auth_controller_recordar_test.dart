import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/network/api_client.dart';
import 'package:pymes_erp_mobile/core/storage/session_storage.dart';
import 'package:pymes_erp_mobile/features/auth/data/auth_repository.dart';
import 'package:pymes_erp_mobile/features/auth/presentation/auth_controller.dart';

const String _respuestaLogin =
    '{"token":"abc","type":"Bearer","usuario":{"id":1,"empresaId":1,'
    '"username":"usuario","email":"correo@ejemplo.com","roles":[]}}';

class _AlmacenMemoria extends SessionStorage {
  String? token;
  String? usuarioJson;
  String? correo;
  String? clave;
  bool fallaLectura = false;

  @override
  Future<void> guardar(String token, String usuarioJson) async {
    this.token = token;
    this.usuarioJson = usuarioJson;
  }

  @override
  Future<String?> leerToken() async => token;

  @override
  Future<String?> leerUsuarioJson() async => usuarioJson;

  @override
  Future<void> borrar() async {
    token = null;
    usuarioJson = null;
  }

  @override
  Future<void> guardarRecordadas(String correo, String clave) async {
    this.correo = correo;
    this.clave = clave;
  }

  @override
  Future<String?> leerCorreoRecordado() async {
    if (fallaLectura) throw StateError('lectura');
    return correo;
  }

  @override
  Future<String?> leerClaveRecordada() async {
    if (fallaLectura) throw StateError('lectura');
    return clave;
  }

  @override
  Future<void> olvidarRecordadas() async {
    correo = null;
    clave = null;
  }
}

class _AdaptadorFalso implements HttpClientAdapter {
  _AdaptadorFalso(this._status, this._cuerpo);

  final int _status;
  final String _cuerpo;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      _cuerpo,
      _status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

AuthController _construir(_AlmacenMemoria almacen, {int status = 200}) {
  final cliente = ApiClient(almacen: almacen);
  cliente.dio.httpClientAdapter = _AdaptadorFalso(
    status,
    status == 200 ? _respuestaLogin : '{}',
  );
  return AuthController(
    repositorio: AuthRepository(cliente: cliente, almacen: almacen),
  );
}

void main() {
  test('un login correcto con la casilla activa guarda correo y clave', () async {
    final almacen = _AlmacenMemoria();
    final auth = _construir(almacen);

    final ok = await auth.login(
      email: 'correo@ejemplo.com',
      password: 'secreta',
      recordar: true,
    );

    expect(ok, isTrue);
    expect(almacen.correo, 'correo@ejemplo.com');
    expect(almacen.clave, 'secreta');
    expect(auth.correoRecordado, 'correo@ejemplo.com');
    expect(auth.claveRecordada, 'secreta');
  });

  test('un login correcto con la casilla apagada borra lo guardado', () async {
    final almacen = _AlmacenMemoria()
      ..correo = 'viejo@ejemplo.com'
      ..clave = 'vieja';
    final auth = _construir(almacen);

    final ok = await auth.login(
      email: 'correo@ejemplo.com',
      password: 'secreta',
    );

    expect(ok, isTrue);
    expect(almacen.correo, isNull);
    expect(almacen.clave, isNull);
    expect(auth.correoRecordado, isNull);
  });

  test('un login fallido no guarda nada', () async {
    final almacen = _AlmacenMemoria();
    final auth = _construir(almacen, status: 500);

    final ok = await auth.login(
      email: 'correo@ejemplo.com',
      password: 'mala',
      recordar: true,
    );

    expect(ok, isFalse);
    expect(almacen.correo, isNull);
    expect(almacen.clave, isNull);
  });

  test('restaurar carga lo recordado', () async {
    final almacen = _AlmacenMemoria()
      ..correo = 'correo@ejemplo.com'
      ..clave = 'secreta';
    final auth = _construir(almacen);

    await auth.restaurar();

    expect(auth.correoRecordado, 'correo@ejemplo.com');
    expect(auth.claveRecordada, 'secreta');
  });

  test('restaurar no falla si la lectura de lo recordado falla', () async {
    final almacen = _AlmacenMemoria()..fallaLectura = true;
    final auth = _construir(almacen);

    await auth.restaurar();

    expect(auth.correoRecordado, isNull);
    expect(auth.claveRecordada, isNull);
  });

  test('cerrar sesión no borra lo recordado', () async {
    final almacen = _AlmacenMemoria();
    final auth = _construir(almacen);
    await auth.login(
      email: 'correo@ejemplo.com',
      password: 'secreta',
      recordar: true,
    );

    await auth.cerrarSesion();

    expect(auth.autenticado, isFalse);
    expect(almacen.token, isNull);
    expect(almacen.correo, 'correo@ejemplo.com');
    expect(almacen.clave, 'secreta');
  });

  test('la sesión expirada deja el aviso y conserva lo recordado', () async {
    final almacen = _AlmacenMemoria();
    final auth = _construir(almacen);
    await auth.login(
      email: 'correo@ejemplo.com',
      password: 'secreta',
      recordar: true,
    );

    await auth.sesionExpirada();
    await auth.sesionExpirada();

    expect(auth.autenticado, isFalse);
    expect(auth.aviso, 'Tu sesión terminó. Inicia sesión de nuevo.');
    expect(almacen.token, isNull);
    expect(almacen.correo, 'correo@ejemplo.com');
    expect(almacen.clave, 'secreta');
  });
}
