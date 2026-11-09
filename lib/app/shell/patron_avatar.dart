const int _filas = 5;
const int _columnas = 5;
const int _columnasLibres = 3;

int hashSemilla(String semilla) {
  var hash = 0x811C9DC5;
  for (final rune in semilla.runes) {
    hash ^= rune;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}

List<List<int>> patronAvatar(String semilla) {
  final normalizada = semilla.trim().toLowerCase();
  var estado = hashSemilla(normalizada);
  final libres = List.generate(
    _filas,
    (_) => List<int>.filled(_columnasLibres, 0),
  );
  var llenas = 0;
  for (var f = 0; f < _filas; f++) {
    for (var c = 0; c < _columnasLibres; c++) {
      estado = (estado * 1664525 + 1013904223) & 0xFFFFFFFF;
      final sorteo = (estado >> 16) % 6;
      final valor = sorteo < 2 ? 0 : (sorteo < 4 ? 1 : 2);
      libres[f][c] = valor;
      if (valor != 0) llenas++;
    }
  }
  if (llenas == 0) libres[_filas ~/ 2][_columnasLibres - 1] = 1;
  return List.generate(
    _filas,
    (f) => List.generate(_columnas, (c) {
      final origen = c < _columnasLibres ? c : _columnas - 1 - c;
      return libres[f][origen];
    }),
  );
}
