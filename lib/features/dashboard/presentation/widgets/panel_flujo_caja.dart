import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/format/moneda.dart';
import '../../data/models/flujo_dia.dart';
import 'grafica_barras.dart';
import 'panel_dashboard.dart';

class PanelFlujoCaja extends StatelessWidget {
  const PanelFlujoCaja({
    super.key,
    required this.saldoTotal,
    required this.totalCajas,
    required this.serie,
    required this.periodo,
    required this.alCambiarPeriodo,
  });

  final num saldoTotal;
  final int totalCajas;
  final List<PuntoFlujo>? serie;
  final PeriodoFlujo periodo;
  final ValueChanged<PeriodoFlujo> alCambiarPeriodo;

  @override
  Widget build(BuildContext context) {
    final datos = serie;
    return TarjetaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Saldo en cajas',
                  style: TextStyle(fontSize: 12, color: textoSecundario),
                ),
              ),
              _SelectorPeriodo(
                periodo: periodo,
                alCambiar: alCambiarPeriodo,
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatearMoneda(saldoTotal),
              maxLines: 1,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            totalCajas == 1 ? '1 caja' : '$totalCajas cajas',
            style: const TextStyle(fontSize: 12, color: textoSecundario),
          ),
          const SizedBox(height: 16),
          if (datos == null)
            const _Mensaje('No disponible')
          else if (_sinMovimientos(datos))
            const _Mensaje('Sin movimientos en este período.')
          else
            GraficaBarras(key: ValueKey(periodo), puntos: datos),
          if (datos != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Leyenda(
                    color: colorIngreso,
                    etiqueta: 'Ingresos',
                    valor: totalIngresosSerie(datos),
                  ),
                ),
                Expanded(
                  child: _Leyenda(
                    color: colorEgreso,
                    etiqueta: 'Egresos',
                    valor: totalEgresosSerie(datos),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _sinMovimientos(List<PuntoFlujo> datos) {
    return datos.every((p) => p.ingreso <= 0 && p.egreso <= 0);
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Center(
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: textoSecundario),
        ),
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  const _Leyenda({
    required this.color,
    required this.etiqueta,
    required this.valor,
  });

  final Color color;
  final String etiqueta;
  final num valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: const TextStyle(fontSize: 12, color: textoSecundario),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatearMoneda(valor),
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectorPeriodo extends StatelessWidget {
  const _SelectorPeriodo({required this.periodo, required this.alCambiar});

  final PeriodoFlujo periodo;
  final ValueChanged<PeriodoFlujo> alCambiar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: superficie,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segmento(
            texto: 'Diario',
            activo: periodo == PeriodoFlujo.diario,
            alTocar: () => alCambiar(PeriodoFlujo.diario),
          ),
          _Segmento(
            texto: 'Semanal',
            activo: periodo == PeriodoFlujo.semanal,
            alTocar: () => alCambiar(PeriodoFlujo.semanal),
          ),
        ],
      ),
    );
  }
}

class _Segmento extends StatelessWidget {
  const _Segmento({
    required this.texto,
    required this.activo,
    required this.alTocar,
  });

  final String texto;
  final bool activo;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: activo,
      label: texto,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: alTocar,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: activo ? tintaPrincipal : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: activo ? papel : textoSecundario,
            ),
          ),
        ),
      ),
    );
  }
}
