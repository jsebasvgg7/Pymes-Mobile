import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';

class CargaMarca extends StatefulWidget {
  const CargaMarca({
    super.key,
    this.tamano = 96,
    this.color = tintaPrincipal,
    this.colorBanda = textoSecundario,
    this.conBarrido = true,
  });

  final double tamano;
  final Color color;
  final Color colorBanda;
  final bool conBarrido;

  @override
  State<CargaMarca> createState() => _CargaMarcaState();
}

class _CargaMarcaState extends State<CargaMarca>
    with SingleTickerProviderStateMixin {
  static const Duration _duracion = Duration(milliseconds: 1700);

  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: _duracion,
  )..repeat();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.tamano,
      height: widget.tamano,
      child: AnimatedBuilder(
        animation: _controlador,
        builder: (context, _) {
          final t = _controlador.value;
          final pulso = 0.5 - 0.5 * math.cos(t * 2 * math.pi);
          final recorrido = (t - 0.5) * 3.2;
          final colores = widget.conBarrido
              ? [
                  widget.color,
                  widget.color,
                  widget.colorBanda,
                  widget.colorBanda,
                  widget.color,
                  widget.color,
                ]
              : [widget.color, widget.color];
          final paradas = widget.conBarrido
              ? const [0.0, 0.38, 0.46, 0.54, 0.62, 1.0]
              : const [0.0, 1.0];
          return Transform.scale(
            scale: 0.98 + 0.02 * pulso,
            child: Opacity(
              opacity: widget.conBarrido ? 1 : 0.45 + 0.55 * pulso,
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment(-1 + recorrido, -1 + recorrido),
                  end: Alignment(1 + recorrido, 1 + recorrido),
                  colors: colores,
                  stops: paradas,
                ).createShader(rect),
                child: Image.asset(
                  'assets/icon/icon_marca.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
