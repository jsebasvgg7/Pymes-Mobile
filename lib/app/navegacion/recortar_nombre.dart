String recortarNombre(String nombre, {int maximo = 16}) {
  final limpio = nombre.trim();
  final runas = limpio.runes.toList();
  if (runas.length <= maximo) return limpio;
  return '${String.fromCharCodes(runas.take(maximo)).trimRight()}…';
}
