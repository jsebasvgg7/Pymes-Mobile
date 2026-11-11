import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/theme.dart';
import '../../../../core/format/fecha.dart';
import '../../../../core/format/moneda.dart';
import '../../data/models/apertura_caja.dart';
import '../../data/models/resumen_caja.dart';
import '../caja_controller.dart';
import 'tarjeta_caja.dart';

class TarjetaResumenCaja extends StatelessWidget {
  const TarjetaResumenCaja({super.key, required this.caja, this.ultimoCierre});

  final CajaVista caja;
  final AperturaCaja? ultimoCierre;

  @override
  Widget build(BuildContext context) {
    return TarjetaCaja(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Saldo actual',
                  style: TextStyle(fontSize: 14, color: textoSecundario),
                ),
              ),
              if (!caja.abierta)
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: superficie,
                    shape: BoxShape.circle,
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedLock,
                    color: textoSecundario,
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            formatearMoneda(caja.resumen.saldoActual),
            maxLines: 1,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: linea),
          const SizedBox(height: 16),
          if (caja.abierta)
            _DetalleAbierto(resumen: caja.resumen)
          else
            _DetalleCerrado(cierre: ultimoCierre),
        ],
      ),
    );
  }
}

class _DetalleAbierto extends StatelessWidget {
  const _DetalleAbierto({required this.resumen});

  final ResumenCaja resumen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MovimientoResumen(
                icono: HugeIcons.strokeRoundedArrowDownLeft01,
                titulo: 'Ingresos',
                monto: resumen.totalIngresos,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MovimientoResumen(
                icono: HugeIcons.strokeRoundedArrowUpRight01,
                titulo: 'Egresos',
                monto: resumen.totalEgresos,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Histórico de la caja · ${_conMiles(resumen.totalMovimientos)} '
          '${resumen.totalMovimientos == 1 ? 'movimiento' : 'movimientos'}',
          style: const TextStyle(fontSize: 12, color: textoSecundario),
        ),
      ],
    );
  }
}

class _MovimientoResumen extends StatelessWidget {
  const _MovimientoResumen({
    required this.icono,
    required this.titulo,
    required this.monto,
  });

  final List<List<dynamic>> icono;
  final String titulo;
  final num monto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: superficie,
            shape: BoxShape.circle,
          ),
          child: HugeIcon(icon: icono, color: tintaPrincipal, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                maxLines: 1,
                style: const TextStyle(fontSize: 12, color: textoSecundario),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatearMoneda(monto),
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 14,
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

class _DetalleCerrado extends StatelessWidget {
  const _DetalleCerrado({required this.cierre});

  final AperturaCaja? cierre;

  @override
  Widget build(BuildContext context) {
    final fecha = cierre?.fechaCierre;
    final diferencia = cierre?.diferencia;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Último cierre',
                style: TextStyle(fontSize: 12, color: textoSecundario),
              ),
              const SizedBox(height: 4),
              Text(
                fecha == null
                    ? 'Sin cierres registrados'
                    : formatearFechaYHora12(fecha),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: fecha == null ? FontWeight.w400 : FontWeight.w600,
                  color: fecha == null ? textoSecundario : tintaPrincipal,
                ),
              ),
            ],
          ),
        ),
        if (diferencia != null) ...[
          const SizedBox(width: 12),
          _EtiquetaDiferencia(diferencia: diferencia),
        ],
      ],
    );
  }
}

class _EtiquetaDiferencia extends StatelessWidget {
  const _EtiquetaDiferencia({required this.diferencia});

  final num diferencia;

  @override
  Widget build(BuildContext context) {
    final cuadrada = diferencia == 0;
    final color = cuadrada
        ? textoSecundario
        : (diferencia < 0 ? negativo : positivo);
    final texto = cuadrada
        ? 'Cuadrada'
        : '${diferencia < 0 ? 'Faltante' : 'Sobrante'} '
              '${formatearMoneda(diferencia.abs())}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

String _conMiles(int valor) {
  final digitos = valor.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digitos[i]);
  }
  return '${valor < 0 ? '-' : ''}$buffer';
}
