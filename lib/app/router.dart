import 'package:go_router/go_router.dart';

import 'prueba_login.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const PruebaLogin()),
  ],
);
