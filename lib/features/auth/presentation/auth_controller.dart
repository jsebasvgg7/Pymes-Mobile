import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import '../data/models/usuario.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this._repositorio});

  static const String _mensajeCredenciales =
      'No pudimos iniciar sesión. Revisa tu correo y clave e intenta de nuevo.';

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

  Future<bool> login({required String email, required String password}) async {
    _cargando = true;
    _error = null;
    _errores = const {};
    notifyListeners();

    try {
      _usuario = await _repositorio.login(email: email, password: password);
      return true;
    } on ApiException catch (e) {
      if (e.errores.isNotEmpty) {
        _errores = e.errores;
      } else if (e.status == 500) {
        _error = _mensajeCredenciales;
      } else {
        _error = e.mensaje;
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
}
