class Rol {
  const Rol({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.modulos = const [],
  });

  final int id;
  final String nombre;
  final String? descripcion;
  final List<String> modulos;

  factory Rol.fromJson(Map<String, dynamic> json) {
    final lista = json['modulos'] as List<dynamic>? ?? const [];
    return Rol(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      modulos: lista.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'modulos': modulos,
  };
}

class Usuario {
  const Usuario({
    required this.id,
    required this.empresaId,
    required this.username,
    required this.email,
    this.roles = const [],
  });

  final int id;
  final int empresaId;
  final String username;
  final String email;
  final List<Rol> roles;

  bool get esAdmin => roles.any((r) => r.nombre.toUpperCase() == 'ADMIN');

  factory Usuario.fromJson(Map<String, dynamic> json) {
    final lista = json['roles'] as List<dynamic>? ?? const [];
    return Usuario(
      id: (json['id'] as num).toInt(),
      empresaId: (json['empresaId'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      roles: lista.map((e) => Rol.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'empresaId': empresaId,
    'username': username,
    'email': email,
    'roles': roles.map((r) => r.toJson()).toList(),
  };
}
