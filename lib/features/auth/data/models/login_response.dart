import 'usuario.dart';

class LoginResponse {
  const LoginResponse({
    required this.token,
    required this.type,
    required this.usuario,
  });

  final String token;
  final String type;
  final Usuario usuario;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      type: json['type'] as String? ?? 'Bearer',
      usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
    );
  }
}
