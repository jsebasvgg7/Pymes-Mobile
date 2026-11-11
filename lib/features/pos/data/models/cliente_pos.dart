import '../../../../core/format/numero.dart';

class ClientePos {
  const ClientePos({
    required this.id,
    required this.nombre,
    this.documento = '',
    this.activo = true,
  });

  final int id;
  final String nombre;
  final String documento;
  final bool activo;

  factory ClientePos.fromJson(Map<String, dynamic> json) {
    return ClientePos(
      id: aNumero(json['id']).toInt(),
      nombre: (json['nombre'] as String?)?.trim() ?? '',
      documento: (json['documento'] as String?)?.trim() ?? '',
      activo: json['active'] != false,
    );
  }

  static List<ClientePos> listaDesdePagina(dynamic json) {
    if (json is! Map) return const [];
    final contenido = json['content'];
    if (contenido is! List) return const [];
    return contenido
        .whereType<Map<String, dynamic>>()
        .map(ClientePos.fromJson)
        .toList();
  }
}
