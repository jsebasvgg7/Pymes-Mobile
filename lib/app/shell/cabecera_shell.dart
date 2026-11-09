import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../features/auth/data/models/usuario.dart';
import '../navegacion/recortar_nombre.dart';
import '../theme.dart';
import 'avatar_usuario.dart';
import 'hoja_administracion.dart';
import 'hoja_perfil.dart';

const List<String> _meses = [
  'Ene',
  'Feb',
  'Mar',
  'Abr',
  'May',
  'Jun',
  'Jul',
  'Ago',
  'Sep',
  'Oct',
  'Nov',
  'Dic',
];

String etiquetaHoy(DateTime ahora) {
  final dia = ahora.day.toString().padLeft(2, '0');
  return 'Hoy $dia ${_meses[ahora.month - 1]}';
}

class CabeceraShell extends StatelessWidget {
  const CabeceraShell({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
              child: AvatarUsuario(username: usuario.username, fondo: papel),
            ),
          ),
        ],
      ),
    );
  }
}

class BarraBusqueda extends StatelessWidget {
  const BarraBusqueda({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Material(
        color: papel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: linea),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: const SizedBox(
            height: 48,
            child: Row(
              children: [
                SizedBox(width: 16),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  color: textoSecundario,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Buscar...',
                  style: TextStyle(fontSize: 15, color: textoSecundario),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
