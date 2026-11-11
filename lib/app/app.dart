import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/storage/session_storage.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/bienvenida_controller.dart';
import '../features/caja/data/caja_repository.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/inventario/data/inventario_repository.dart';
import '../features/pos/data/pos_repository.dart';
import 'escala_texto.dart';
import 'router.dart';
import 'theme.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    required this.almacen,
    required this.cliente,
    required this.repositorioAuth,
    required this.auth,
    required this.bienvenida,
    required this.repositorioDashboard,
    required this.repositorioCaja,
    required this.repositorioInventario,
    required this.repositorioPos,
  });

  final SessionStorage almacen;
  final ApiClient cliente;
  final AuthRepository repositorioAuth;
  final AuthController auth;
  final BienvenidaController bienvenida;
  final DashboardRepository repositorioDashboard;
  final CajaRepository repositorioCaja;
  final InventarioRepository repositorioInventario;
  final PosRepository repositorioPos;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = construirRouter(widget.auth, widget.bienvenida);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SessionStorage>.value(value: widget.almacen),
        Provider<ApiClient>.value(value: widget.cliente),
        Provider<AuthRepository>.value(value: widget.repositorioAuth),
        ChangeNotifierProvider<AuthController>.value(value: widget.auth),
        Provider<BienvenidaController>.value(value: widget.bienvenida),
        Provider<DashboardRepository>.value(value: widget.repositorioDashboard),
        Provider<CajaRepository>.value(value: widget.repositorioCaja),
        Provider<InventarioRepository>.value(
          value: widget.repositorioInventario,
        ),
        Provider<PosRepository>.value(value: widget.repositorioPos),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: papel,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: papel,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: MaterialApp.router(
          title: 'Pymes ERP',
          debugShowCheckedModeBanner: false,
          theme: construirTema(),
          routerConfig: _router,
          builder: (contexto, hijo) =>
              EscalaTexto(child: hijo ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
