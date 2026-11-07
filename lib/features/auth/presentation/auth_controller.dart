import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import '../data/models/usuario.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this._repositorio});

  static const String _mensajeCredenciales =
      'No pudimos iniciar sesión. Revisa tu correo y clave e intenta de nuevo.';
  static const String _mensajeCodigo =
      'El código de acceso no es válido, ya se usó o venció.';

  final AuthRepository _repositorio;

  Usuario? _usuario;
  bool _cargando = false;
  String? _error;
  Map<String, String> _errores = const {};

  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  bool get autenticado => _usuario != null;
  String? get error => _error;
  Map<String, String> get errores => _errores;

  Future<void> restaurar() async {
    _usuario = await _repositorio.restaurarSesion();
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) {
    return _autenticar(
      () => _repositorio.login(email: email, password: password),
      (e) => e.status == 500 ? _mensajeCredenciales : e.mensaje,
    );
  }

  Future<bool> registrar({
    required String empresaNombre,
    required String username,
    required String email,
    required String password,
    required String codigoRegistro,
  }) {
    return _autenticar(
      () => _repositorio.registrar(
        empresaNombre: empresaNombre,
        username: username,
        email: email,
        password: password,
        codigoRegistro: codigoRegistro,
      ),
      (e) => e.status == 403 ? _mensajeCodigo : e.mensaje,
    );
  }

  Future<void> cerrarSesion() async {
    await _repositorio.cerrarSesion();
    _usuario = null;
    _error = null;
    _errores = const {};
    notifyListeners();
  }

  void limpiarErrores() {
    if (_error == null && _errores.isEmpty) return;
    _error = null;
    _errores = const {};
    notifyListeners();
  }

  Future<bool> _autenticar(
    Future<Usuario> Function() accion,
    String Function(ApiException) mensajePara,
  ) async {
    _cargando = true;
    _error = null;
    _errores = const {};
    notifyListeners();

    try {
      _usuario = await accion();
      return true;
    } on ApiException catch (e) {
      if (e.errores.isNotEmpty) {
        _errores = e.errores;
      } else {
        _error = mensajePara(e);
      }
      return false;
    } catch (_) {
      _error = 'Ocurrió un error inesperado. Intenta de nuevo.';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
