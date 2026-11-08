import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/storage/session_storage.dart';
import 'models/login_response.dart';
import 'models/usuario.dart';

typedef CredencialesRecordadas = ({String correo, String clave});

class AuthRepository {
  AuthRepository({required this._cliente, required this._almacen});

  final ApiClient _cliente;
  final SessionStorage _almacen;

  Future<Usuario> login({
    required String email,
    required String password,
  }) async {
    final datos = await _cliente.post(
      '/api/auth/login',
      datos: {'email': email, 'password': password},
    );
    return _guardarSesion(datos);
  }

  Future<Usuario> registrar({
    required String empresaNombre,
    required String username,
    required String email,
    required String password,
    required String codigoRegistro,
  }) async {
    final datos = await _cliente.post(
      '/api/auth/registro-cliente',
      datos: {
        'empresaNombre': empresaNombre,
        'username': username,
        'email': email,
        'password': password,
        'codigoRegistro': codigoRegistro,
      },
    );
    return _guardarSesion(datos);
  }

  Future<Usuario?> restaurarSesion() async {
    final token = await _almacen.leerToken();
    final usuarioJson = await _almacen.leerUsuarioJson();
    if (token == null || token.isEmpty || usuarioJson == null) {
      return null;
    }
    try {
      final mapa = jsonDecode(usuarioJson) as Map<String, dynamic>;
      return Usuario.fromJson(mapa);
    } catch (_) {
      await _almacen.borrar();
      return null;
    }
  }

  Future<void> cerrarSesion() => _almacen.borrar();

  Future<CredencialesRecordadas?> leerRecordadas() async {
    try {
      final correo = await _almacen.leerCorreoRecordado();
      final clave = await _almacen.leerClaveRecordada();
      if (correo == null || correo.isEmpty || clave == null || clave.isEmpty) {
        return null;
      }
      return (correo: correo, clave: clave);
    } catch (_) {
      return null;
    }
  }

  Future<void> recordar(String correo, String clave) =>
      _almacen.guardarRecordadas(correo, clave);

  Future<void> olvidarRecordadas() => _almacen.olvidarRecordadas();

  Future<Usuario> _guardarSesion(dynamic datos) async {
    final respuesta = LoginResponse.fromJson(datos as Map<String, dynamic>);
    await _almacen.guardar(
      respuesta.token,
      jsonEncode(respuesta.usuario.toJson()),
    );
    return respuesta.usuario;
  }
}
