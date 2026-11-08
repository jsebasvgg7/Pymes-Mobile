class VentasHoy {
  const VentasHoy({required this.cantidad, required this.total});

  final int cantidad;
  final num total;

  factory VentasHoy.desdeFacturas(List<dynamic> facturas) {
    var cantidad = 0;
    num total = 0;
    for (final item in facturas) {
      if (item is! Map) continue;
      if (item['estado'] == 'ANULADA') continue;
      final valor = item['total'];
      final numero = valor is num ? valor : num.tryParse('$valor') ?? 0;
      cantidad++;
      total += numero;
    }
    return VentasHoy(cantidad: cantidad, total: total);
  }
}
