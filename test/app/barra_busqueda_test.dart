import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/app/shell/barra_busqueda.dart';
import 'package:pymes_erp_mobile/app/shell/cabecera_shell.dart';
import 'package:pymes_erp_mobile/app/shell/shell_page.dart';
import 'package:pymes_erp_mobile/app/theme.dart';
import 'package:pymes_erp_mobile/core/network/api_client.dart';
import 'package:pymes_erp_mobile/core/storage/session_storage.dart';
import 'package:pymes_erp_mobile/features/auth/data/auth_repository.dart';
import 'package:pymes_erp_mobile/features/auth/data/models/usuario.dart';
import 'package:pymes_erp_mobile/features/auth/presentation/auth_controller.dart';
import 'package:provider/provider.dart';

class _AuthFalso extends AuthController {
  _AuthFalso()
    : super(
        repositorio: AuthRepository(
          cliente: ApiClient(almacen: SessionStorage()),
          almacen: SessionStorage(),
        ),
      );

  @override
  Usuario? get usuario => const Usuario(
    id: 1,
    empresaId: 1,
    username: 'Don Carlos',
    email: 'don@correo.com',
  );
}

Widget _envolver(Widget hijo) {
  return MaterialApp(theme: construirTema(), home: hijo);
}

void main() {
  testWidgets('la barra de búsqueda se pinta y avisa al tocarla', (
    tester,
  ) async {
    var toques = 0;

    await tester.pumpWidget(
      _envolver(
        Scaffold(
          body: Center(child: BarraBusqueda(onTap: () => toques++)),
        ),
      ),
    );

    expect(find.text('Buscar...'), findsOneWidget);

    await tester.tap(find.text('Buscar...'));
    expect(toques, 1);
  });

  testWidgets('el shell ya no trae la barra de búsqueda', (tester) async {
    await tester.pumpWidget(
      _envolver(
        ChangeNotifierProvider<AuthController>.value(
          value: _AuthFalso(),
          child: ShellPage(
            rutaActual: '/',
            child: const Center(child: Text('contenido')),
          ),
        ),
      ),
    );

    expect(find.byType(CabeceraShell), findsOneWidget);
    expect(find.byType(BarraBusqueda), findsNothing);
    expect(find.text('Buscar...'), findsNothing);
  });

  testWidgets('el encabezado deja un margen inferior de 6 px', (tester) async {
    await tester.pumpWidget(
      _envolver(
        ChangeNotifierProvider<AuthController>.value(
          value: _AuthFalso(),
          child: ShellPage(
            rutaActual: '/',
            child: const Center(child: Text('contenido')),
          ),
        ),
      ),
    );

    final relleno = tester.widget<Padding>(
      find.descendant(
        of: find.byType(CabeceraShell),
        matching: find.byType(Padding),
      ).first,
    );

    expect(relleno.padding, const EdgeInsets.fromLTRB(20, 12, 20, 6));
  });

  testWidgets('la barra de búsqueda deja un margen inferior de 6 px', (
    tester,
  ) async {
    await tester.pumpWidget(
      _envolver(
        const Scaffold(
          body: Center(child: BarraBusqueda(onTap: _nada)),
        ),
      ),
    );

    final relleno = tester.widget<Padding>(
      find.descendant(
        of: find.byType(BarraBusqueda),
        matching: find.byType(Padding),
      ).first,
    );

    expect(relleno.padding, const EdgeInsets.only(bottom: 6));
  });
}

void _nada() {}
