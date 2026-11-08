enum GrupoDestino { barra, operacion, catalogo, administracion }

class Destino {
  const Destino({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.grupo,
    this.ruta,
    this.sinonimos = const [],
  });

  final String id;
  final String nombre;
  final List<List<dynamic>> icono;
  final GrupoDestino grupo;
  final String? ruta;
  final List<String> sinonimos;

  bool get disponible => ruta != null;
}
