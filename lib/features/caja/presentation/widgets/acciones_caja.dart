import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import 'etiqueta_adaptable.dart';

class AccionesCaja extends StatelessWidget {
  const AccionesCaja({
    super.key,
    required this.abierta,
    required this.puedeReabrir,
    required this.ocupado,
    required this.alAbrir,
    required this.alCerrar,
    this.alReabrir,
    this.alMovimiento,
  });

  final bool abierta;
  final bool puedeReabrir;
  final bool ocupado;
  final VoidCallback alAbrir;
  final VoidCallback alCerrar;
  final VoidCallback? alReabrir;
  final VoidCallback? alMovimiento;

  Widget _etiqueta(String texto, String? textoCorto) {
    const estilo = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
    if (textoCorto == null) {
      return Text(
        texto,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: estilo,
      );
    }
    return EtiquetaAdaptable(
      completa: texto,
      corta: textoCorto,
      estilo: estilo,
    );
  }

  Widget _botonFilled(
    BuildContext context,
    String texto,
    VoidCallback alPulsar, {
    String? textoCorto,
  }) {
    return FilledButton(
      onPressed: ocupado ? null : alPulsar,
      style: FilledButton.styleFrom(
        backgroundColor: tintaPrincipal,
        foregroundColor: papel,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: _etiqueta(texto, textoCorto),
    );
  }

  Widget _botonOutlined(
    BuildContext context,
    String texto,
    VoidCallback alPulsar, {
    String? textoCorto,
  }) {
    return OutlinedButton(
      onPressed: ocupado ? null : alPulsar,
      style: OutlinedButton.styleFrom(
        foregroundColor: tintaPrincipal,
        side: const BorderSide(color: linea),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: _etiqueta(texto, textoCorto),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (abierta) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _botonFilled(
                  context,
                  'Nuevo movimiento',
                  alMovimiento ?? alCerrar,
                  textoCorto: 'Nuevo mov.',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _botonOutlined(context, 'Cerrar caja', alCerrar)),
            ],
          ),
        ],
      );
    }
    if (puedeReabrir) {
      return Row(
        children: [
          Expanded(child: _botonFilled(context, 'Abrir caja', alAbrir)),
          const SizedBox(width: 12),
          Expanded(
            child: _botonOutlined(
              context,
              'Reabrir cierre',
              alReabrir ?? alAbrir,
              textoCorto: 'Reabrir',
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_botonFilled(context, 'Abrir caja', alAbrir)],
    );
  }
}
