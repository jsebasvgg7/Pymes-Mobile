class AjustesVenta {
  const AjustesVenta({
    this.moneda = 'COP',
    this.simboloMoneda = r'$',
    this.clienteObligatorio = false,
    this.nombreRecibo = '',
    this.mensajePieRecibo = '',
  });

  final String moneda;
  final String simboloMoneda;
  final bool clienteObligatorio;
  final String nombreRecibo;
  final String mensajePieRecibo;

  factory AjustesVenta.fromJson(Map<String, dynamic> json) {
    return AjustesVenta(
      moneda: (json['moneda'] as String?)?.trim().toUpperCase() ?? 'COP',
      simboloMoneda: (json['simboloMoneda'] as String?)?.trim().isEmpty ?? true
          ? r'$'
          : (json['simboloMoneda'] as String).trim(),
      clienteObligatorio: json['clienteObligatorio'] == true,
      nombreRecibo: (json['nombreRecibo'] as String?)?.trim() ?? '',
      mensajePieRecibo: (json['mensajePieRecibo'] as String?)?.trim() ?? '',
    );
  }
}
