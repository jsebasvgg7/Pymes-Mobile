import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/theme.dart';
import '../../../../core/format/fecha.dart';
import '../../../../core/format/moneda.dart';
import '../../data/models/movimiento_caja.dart';

class ListaMovimientos extends StatelessWidget {
  const ListaMovimientos({
    super.key,
    required this.movimientos,
    this.cargandoMas = false,
    this.hayMas = false,
    this.onCargarMas,
  });

  final List<MovimientoCaja> movimientos;
  final bool cargandoMas;
  final bool hayMas;
  final VoidCallback? onCargarMas;

  @override
  Widget build(BuildContext context) {
    if (movimientos.isEmpty) {
      return const _Vacio();
    }
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movimientos.length,
          separatorBuilder: (context, indice) =>
              const Divider(height: 1, color: linea),
          itemBuilder: (context, indice) {
            return _FilaMovimiento(movimiento: movimientos[indice]);
          },
        ),
        if (hayMas || cargandoMas)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextButton(
              onPressed: cargandoMas ? null : onCargarMas,
              child: cargandoMas
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ver más'),
            ),
          ),
      ],
    );
  }
}

class _FilaMovimiento extends StatelessWidget {
  const _FilaMovimiento({required this.movimiento});

  final MovimientoCaja movimiento;

  @override
  Widget build(BuildContext context) {
    final esIngreso = movimiento.esIngreso;
    final signo = esIngreso ? '+' : '-';
    final fecha = movimiento.fecha;
    final etiquetaFecha = fecha == null
        ? ''
        : etiquetaMovimiento(fecha, DateTime.now());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: esIngreso ? positivo.withValues(alpha: 0.1) : superficie,
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: esIngreso
                  ? HugeIcons.strokeRoundedArrowDownLeft01
                  : HugeIcons.strokeRoundedArrowUpRight01,
              color: esIngreso ? positivo : tintaPrincipal,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movimiento.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (movimiento.formaPagoNombre.isNotEmpty)
                      movimiento.formaPagoNombre,
                    if (etiquetaFecha.isNotEmpty) etiquetaFecha,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: textoSecundario),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$signo${formatearMoneda(movimiento.monto)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: esIngreso ? positivo : tintaPrincipal,
            ),
          ),
        ],
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: superficie,
              shape: BoxShape.circle,
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedFile02,
              color: textoSecundario,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sin movimientos',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Aún no hay movimientos en esta caja.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: textoSecundario),
          ),
        ],
      ),
    );
  }
}
