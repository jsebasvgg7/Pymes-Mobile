import 'package:flutter/material.dart';

import '../theme.dart';

class AvatarUsuario extends StatelessWidget {
  const AvatarUsuario({super.key, required this.username, this.tamano = 44});

  final String username;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final limpio = username.trim();
    final inicial = limpio.isEmpty
        ? '?'
        : String.fromCharCode(limpio.runes.first).toUpperCase();
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: superficie,
        shape: BoxShape.circle,
        border: Border.all(color: linea),
      ),
      child: Text(
        inicial,
        style: TextStyle(
          fontSize: tamano * 0.38,
          fontWeight: FontWeight.w700,
          color: tintaPrincipal,
        ),
      ),
    );
  }
}
