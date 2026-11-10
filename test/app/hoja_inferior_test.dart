import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/app/shell/hoja_inferior.dart';

void main() {
  testWidgets('la hoja se abre sobre el navegador raíz y no sobre el interno', (
    tester,
  ) async {
    final raiz = GlobalKey<NavigatorState>();
    NavigatorState? navegadorDeLaHoja;

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: raiz,
        home: Scaffold(
          bottomNavigationBar: const SizedBox(height: 56, child: Text('barra')),
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (interno) => Scaffold(
                body: TextButton(
                  onPressed: () => mostrarHojaInferior<void>(
                    context: interno,
                    builder: (hoja) {
                      navegadorDeLaHoja = Navigator.of(hoja);
                      return const SizedBox(height: 120, child: Text('hoja'));
                    },
                  ),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('hoja'), findsOneWidget);
    expect(navegadorDeLaHoja, same(raiz.currentState));
  });
}
