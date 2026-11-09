num aNumero(dynamic valor) {
  if (valor is num) return valor;
  return num.tryParse('$valor') ?? 0;
}
