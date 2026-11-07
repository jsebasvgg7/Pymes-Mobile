import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_page.dart';
import 'inicio_temporal.dart';

GoRouter construirRouter(AuthController auth) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth,
    redirect: (context, state) {
      final enLogin = state.matchedLocation == '/login';
      if (!auth.autenticado) return enLogin ? null : '/login';
      return enLogin ? '/' : null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const InicioTemporal()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    ],
  );
}
