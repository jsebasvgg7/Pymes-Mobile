String formatearCantidad(num valor, {required bool decimales}) {
  final texto = decimales
      ? valor.abs().toStringAsFixed(3)
      : valor.abs().round().toString();
  final partes = texto.split('.');
  final entera = _agrupar(partes[0]);
  final decimal = partes.length > 1
      ? partes[1].replaceFirst(RegExp(r'0+$'), '')
      : '';
  final esCero = partes[0] == '0' && decimal.isEmpty;
  final signo = valor < 0 && !esCero ? '-' : '';
  return decimal.isEmpty ? '$signo$entera' : '$signo$entera,$decimal';
}

String abreviarUnidad(String unidad, num cantidad) {
  final singular = cantidad == 1;
  return switch (unidad) {
    'KILOGRAMO' => 'kg',
    'GRAMO' => 'g',
    'LITRO' => 'L',
    'MILILITRO' => 'mL',
    'CAJA' => singular ? 'caja' : 'cajas',
    'PAQUETE' => singular ? 'paquete' : 'paquetes',
    'HORA' => singular ? 'hora' : 'horas',
    'SERVICIO' => singular ? 'servicio' : 'servicios',
    _ => 'und',
  };
}

String _agrupar(String digitos) {
  final grupos = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) grupos.write('.');
    grupos.write(digitos[i]);
  }
  return grupos.toString();
}
