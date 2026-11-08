import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../features/auth/presentation/auth_controller.dart';
import 'theme.dart';

class InicioTemporal extends StatelessWidget {
  const InicioTemporal({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final usuario = auth.usuario;
    if (usuario == null) return const SizedBox.shrink();

    final roles = usuario.roles.map((r) => r.nombre).join(', ');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido, ${usuario.username}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                usuario.email,
                style: const TextStyle(color: textoSecundario),
              ),
              const SizedBox(height: 4),
              Text(
                'Empresa ${usuario.empresaId}'
                '${roles.isEmpty ? '' : ' · $roles'}',
                style: const TextStyle(color: textoSecundario),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: auth.cerrarSesion,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedLogout01,
                  color: tintaPrincipal,
                  size: 20,
                ),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: linea),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
