import 'package:flutter/material.dart';

class EtiquetaAdaptable extends StatelessWidget {
  const EtiquetaAdaptable({
    super.key,
    required this.completa,
    required this.corta,
    required this.estilo,
  });

  final String completa;
  final String corta;
  final TextStyle estilo;

  @override
  Widget build(BuildContext context) {
    final direccion = Directionality.of(context);
    final escala = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (contexto, restricciones) {
        final efectivo = DefaultTextStyle.of(contexto).style.merge(estilo);
        final medidor = TextPainter(
          text: TextSpan(text: completa, style: efectivo),
          maxLines: 1,
          textDirection: direccion,
          textScaler: escala,
        )..layout();
        final cabe = medidor.width <= restricciones.maxWidth;
        medidor.dispose();
        return Text(
          cabe ? completa : corta,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: estilo,
        );
      },
    );
  }
}
