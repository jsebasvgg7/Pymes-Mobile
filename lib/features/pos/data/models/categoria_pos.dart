import '../../../../core/format/numero.dart';

class CategoriaPos {
  const CategoriaPos({
    required this.id,
    required this.nombre,
    this.icono,
  });

  final int id;
  final String nombre;
  final String? icono;

  factory CategoriaPos.fromJson(Map<String, dynamic> json) {
    return CategoriaPos(
      id: aNumero(json['id']).toInt(),
      nombre: (json['nombre'] as String?)?.trim() ?? '',
      icono: (json['icono'] as String?)?.trim(),
    );
  }

  static List<CategoriaPos> listaDesdePagina(dynamic json) {
    if (json is! Map) return const [];
    final contenido = json['content'];
    if (contenido is! List) return const [];
    return contenido
        .whereType<Map<String, dynamic>>()
        .map(CategoriaPos.fromJson)
        .toList();
  }
}
