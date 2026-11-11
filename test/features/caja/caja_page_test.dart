import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:pymes_erp_mobile/app/theme.dart';
import 'package:pymes_erp_mobile/core/network/api_client.dart';
import 'package:pymes_erp_mobile/core/network/api_exception.dart';
import 'package:pymes_erp_mobile/core/storage/session_storage.dart';
import 'package:pymes_erp_mobile/features/auth/data/auth_repository.dart';
import 'package:pymes_erp_mobile/features/auth/data/models/usuario.dart';
import 'package:pymes_erp_mobile/features/auth/presentation/auth_controller.dart';
import 'package:pymes_erp_mobile/features/caja/data/caja_repository.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/apertura_caja.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/estado_caja.dart';
import 'package:pymes_erp_mobile/features/caja/data/models/resumen_caja.dart';
import 'package:pymes_erp_mobile/features/caja/presentation/caja_page.dart';

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

class _RepoFalso extends CajaRepository {
  _RepoFalso({
    Future<List<ResumenCaja>> Function(int empresaId)? resumenesAccion,
    Future<List<EstadoCaja>> Function(int empresaId)? estadosAccion,
    Future<PaginaCierresCaja> Function(int cajaId)? cierresAccion,
  }) : resumenesAccion = resumenesAccion ?? ((_) async => const []),
       estadosAccion = estadosAccion ?? ((_) async => const []),
       cierresAccion =
           cierresAccion ?? ((_) async => const PaginaCierresCaja(items: [])),
       super(cliente: ApiClient(almacen: SessionStorage()));

  Future<List<ResumenCaja>> Function(int empresaId) resumenesAccion;
  Future<List<EstadoCaja>> Function(int empresaId) estadosAccion;
  Future<PaginaCierresCaja> Function(int cajaId) cierresAccion;

  @override
  Future<List<ResumenCaja>> resumenes(int empresaId) {
    return resumenesAccion(empresaId);
  }

  @override
  Future<List<EstadoCaja>> estados(int empresaId) {
    return estadosAccion(empresaId);
  }

  @override
  Future<PaginaCierresCaja> cierres(
    int cajaId, {
    int pagina = 0,
    int tamano = 1,
  }) {
    return cierresAccion(cajaId);
  }
}

ResumenCaja _resumen(
  int id,
  String nombre, {
  num saldo = 100000,
  num ingresos = 50000,
  num egresos = 20000,
  int movimientos = 3,
}) {
  return ResumenCaja(
    cajaId: id,
    cajaNombre: nombre,
    saldoInicial: 0,
    saldoActual: saldo,
    totalIngresos: ingresos,
    totalEgresos: egresos,
    totalMovimientos: movimientos,
  );
}

EstadoCaja _estado(
  int id,
  String nombre, {
  bool abierta = true,
  bool requiereCierre = false,
}) {
  return EstadoCaja(
    cajaId: id,
    cajaNombre: nombre,
    abierta: abierta,
    requiereCierre: requiereCierre,
    apertura: null,
    efectivoSugerido: null,
  );
}

AperturaCaja _cierre() {
  return AperturaCaja(
    id: 733,
    cajaId: 2,
    cajaNombre: 'Caja 2',
    estado: EstadoAperturaCaja.cerrada,
    usuarioAperturaId: null,
    usuarioAperturaNombre: null,
    fechaApertura: null,
    efectivoInicial: 0,
    usuarioCierreId: null,
    usuarioCierreNombre: null,
    fechaCierre: DateTime(2026, 11, 11, 15, 52),
    efectivoEsperado: 500000,
    efectivoContado: 484500,
    diferencia: -15500,
    tipoCierre: TipoCierreCaja.manual,
    resultado: ResultadoCierreCaja.faltante,
    requiereCierre: false,
  );
}

Widget _envolver(_RepoFalso repo) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: _AuthFalso()),
      Provider<CajaRepository>.value(value: repo),
    ],
    child: MaterialApp(
      theme: construirTema(),
      home: const Scaffold(body: CajaPage()),
    ),
  );
}

Future<void> _cargar(WidgetTester tester, _RepoFalso repo) async {
  await tester.pumpWidget(_envolver(repo));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('muestra la caja abierta con su resumen', (tester) async {
    final repo = _RepoFalso(
      resumenesAccion: (_) async => [
        _resumen(
          1,
          'Caja Principal',
          saldo: 59748038,
          ingresos: 524769008,
          egresos: 471020970,
          movimientos: 18805,
        ),
      ],
      estadosAccion: (_) async => [_estado(1, 'Caja Principal')],
    );

    await _cargar(tester, repo);

    expect(find.text('Caja'), findsOneWidget);
    expect(find.text('Caja Principal'), findsOneWidget);
    expect(find.text('Caja abierta'), findsOneWidget);
    expect(find.text(r'$ 59.748.038'), findsOneWidget);
    expect(find.text(r'$ 524.769.008'), findsOneWidget);
    expect(find.text(r'$ 471.020.970'), findsOneWidget);
    expect(find.textContaining('18.805 movimientos'), findsOneWidget);
    expect(find.text('Sin caja abierta'), findsNothing);
  });

  testWidgets('al elegir una caja cerrada muestra su ultimo cierre', (
    tester,
  ) async {
    final repo = _RepoFalso(
      resumenesAccion: (_) async => [
        _resumen(1, 'Caja Principal'),
        _resumen(2, 'Caja 2'),
      ],
      estadosAccion: (_) async => [
        _estado(1, 'Caja Principal'),
        _estado(2, 'Caja 2', abierta: false),
      ],
      cierresAccion: (_) async => PaginaCierresCaja(items: [_cierre()]),
    );
    await _cargar(tester, repo);

    await tester.tap(find.text('Caja 2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Caja cerrada'), findsOneWidget);
    expect(find.text('Sin caja abierta'), findsOneWidget);
    expect(find.text('11/11/2026 3:52 p. m.'), findsOneWidget);
    expect(find.text(r'Faltante $ 15.500'), findsOneWidget);
  });

  testWidgets('avisa cuando el cierre quedo pendiente', (tester) async {
    final repo = _RepoFalso(
      resumenesAccion: (_) async => [_resumen(1, 'Caja Principal')],
      estadosAccion: (_) async => [
        _estado(1, 'Caja Principal', requiereCierre: true),
      ],
    );

    await _cargar(tester, repo);

    expect(find.text('Cierre pendiente'), findsNWidgets(2));
    expect(find.textContaining('El cierre de ayer'), findsOneWidget);
  });

  testWidgets('sin cajas muestra el estado vacio', (tester) async {
    await _cargar(tester, _RepoFalso());

    expect(find.text('Sin cajas'), findsOneWidget);
    expect(
      find.text('Aún no hay cajas registradas en esta empresa.'),
      findsOneWidget,
    );
    expect(find.text('Caja abierta'), findsNothing);
  });

  testWidgets('si falla la carga muestra el error y permite reintentar', (
    tester,
  ) async {
    var falla = true;
    final repo = _RepoFalso(
      resumenesAccion: (_) async {
        if (falla) throw const ApiException('Sin conexión');
        return [_resumen(1, 'Caja Principal')];
      },
      estadosAccion: (_) async => [_estado(1, 'Caja Principal')],
    );

    await _cargar(tester, repo);

    expect(find.text('Sin conexión'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    falla = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Caja Principal'), findsOneWidget);
    expect(find.text('Caja abierta'), findsOneWidget);
  });
}
