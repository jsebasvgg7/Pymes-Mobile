String formatearMoneda(num valor) {
  final entero = valor.round();
  final digitos = entero.abs().toString();
  final grupos = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) grupos.write('.');
    grupos.write(digitos[i]);
  }
  final signo = entero < 0 ? '-' : '';
  return '$signo\$ $grupos';
}
