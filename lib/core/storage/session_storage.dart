import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStorage {
  SessionStorage({FlutterSecureStorage? almacen})
    : _almacen = almacen ?? const FlutterSecureStorage();

  static const String _claveToken = 'token';
  static const String _claveUsuario = 'usuario';
  static const String _claveBienvenida = 'bienvenida_vista';
  static const String _claveCorreoRecordado = 'recordar_correo';
  static const String _claveClaveRecordada = 'recordar_clave';

  final FlutterSecureStorage _almacen;

  Future<void> guardar(String token, String usuarioJson) async {
    await _almacen.write(key: _claveToken, value: token);
    await _almacen.write(key: _claveUsuario, value: usuarioJson);
  }

  Future<String?> leerToken() => _almacen.read(key: _claveToken);

  Future<String?> leerUsuarioJson() => _almacen.read(key: _claveUsuario);

  Future<bool> bienvenidaVista() async =>
      await _almacen.read(key: _claveBienvenida) == '1';

  Future<void> marcarBienvenidaVista() =>
      _almacen.write(key: _claveBienvenida, value: '1');

  Future<void> guardarRecordadas(String correo, String clave) async {
    await _almacen.write(key: _claveCorreoRecordado, value: correo);
    await _almacen.write(key: _claveClaveRecordada, value: clave);
  }

  Future<String?> leerCorreoRecordado() =>
      _almacen.read(key: _claveCorreoRecordado);

  Future<String?> leerClaveRecordada() =>
      _almacen.read(key: _claveClaveRecordada);

  Future<void> olvidarRecordadas() async {
    await _almacen.delete(key: _claveCorreoRecordado);
    await _almacen.delete(key: _claveClaveRecordada);
  }

  Future<void> borrar() async {
    await _almacen.delete(key: _claveToken);
    await _almacen.delete(key: _claveUsuario);
  }
}
