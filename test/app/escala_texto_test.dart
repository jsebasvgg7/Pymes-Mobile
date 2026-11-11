import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pymes_erp_mobile/app/escala_texto.dart';

void main() {
  testWidgets('reduce el texto un 7 por ciento', (tester) async {
    late double escalado;
    await tester.pumpWidget(
      MaterialApp(
        builder: (contexto, hijo) => EscalaTexto(child: hijo!),
        home: Builder(
          builder: (contexto) {
            escalado = MediaQuery.textScalerOf(contexto).scale(100);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(escalado, closeTo(93, 0.01));
  });

  testWidgets('respeta la escala de texto del sistema', (tester) async {
    late double escalado;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MaterialApp(
          builder: (contexto, hijo) => EscalaTexto(child: hijo!),
          home: Builder(
            builder: (contexto) {
              escalado = MediaQuery.textScalerOf(contexto).scale(100);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(escalado, closeTo(139.5, 0.01));
  });
}
