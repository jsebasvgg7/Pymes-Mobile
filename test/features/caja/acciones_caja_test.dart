import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pymes_erp_mobile/features/caja/presentation/widgets/acciones_caja.dart';

Widget _envolver({
  required double ancho,
  required bool abierta,
  required bool puedeReabrir,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: ancho,
          child: AccionesCaja(
            abierta: abierta,
            puedeReabrir: puedeReabrir,
            ocupado: false,
            alAbrir: () {},
            alCerrar: () {},
            alReabrir: () {},
            alMovimiento: () {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('con ancho suficiente muestra Nuevo movimiento completo', (
    tester,
  ) async {
    await tester.pumpWidget(
      _envolver(ancho: 760, abierta: true, puedeReabrir: false),
    );

    expect(find.text('Nuevo movimiento'), findsOneWidget);
    expect(find.text('Nuevo mov.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('con ancho angosto abrevia a Nuevo mov. en una sola linea', (
    tester,
  ) async {
    await tester.pumpWidget(
      _envolver(ancho: 340, abierta: true, puedeReabrir: false),
    );

    expect(find.text('Nuevo mov.'), findsOneWidget);
    expect(find.text('Nuevo movimiento'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reabrir cierre se abrevia a Reabrir con ancho angosto', (
    tester,
  ) async {
    await tester.pumpWidget(
      _envolver(ancho: 340, abierta: false, puedeReabrir: true),
    );

    expect(find.text('Reabrir'), findsOneWidget);
    expect(find.text('Reabrir cierre'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('con ancho suficiente muestra Reabrir cierre completo', (
    tester,
  ) async {
    await tester.pumpWidget(
      _envolver(ancho: 760, abierta: false, puedeReabrir: true),
    );

    expect(find.text('Reabrir cierre'), findsOneWidget);
    expect(find.text('Reabrir'), findsNothing);
  });
}
