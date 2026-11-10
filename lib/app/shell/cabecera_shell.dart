import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/format/fecha.dart';
import '../../features/auth/data/models/usuario.dart';
import '../navegacion/recortar_nombre.dart';
import '../theme.dart';
import 'avatar_usuario.dart';
import 'hoja_administracion.dart';
import 'hoja_perfil.dart';

String etiquetaHoy(DateTime ahora) {
  final dia = ahora.day.toString().padLeft(2, '0');
  return 'Hoy $dia ${mesCorto(ahora.month)}';
}

class CabeceraShell extends StatelessWidget {
  const CabeceraShell({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Administración',
            child: Material(
              color: papel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: linea),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => mostrarHojaAdministracion(context),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedDashboardSquare01,
                      color: tintaPrincipal,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Bienvenido, ${recortarNombre(usuario.username)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                Text(
                  etiquetaHoy(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 13,
                    color: textoSecundario,
                    letterSpacing: -0.1,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Perfil',
            child: GestureDetector(
              onTap: () => mostrarHojaPerfil(context, usuario),
              child: AvatarUsuario(
                username: usuario.username,
                semilla: usuario.email,
                fondo: papel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
