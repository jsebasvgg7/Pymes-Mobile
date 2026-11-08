import 'destino.dart';

const Map<String, String> _acentos = {
  'á': 'a',
  'à': 'a',
  'ä': 'a',
  'â': 'a',
  'é': 'e',
  'è': 'e',
  'ë': 'e',
  'ê': 'e',
  'í': 'i',
  'ì': 'i',
  'ï': 'i',
  'î': 'i',
  'ó': 'o',
  'ò': 'o',
  'ö': 'o',
  'ô': 'o',
  'ú': 'u',
  'ù': 'u',
  'ü': 'u',
  'û': 'u',
  'ñ': 'n',
};

String normalizarTexto(String texto) {
  final salida = StringBuffer();
  for (final codigo in texto.toLowerCase().runes) {
    final letra = String.fromCharCode(codigo);
    salida.write(_acentos[letra] ?? letra);
  }
  return salida.toString().trim();
}

List<Destino> buscarDestinos(List<Destino> lista, String consulta) {
  final palabras = normalizarTexto(
    consulta,
  ).split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (palabras.isEmpty) {
    return List.of(lista);
  }

  final resultados = <({int puntos, int orden, Destino destino})>[];
  for (var i = 0; i < lista.length; i++) {
    final destino = lista[i];
    final nombre = normalizarTexto(destino.nombre);
    final claves = destino.sinonimos.map(normalizarTexto).toList();
    var puntos = 0;
    var coincide = true;
    for (final palabra in palabras) {
      if (nombre.contains(palabra)) {
        puntos += 2;
      } else if (claves.any((c) => c.contains(palabra))) {
        puntos += 1;
      } else {
        coincide = false;
        break;
      }
    }
    if (coincide) {
      resultados.add((puntos: puntos, orden: i, destino: destino));
    }
  }

  resultados.sort((a, b) {
    final porPuntos = b.puntos.compareTo(a.puntos);
    return porPuntos != 0 ? porPuntos : a.orden.compareTo(b.orden);
  });
  return resultados.map((r) => r.destino).toList();
}
