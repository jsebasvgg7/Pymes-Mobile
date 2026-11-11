String formatearMoneda(num valor) {
  return formatearMonedaConfigurada(valor, simbolo: r'$', decimales: 0);
}

String formatearMonedaConfigurada(
  num valor, {
  required String simbolo,
  required int decimales,
}) {
  final redondeado = decimales <= 0
      ? valor.abs().round().toDouble()
      : double.parse(valor.abs().toStringAsFixed(decimales));
  final texto = redondeado.toStringAsFixed(decimales);
  final partes = texto.split('.');
  final entero = _agrupar(partes[0]);
  final decimal = partes.length > 1 ? partes[1] : '';
  final monto = decimal.isEmpty ? entero : '$entero,$decimal';
  final signo = redondeado == 0 ? '' : (valor < 0 ? '-' : '');
  return '$signo$simbolo $monto';
}

bool esMonedaSinDecimales(String codigo) {
  return const {'COP', 'CLP', 'JPY', 'PYG'}.contains(codigo.toUpperCase());
}

int decimalesDeMoneda(String codigo) => esMonedaSinDecimales(codigo) ? 0 : 2;

String _agrupar(String digitos) {
  final grupos = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) grupos.write('.');
    grupos.write(digitos[i]);
  }
  return grupos.toString();
}
