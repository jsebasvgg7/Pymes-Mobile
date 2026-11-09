import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/format/moneda.dart';
import '../../data/models/flujo_dia.dart';

const Color colorIngreso = tintaPrincipal;
final Color colorEgreso = textoSecundario.withValues(alpha: 0.45);

class GraficaBarras extends StatefulWidget {
  const GraficaBarras({super.key, required this.puntos});

  final List<PuntoFlujo> puntos;

  @override
  State<GraficaBarras> createState() => _EstadoGraficaBarras();
}

class _EstadoGraficaBarras extends State<GraficaBarras> {
  static const double _altoTooltip = 44;
  static const double _altoBarras = 92;
  static const double _altoEtiquetas = 24;
  static const double _altoMinimo = 6;
  static const double _altoVacio = 4;

  int? _seleccion;

  @override
  Widget build(BuildContext context) {
    final puntos = widget.puntos;
    num maximo = 0;
    for (final p in puntos) {
      if (p.ingreso > maximo) maximo = p.ingreso;
      if (p.egreso > maximo) maximo = p.egreso;
    }
    final escala = maximo > 0 ? _altoBarras / maximo : 0.0;
    final anchoBarra = puntos.length <= 4 ? 16.0 : 10.0;

    return SizedBox(
      height: _altoTooltip + _altoBarras + _altoEtiquetas,
      child: Stack(
        children: [
          Row(
            children: [
              for (var i = 0; i < puntos.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() {
                      _seleccion = _seleccion == i ? null : i;
                    }),
                    child: _Columna(
                      punto: puntos[i],
                      escala: escala.toDouble(),
                      anchoBarra: anchoBarra,
                      seleccionada: _seleccion == i,
                      atenuada: _seleccion != null && _seleccion != i,
                    ),
                  ),
                ),
            ],
          ),
          if (_seleccion != null)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: _altoTooltip,
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment(
                    (2 * (_seleccion! + 0.5) / puntos.length) - 1,
                    -1,
                  ),
                  child: _Tooltip(punto: puntos[_seleccion!]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Columna extends StatelessWidget {
  const _Columna({
    required this.punto,
    required this.escala,
    required this.anchoBarra,
    required this.seleccionada,
    required this.atenuada,
  });

  final PuntoFlujo punto;
  final double escala;
  final double anchoBarra;
  final bool seleccionada;
  final bool atenuada;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: _EstadoGraficaBarras._altoTooltip),
        SizedBox(
          height: _EstadoGraficaBarras._altoBarras,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Barra(
                alto: _alto(punto.ingreso),
                ancho: anchoBarra,
                color: _color(colorIngreso, punto.ingreso),
              ),
              const SizedBox(width: 3),
              _Barra(
                alto: _alto(punto.egreso),
                ancho: anchoBarra,
                color: _color(colorEgreso, punto.egreso),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _EstadoGraficaBarras._altoEtiquetas,
          child: Center(
            child: Text(
              punto.etiqueta,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                fontWeight: seleccionada ? FontWeight.w600 : FontWeight.w400,
                color: seleccionada ? tintaPrincipal : textoSecundario,
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _alto(num valor) {
    if (valor <= 0) return _EstadoGraficaBarras._altoVacio;
    final alto = valor * escala;
    return alto < _EstadoGraficaBarras._altoMinimo
        ? _EstadoGraficaBarras._altoMinimo
        : alto.toDouble();
  }

  Color _color(Color base, num valor) {
    if (valor <= 0) return superficie;
    return atenuada ? base.withValues(alpha: base.a * 0.35) : base;
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.alto, required this.ancho, required this.color});

  final double alto;
  final double ancho;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: ancho,
      height: alto,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ancho / 2),
      ),
    );
  }
}

class _Tooltip extends StatelessWidget {
  const _Tooltip({required this.punto});

  final PuntoFlujo punto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tintaPrincipal,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingresos ${formatearMoneda(punto.ingreso)}',
            style: const TextStyle(fontSize: 12, height: 1.2, color: papel),
          ),
          Text(
            'Egresos ${formatearMoneda(punto.egreso)}',
            style: TextStyle(
              fontSize: 12,
              height: 1.2,
              color: papel.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
