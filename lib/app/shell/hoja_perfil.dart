import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../features/auth/data/models/usuario.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../theme.dart';
import 'avatar_usuario.dart';
import 'hoja_inferior.dart';

Future<void> mostrarHojaPerfil(BuildContext context, Usuario usuario) {
  final auth = context.read<AuthController>();
  final roles = usuario.roles.map((r) => r.nombre).join(', ');
  return mostrarHojaInferior<void>(
    context: context,
    builder: (hoja) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarUsuario(username: usuario.username, tamano: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      usuario.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: textoSecundario),
                    ),
                    if (roles.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        roles,
                        style: const TextStyle(
                          fontSize: 13,
                          color: textoSecundario,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(hoja).pop();
              auth.cerrarSesion();
            },
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
  );
}
