import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/bienvenida_controller.dart';
import '../features/auth/presentation/bienvenida_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/registro_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import 'shell/shell_page.dart';

GoRouter construirRouter(AuthController auth, BienvenidaController bienvenida) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth,
    redirect: (context, state) {
      final ruta = state.matchedLocation;
      final enAcceso = ruta == '/login' || ruta == '/registro';
      if (auth.autenticado) {
        return enAcceso || ruta == '/bienvenida' ? '/' : null;
      }
      if (!bienvenida.vista) {
        return ruta == '/bienvenida' ? null : '/bienvenida';
      }
      return enAcceso ? null : '/login';
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            ShellPage(rutaActual: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/bienvenida',
        builder: (context, state) => const BienvenidaPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/registro',
        builder: (context, state) => const RegistroPage(),
      ),
    ],
  );
}
