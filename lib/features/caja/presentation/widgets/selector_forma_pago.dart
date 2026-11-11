import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/theme.dart';
import '../../data/models/forma_pago_caja.dart';

List<List<dynamic>> iconoFormaPago(TipoFormaPagoCaja tipo) {
  switch (tipo) {
    case TipoFormaPagoCaja.efectivo:
      return HugeIcons.strokeRoundedMoney03;
    case TipoFormaPagoCaja.tarjeta:
      return HugeIcons.strokeRoundedCreditCard;
    case TipoFormaPagoCaja.transferencia:
      return HugeIcons.strokeRoundedBank;
    case TipoFormaPagoCaja.credito:
    case TipoFormaPagoCaja.otro:
      return HugeIcons.strokeRoundedWallet01;
  }
}

class SelectorFormaPago extends StatelessWidget {
  const SelectorFormaPago({
    super.key,
    required this.formas,
    required this.seleccionadaId,
    required this.alSeleccionar,
  });

  final List<FormaPagoCaja> formas;
  final int? seleccionadaId;
  final ValueChanged<int> alSeleccionar;

  static const double _separacion = 8;
  static const double _tamanoIcono = 18;
  static const double _relleno = 12;
  static const TextStyle _estilo = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  double _anchoNecesario(BuildContext context) {
    final base = DefaultTextStyle.of(context).style.merge(_estilo);
    final direccion = Directionality.of(context);
    final escala = MediaQuery.textScalerOf(context);
    var mayor = 0.0;
    for (final forma in formas) {
      final medidor = TextPainter(
        text: TextSpan(text: forma.nombre, style: base),
        maxLines: 1,
        textDirection: direccion,
        textScaler: escala,
      )..layout();
      mayor = math.max(mayor, medidor.width);
      medidor.dispose();
    }
    return mayor + _tamanoIcono + _separacion + _relleno * 2;
  }

  @override
  Widget build(BuildContext context) {
    if (formas.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (contexto, restricciones) {
        if (formas.length <= 3) {
          final cantidad = formas.length;
          final disponible =
              (restricciones.maxWidth - _separacion * (cantidad - 1)) /
              cantidad;
          final soloIcono = disponible < _anchoNecesario(contexto);
          return Row(
            children: [
              for (var i = 0; i < cantidad; i++) ...[
                if (i > 0) const SizedBox(width: _separacion),
                Expanded(
                  child: _OpcionPago(
                    forma: formas[i],
                    seleccionada: formas[i].id == seleccionadaId,
                    soloIcono: soloIcono,
                    alTocar: () => alSeleccionar(formas[i].id),
                  ),
                ),
              ],
            ],
          );
        }
        return Wrap(
          spacing: _separacion,
          runSpacing: _separacion,
          children: [
            for (final forma in formas)
              _OpcionPago(
                forma: forma,
                seleccionada: forma.id == seleccionadaId,
                soloIcono: false,
                ajustada: true,
                alTocar: () => alSeleccionar(forma.id),
              ),
          ],
        );
      },
    );
  }
}

class _OpcionPago extends StatelessWidget {
  const _OpcionPago({
    required this.forma,
    required this.seleccionada,
    required this.soloIcono,
    required this.alTocar,
    this.ajustada = false,
  });

  final FormaPagoCaja forma;
  final bool seleccionada;
  final bool soloIcono;
  final bool ajustada;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final color = seleccionada ? tintaPrincipal : textoSecundario;
    final contenido = Row(
      mainAxisSize: ajustada ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HugeIcon(
          icon: iconoFormaPago(forma.tipo),
          color: color,
          size: SelectorFormaPago._tamanoIcono,
        ),
        if (!soloIcono) ...[
          const SizedBox(width: SelectorFormaPago._separacion),
          Flexible(
            child: Text(
              forma.nombre,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: SelectorFormaPago._estilo.copyWith(
                color: color,
                fontWeight: seleccionada ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
    final opcion = Semantics(
      button: true,
      selected: seleccionada,
      label: forma.nombre,
      excludeSemantics: true,
      child: Material(
        color: seleccionada
            ? tintaPrincipal.withValues(alpha: 0.1)
            : superficie,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: seleccionada ? tintaPrincipal : linea,
            width: 1.2,
          ),
        ),
        child: InkWell(
          onTap: alTocar,
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SelectorFormaPago._relleno,
              ),
              child: contenido,
            ),
          ),
        ),
      ),
    );
    if (!soloIcono) return opcion;
    return Tooltip(message: forma.nombre, child: opcion);
  }
}
