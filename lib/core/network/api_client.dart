import 'package:dio/dio.dart';

import '../config/env.dart';
import '../storage/session_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({required this._almacen, this._alSesionExpirada}) {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.apiUrl,
        connectTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: _alEnviar, onError: _alFallar),
    );
  }

  static const int _maxReintentos = 2;

  final SessionStorage _almacen;
  final void Function()? _alSesionExpirada;
  late final Dio dio;

  Future<dynamic> get(String ruta, {Map<String, dynamic>? query}) {
    return _enviar(() => dio.get<dynamic>(ruta, queryParameters: query));
  }

  Future<dynamic> post(String ruta, {Object? datos}) {
    return _enviar(() => dio.post<dynamic>(ruta, data: datos));
  }

  Future<dynamic> patch(String ruta, {Object? datos}) {
    return _enviar(() => dio.patch<dynamic>(ruta, data: datos));
  }

  Future<dynamic> _enviar(Future<Response<dynamic>> Function() peticion) async {
    try {
      final respuesta = await peticion();
      return respuesta.data;
    } on DioException catch (e) {
      throw ApiException.desde(e);
    }
  }

  Future<void> _alEnviar(
    RequestOptions opciones,
    RequestInterceptorHandler manejador,
  ) async {
    final token = await _almacen.leerToken();
    if (token != null && token.isNotEmpty) {
      opciones.headers['Authorization'] = 'Bearer $token';
    }
    manejador.next(opciones);
  }

  Future<void> _alFallar(
    DioException error,
    ErrorInterceptorHandler manejador,
  ) async {
    final opciones = error.requestOptions;
    final intentos = (opciones.extra['intentos'] as int?) ?? 0;

    if (opciones.method == 'GET' &&
        _esTemporal(error) &&
        intentos < _maxReintentos) {
      await Future<void>.delayed(const Duration(seconds: 2));
      opciones.extra['intentos'] = intentos + 1;
      try {
        final respuesta = await dio.fetch<dynamic>(opciones);
        manejador.resolve(respuesta);
      } on DioException catch (e) {
        manejador.next(e);
      }
      return;
    }

    final llevabaToken = opciones.headers.containsKey('Authorization');
    if (error.response?.statusCode == 401 && llevabaToken) {
      _alSesionExpirada?.call();
    }
    manejador.next(error);
  }

  bool _esTemporal(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final s = e.response?.statusCode;
        return s == 502 || s == 503 || s == 504;
      default:
        return false;
    }
  }
}
