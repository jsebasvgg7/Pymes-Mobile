import 'package:flutter/services.dart';

String textoMontoCaja(num valor) {
  final entero = valor.round().abs();
  final texto = entero.toString();
  final partes = <String>[];
  for (var i = texto.length; i > 0; i -= 3) {
    partes.add(texto.substring(i > 3 ? i - 3 : 0, i));
  }
  final formateado = partes.reversed.join('.');
  return valor.isNegative ? '-$formateado' : formateado;
}

num? montoDesdeTexto(String texto) {
  final digitos = texto.replaceAll(RegExp(r'\D'), '');
  if (digitos.isEmpty) return null;
  return num.tryParse(digitos);
}

class FormatoMiles extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue nuevo,
  ) {
    final digitos = nuevo.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.isEmpty) {
      return const TextEditingValue();
    }
    final formateado = textoMontoCaja(int.parse(digitos));
    return TextEditingValue(
      text: formateado,
      selection: TextSelection.collapsed(offset: formateado.length),
    );
  }
}
