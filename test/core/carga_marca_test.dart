import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/core/widgets/carga_marca.dart';
import 'package:pymes_erp_mobile/core/widgets/estado_carga.dart';
import 'package:pymes_erp_mobile/core/widgets/estado_error.dart';

void main() {
  testWidgets('la carga muestra la marca y anima sin errores', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: CargaMarca(tamano: 96))),
      ),
    );

    expect(find.byType(CargaMarca), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
  });

  testWidgets('el barrido cambia el aspecto de la marca al avanzar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: CargaMarca(tamano: 96))),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    final alInicio = tester.widget<ShaderMask>(find.byType(ShaderMask));
    final inicio = alInicio.shaderCallback(const Rect.fromLTWH(0, 0, 96, 96));

    await tester.pump(const Duration(milliseconds: 600));
    final alFinal = tester.widget<ShaderMask>(find.byType(ShaderMask));
    final final_ = alFinal.shaderCallback(const Rect.fromLTWH(0, 0, 96, 96));

    expect(inicio, isNot(equals(final_)));
  });

  testWidgets('sin barrido la marca dibuja sin errores', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: CargaMarca(tamano: 24, conBarrido: false)),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el estado de carga usa la marca', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EstadoCarga())),
    );

    expect(find.byType(CargaMarca), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('el estado de carga muestra el mensaje debajo de la marca', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: EstadoCarga(mensaje: 'Cargando tus gráficas')),
      ),
    );

    expect(find.text('Cargando tus gráficas'), findsOneWidget);

    final marca = tester.getRect(find.byType(CargaMarca));
    final texto = tester.getRect(find.text('Cargando tus gráficas'));

    expect(texto.top, greaterThan(marca.bottom));
    expect(texto.center.dx, closeTo(marca.center.dx, 1));
  });

  testWidgets('el estado de carga queda arriba y es pequeño', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(height: 180),
              Expanded(child: EstadoCarga()),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final pantalla = tester.getRect(find.byType(Scaffold));
    final marca = tester.getRect(find.byType(CargaMarca));

    expect(marca.height, lessThanOrEqualTo(64));
    expect(marca.center.dy, lessThan(pantalla.height * 0.5));
    expect(marca.center.dy, greaterThan(pantalla.height * 0.4));
  });

  testWidgets('el estado de error muestra el mensaje y reintenta', (
    tester,
  ) async {
    var intentos = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EstadoError(
            mensaje: 'No pudimos cargar.',
            alReintentar: () => intentos++,
          ),
        ),
      ),
    );

    expect(find.text('No pudimos cargar.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    expect(intentos, 1);
  });
}
