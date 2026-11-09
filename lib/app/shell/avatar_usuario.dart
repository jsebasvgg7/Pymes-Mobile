import 'package:flutter/material.dart';

import '../theme.dart';
import 'patron_avatar.dart';

class AvatarUsuario extends StatelessWidget {
  const AvatarUsuario({
    super.key,
    required this.username,
    this.semilla,
    this.tamano = 44,
    this.fondo = superficie,
  });

  final String username;
  final String? semilla;
  final double tamano;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    final propia = semilla?.trim() ?? '';
    final base = propia.isNotEmpty ? propia : username.trim();
    return Semantics(
      label: 'Avatar de ${username.trim()}',
      excludeSemantics: true,
      child: Container(
        width: tamano,
        height: tamano,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fondo,
          shape: BoxShape.circle,
          border: Border.all(color: linea),
        ),
        child: base.isEmpty
            ? Text(
                '?',
                style: TextStyle(
                  fontSize: tamano * 0.38,
                  fontWeight: FontWeight.w700,
                  color: tintaPrincipal,
                ),
              )
            : CustomPaint(
                size: Size.square(tamano),
                painter: _PintorAvatar(patronAvatar(base)),
              ),
      ),
    );
  }
}

class _PintorAvatar extends CustomPainter {
  _PintorAvatar(this.patron);

  final List<List<int>> patron;

  @override
  void paint(Canvas canvas, Size size) {
    final lado = size.width * 0.68;
    final origen = (size.width - lado) / 2;
    final celda = lado / patron.length;
    final tinta = Paint()..color = tintaPrincipal;
    final gris = Paint()..color = textoSecundario.withValues(alpha: 0.45);
    for (var f = 0; f < patron.length; f++) {
      for (var c = 0; c < patron[f].length; c++) {
        final valor = patron[f][c];
        if (valor == 0) continue;
        canvas.drawCircle(
          Offset(origen + celda * (c + 0.5), origen + celda * (f + 0.5)),
          celda * 0.4,
          valor == 1 ? tinta : gris,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PintorAvatar anterior) => true;
}
