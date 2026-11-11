class ConfiguracionCaja {
  const ConfiguracionCaja({this.moneda = 'COP', this.simboloMoneda = r'$'});

  final String moneda;
  final String simboloMoneda;

  factory ConfiguracionCaja.fromJson(Map<String, dynamic> json) {
    final moneda = (json['moneda'] as String?)?.trim().toUpperCase() ?? '';
    final simbolo = (json['simboloMoneda'] as String?)?.trim() ?? '';
    return ConfiguracionCaja(
      moneda: moneda.isEmpty ? 'COP' : moneda,
      simboloMoneda: simbolo.isEmpty ? r'$' : simbolo,
    );
  }
}
