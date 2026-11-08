import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStorage {
  SessionStorage({FlutterSecureStorage? almacen})
    : _almacen = almacen ?? const FlutterSecureStorage();

  static const String _claveToken = 'token';
  static const String _claveUsuario = 'usuario';
  static const String _claveBienvenida = 'bienvenida_vista';

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

  Future<void> borrar() async {
    await _almacen.delete(key: _claveToken);
    await _almacen.delete(key: _claveUsuario);
  }
}
