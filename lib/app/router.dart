import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/registro_page.dart';
import 'inicio_temporal.dart';

GoRouter construirRouter(AuthController auth) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth,
    redirect: (context, state) {
      final enAcceso =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/registro';
      if (!auth.autenticado) return enAcceso ? null : '/login';
      return enAcceso ? '/' : null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const InicioTemporal()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/registro',
        builder: (context, state) => const RegistroPage(),
      ),
    ],
  );
}
