import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/storage/session_storage.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/bienvenida_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  late final AuthController auth;
  final almacen = SessionStorage();
  final cliente = ApiClient(
    almacen: almacen,
    alSesionExpirada: () => auth.sesionExpirada(),
  );
  final repositorioAuth = AuthRepository(cliente: cliente, almacen: almacen);
  auth = AuthController(repositorio: repositorioAuth);
  await auth.restaurar();
  final bienvenida = BienvenidaController(almacen: almacen);
  await bienvenida.cargar();

  runApp(
    App(
      almacen: almacen,
      cliente: cliente,
      repositorioAuth: repositorioAuth,
      auth: auth,
      bienvenida: bienvenida,
    ),
  );
}
