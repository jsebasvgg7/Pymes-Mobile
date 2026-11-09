const List<String> mesesCortos = [
  'Ene',
  'Feb',
  'Mar',
  'Abr',
  'May',
  'Jun',
  'Jul',
  'Ago',
  'Sep',
  'Oct',
  'Nov',
  'Dic',
];

const List<String> _diasSemana = [
  'Lun',
  'Mar',
  'Mié',
  'Jue',
  'Vie',
  'Sáb',
  'Dom',
];

String mesCorto(int mes) => mesesCortos[mes - 1];

String diaSemanaCorto(int diaDeSemana) => _diasSemana[diaDeSemana - 1];

String _dosDigitos(int valor) => valor.toString().padLeft(2, '0');

String formatearHora(DateTime fecha) {
  return '${_dosDigitos(fecha.hour)}:${_dosDigitos(fecha.minute)}';
}

String formatearDiaMes(DateTime fecha) {
  return '${_dosDigitos(fecha.day)} ${mesCorto(fecha.month)}';
}

DateTime soloFecha(DateTime fecha) {
  return DateTime(fecha.year, fecha.month, fecha.day);
}

String etiquetaMovimiento(DateTime fecha, DateTime ahora) {
  final dias = DateTime.utc(ahora.year, ahora.month, ahora.day)
      .difference(DateTime.utc(fecha.year, fecha.month, fecha.day))
      .inDays;
  if (dias == 0) return 'Hoy ${formatearHora(fecha)}';
  if (dias == 1) return 'Ayer ${formatearHora(fecha)}';
  return formatearDiaMes(fecha);
}

DateTime? parsearFechaIso(dynamic valor) {
  if (valor is! String || valor.isEmpty) return null;
  final recortada = valor.replaceFirstMapped(
    RegExp(r'(\.\d{6})\d+'),
    (m) => m.group(1)!,
  );
  return DateTime.tryParse(recortada);
}
