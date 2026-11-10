import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pymes_erp_mobile/app/shell/barra_busqueda.dart';
import 'package:pymes_erp_mobile/app/theme.dart';
import 'package:pymes_erp_mobile/core/network/api_client.dart';
import 'package:pymes_erp_mobile/core/storage/session_storage.dart';
import 'package:pymes_erp_mobile/features/auth/data/auth_repository.dart';
import 'package:pymes_erp_mobile/features/auth/data/models/usuario.dart';
import 'package:pymes_erp_mobile/features/auth/presentation/auth_controller.dart';
import 'package:pymes_erp_mobile/features/dashboard/data/dashboard_repository.dart';
import 'package:pymes_erp_mobile/features/dashboard/data/models/dashboard_resumen.dart';
import 'package:pymes_erp_mobile/features/dashboard/data/models/ventas_hoy.dart';
import 'package:pymes_erp_mobile/features/dashboard/presentation/dashboard_page.dart';
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

class _RepoFalso implements DashboardRepository {
  @override
  Future<DashboardDatos> obtener(int empresaId) async => DashboardDatos(
    resumen: DashboardResumen(
      totalClientes: 8,
      totalProveedores: 1,
      totalProductos: 30,
      productosStockBajo: 3,
      productosSinStock: 1,
      totalCajas: 2,
      saldoTotalCajas: 900000,
      cajas: const [],
      fechaConsulta: DateTime(2026, 11, 10, 9),
    ),
    ventasHoy: const VentasHoy(cantidad: 2, total: 8000),
    flujo: const [],
    movimientos: const [],
  );
}

Widget _envolver(Widget hijo) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: _AuthFalso()),
      Provider<DashboardRepository>.value(value: _RepoFalso()),
    ],
    child: MaterialApp(theme: construirTema(), home: hijo),
  );
}

void main() {
  testWidgets('el dashboard muestra la barra de búsqueda', (tester) async {
    await tester.pumpWidget(_envolver(const DashboardPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(BarraBusqueda), findsOneWidget);
  });

  testWidgets('la barra de búsqueda se desplaza con el contenido', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_envolver(const DashboardPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(BarraBusqueda), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();

    expect(find.byType(BarraBusqueda), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pump();

    expect(find.byType(BarraBusqueda), findsOneWidget);
  });
}
