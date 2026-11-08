import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/storage/session_storage.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/bienvenida_controller.dart';
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
  });

  final SessionStorage almacen;
  final ApiClient cliente;
  final AuthRepository repositorioAuth;
  final AuthController auth;
  final BienvenidaController bienvenida;

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
      ],
      child: MaterialApp.router(
        title: 'Pymes ERP',
        debugShowCheckedModeBanner: false,
        theme: construirTema(),
        routerConfig: _router,
      ),
    );
  }
}
