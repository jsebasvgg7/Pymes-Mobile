import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pymes_erp_mobile/features/caja/data/models/forma_pago_caja.dart';
import 'package:pymes_erp_mobile/features/caja/presentation/widgets/selector_forma_pago.dart';

FormaPagoCaja _forma(int id, String nombre, TipoFormaPagoCaja tipo) {
  return FormaPagoCaja(id: id, nombre: nombre, tipo: tipo, activo: true);
}

final _tres = [
  _forma(1, 'Efectivo', TipoFormaPagoCaja.efectivo),
  _forma(2, 'Tarjeta', TipoFormaPagoCaja.tarjeta),
  _forma(3, 'Transferencia', TipoFormaPagoCaja.transferencia),
];

Widget _envolver({
  required double ancho,
  required List<FormaPagoCaja> formas,
  int? seleccionada,
  ValueChanged<int>? alSeleccionar,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: ancho,
          child: SelectorFormaPago(
            formas: formas,
            seleccionadaId: seleccionada,
            alSeleccionar: alSeleccionar ?? (_) {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('con ancho suficiente muestra icono y nombre de las 3 formas', (
    tester,
  ) async {
    await tester.pumpWidget(_envolver(ancho: 800, formas: _tres));

    expect(find.text('Efectivo'), findsOneWidget);
    expect(find.text('Tarjeta'), findsOneWidget);
    expect(find.text('Transferencia'), findsOneWidget);
    expect(find.byType(Tooltip), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('con ancho angosto muestra solo iconos con tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(_envolver(ancho: 300, formas: _tres));

    expect(find.text('Efectivo'), findsNothing);
    expect(find.text('Transferencia'), findsNothing);
    expect(find.byTooltip('Efectivo'), findsOneWidget);
    expect(find.byTooltip('Tarjeta'), findsOneWidget);
    expect(find.byTooltip('Transferencia'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('las 3 opciones quedan en una sola fila con el mismo ancho', (
    tester,
  ) async {
    await tester.pumpWidget(_envolver(ancho: 300, formas: _tres));

    final a = tester.getRect(find.byTooltip('Efectivo'));
    final b = tester.getRect(find.byTooltip('Tarjeta'));
    final c = tester.getRect(find.byTooltip('Transferencia'));
    expect(a.top, b.top);
    expect(b.top, c.top);
    expect(a.width, closeTo(b.width, 0.01));
    expect(b.width, closeTo(c.width, 0.01));
  });

  testWidgets('tocar una opcion avisa su id', (tester) async {
    int? elegida;
    await tester.pumpWidget(
      _envolver(
        ancho: 300,
        formas: _tres,
        alSeleccionar: (id) => elegida = id,
      ),
    );

    await tester.tap(find.byTooltip('Tarjeta'));
    await tester.pump();

    expect(elegida, 2);
  });

  testWidgets('con mas de 3 formas se acomodan sin perder el nombre', (
    tester,
  ) async {
    final cuatro = [
      ..._tres,
      _forma(4, 'Nequi', TipoFormaPagoCaja.otro),
    ];
    await tester.pumpWidget(_envolver(ancho: 300, formas: cuatro));

    expect(find.text('Nequi'), findsOneWidget);
    expect(find.text('Efectivo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('cada tipo tiene un icono', () {
    for (final tipo in TipoFormaPagoCaja.values) {
      expect(iconoFormaPago(tipo), isNotEmpty);
    }
  });
}
