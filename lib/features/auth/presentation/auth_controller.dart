import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import '../data/models/usuario.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this._repositorio});

  static const String _mensajeCredenciales =
      'No pudimos iniciar sesión. Revisa tu correo y clave e intenta de nuevo.';
  static const String _mensajeSesionExpirada =
      'Tu sesión terminó. Inicia sesión de nuevo.';
  static const String _mensajeCodigo =
      'El código de acceso no es válido, ya se usó o venció.';

  final AuthRepository _repositorio;

  Usuario? _usuario;
  bool _cargando = false;
  String? _error;
  String? _aviso;
  Map<String, String> _errores = const {};
  CredencialesRecordadas? _recordadas;

  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  bool get autenticado => _usuario != null;
  String? get error => _error;
  String? get aviso => _aviso;
  Map<String, String> get errores => _errores;
  String? get correoRecordado => _recordadas?.correo;
  String? get claveRecordada => _recordadas?.clave;

  Future<void> restaurar() async {
    _usuario = await _repositorio.restaurarSesion();
    _recordadas = await _repositorio.leerRecordadas();
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
    bool recordar = false,
  }) {
    return _autenticar(
      () => _repositorio.login(email: email, password: password),
      (e) => e.status == 500 ? _mensajeCredenciales : e.mensaje,
      alExito: () => _actualizarRecordadas(recordar, email, password),
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

  Future<void> sesionExpirada() async {
    if (_usuario == null) return;
    _usuario = null;
    await _repositorio.cerrarSesion();
    _error = null;
    _errores = const {};
    _aviso = _mensajeSesionExpirada;
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    await _repositorio.cerrarSesion();
    _usuario = null;
    _aviso = null;
    _error = null;
    _errores = const {};
    notifyListeners();
  }

  void limpiarErrores() {
    if (_error == null && _errores.isEmpty && _aviso == null) return;
    _aviso = null;
    _error = null;
    _errores = const {};
    notifyListeners();
  }

  Future<void> _actualizarRecordadas(
    bool recordar,
    String email,
    String password,
  ) async {
    try {
      if (recordar) {
        await _repositorio.recordar(email, password);
        _recordadas = (correo: email, clave: password);
      } else {
        await _repositorio.olvidarRecordadas();
        _recordadas = null;
      }
    } catch (_) {
      _recordadas = null;
    }
  }

  Future<bool> _autenticar(
    Future<Usuario> Function() accion,
    String Function(ApiException) mensajePara, {
    Future<void> Function()? alExito,
  }) async {
    _cargando = true;
    _aviso = null;
    _error = null;
    _errores = const {};
    notifyListeners();

    try {
      _usuario = await accion();
      await alExito?.call();
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
