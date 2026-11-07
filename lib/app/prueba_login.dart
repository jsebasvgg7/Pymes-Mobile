import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/storage/session_storage.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/models/usuario.dart';

class PruebaLogin extends StatefulWidget {
  const PruebaLogin({super.key});

  @override
  State<PruebaLogin> createState() => _PruebaLoginState();
}

class _PruebaLoginState extends State<PruebaLogin> {
  final SessionStorage _almacen = SessionStorage();
  late final ApiClient _cliente = ApiClient(almacen: _almacen);
  late final AuthRepository _repo = AuthRepository(
    cliente: _cliente,
    almacen: _almacen,
  );
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _clave = TextEditingController();
  String _resultado = 'Sin probar';
  bool _cargando = false;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  String _describir(Usuario u) {
    final roles = u.roles.map((r) => r.nombre).join(', ');
    return 'Usuario: ${u.username}\nEmpresa: ${u.empresaId}\n'
        'Roles: $roles\nAdmin: ${u.esAdmin}';
  }

  Future<void> _ejecutar(Future<String> Function() accion) async {
    setState(() {
      _cargando = true;
      _resultado = 'Llamando...';
    });
    String texto;
    try {
      texto = await accion();
    } catch (e) {
      texto = '$e';
    }
    if (!mounted) return;
    setState(() {
      _resultado = texto;
      _cargando = false;
    });
  }

  Future<void> _login() => _ejecutar(() async {
    final u = await _repo.login(
      email: _correo.text.trim(),
      password: _clave.text,
    );
    _clave.clear();
    return _describir(u);
  });

  Future<void> _restaurar() => _ejecutar(() async {
    final u = await _repo.restaurarSesion();
    return u == null ? 'Sin sesión guardada' : _describir(u);
  });

  Future<void> _cerrar() => _ejecutar(() async {
    await _repo.cerrarSesion();
    return 'Sesión cerrada';
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              TextField(
                controller: _correo,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _clave,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Clave'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _cargando ? null : _login,
                child: const Text('Iniciar sesión'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _cargando ? null : _restaurar,
                child: const Text('Restaurar sesión'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _cargando ? null : _cerrar,
                child: const Text('Cerrar sesión'),
              ),
              const SizedBox(height: 32),
              Text(_resultado, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
