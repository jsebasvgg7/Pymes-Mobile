import 'package:flutter/material.dart';

const double factorEscalaTexto = 0.93;

class EscalaTexto extends StatelessWidget {
  const EscalaTexto({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final datos = MediaQuery.of(context);
    final escalaSistema = datos.textScaler.scale(14) / 14;
    return MediaQuery(
      data: datos.copyWith(
        textScaler: TextScaler.linear(escalaSistema * factorEscalaTexto),
      ),
      child: child,
    );
  }
}
