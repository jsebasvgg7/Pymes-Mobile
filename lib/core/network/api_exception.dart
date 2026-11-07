import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.mensaje, {this.status, this.errores = const {}});

  final String mensaje;
  final int? status;
  final Map<String, String> errores;

  factory ApiException.desde(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          'El sistema está tardando en responder. Intenta de nuevo en unos segundos.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'No hay conexión. Revisa tu internet e intenta de nuevo.',
        );
      case DioExceptionType.badResponse:
        return _desdeRespuesta(e.response);
      default:
        return const ApiException(
          'Ocurrió un error inesperado. Intenta de nuevo.',
        );
    }
  }

  static ApiException _desdeRespuesta(Response<dynamic>? r) {
    final status = r?.statusCode;
    final data = r?.data;

    if (status != null && status >= 500) {
      return ApiException(
        'El sistema tuvo un problema. Intenta de nuevo en unos minutos.',
        status: status,
      );
    }

    if (data is Map<String, dynamic>) {
      final errs = data['errors'];
      if (errs is Map) {
        final mapa = errs.map((k, v) => MapEntry(k.toString(), v.toString()));
        if (mapa.isNotEmpty) {
          return ApiException(
            mapa.values.join('\n'),
            status: status,
            errores: mapa,
          );
        }
      }
      final msg = data['message'];
      if (msg is String && msg.trim().isNotEmpty) {
        return ApiException(msg, status: status);
      }
    }

    switch (status) {
      case 401:
        return ApiException(
          'Tu sesión terminó o las credenciales no son correctas.',
          status: status,
        );
      case 403:
        return ApiException(
          'No tienes permiso para esta acción.',
          status: status,
        );
      case 429:
        return ApiException(
          'Demasiados intentos. Espera unos minutos antes de volver a intentarlo.',
          status: status,
        );
      default:
        return ApiException(
          'Ocurrió un error inesperado. Intenta de nuevo.',
          status: status,
        );
    }
  }

  @override
  String toString() => mensaje;
}
