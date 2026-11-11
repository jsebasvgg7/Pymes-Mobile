import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/estado_carga.dart';
import '../../../core/widgets/estado_error.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/caja_repository.dart';
import 'caja_controller.dart';
import 'widgets/aviso_caja.dart';
import 'widgets/pildora_estado_caja.dart';
import 'widgets/selector_cajas.dart';
import 'widgets/tarjeta_resumen_caja.dart';

class CajaPage extends StatelessWidget {
  const CajaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.read<AuthController>().usuario;
    if (usuario == null) return const SizedBox.shrink();
    return ChangeNotifierProvider<CajaController>(
      create: (contexto) => CajaController(
        repositorio: contexto.read<CajaRepository>(),
        empresaId: usuario.empresaId,
      )..cargar(),
      child: const _VistaCaja(),
    );
  }
}

class _VistaCaja extends StatelessWidget {
  const _VistaCaja();

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<CajaController>();

    switch (controlador.estado) {
      case EstadoPantallaCaja.cargando:
        return const EstadoCarga(mensaje: 'Cuadrando cajas');
      case EstadoPantallaCaja.error:
        return EstadoError(
          mensaje: controlador.error ?? 'No pudimos cargar la caja.',
          alReintentar: controlador.cargar,
        );
      case EstadoPantallaCaja.listo:
        return RefreshIndicator(
          color: tintaPrincipal,
          backgroundColor: papel,
          onRefresh: () => _refrescar(context, controlador),
          child: _Contenido(controlador: controlador),
        );
    }
  }

  Future<void> _refrescar(
    BuildContext context,
    CajaController controlador,
  ) async {
    final mensajero = ScaffoldMessenger.of(context);
    final exito = await controlador.refrescar();
    if (exito) return;
    mensajero
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            controlador.error ?? 'No pudimos actualizar.',
            style: const TextStyle(color: papel),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: tintaPrincipal,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.controlador});

  final CajaController controlador;

  @override
  Widget build(BuildContext context) {
    final caja = controlador.seleccionada;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        _Cabecera(caja: caja),
        if (caja == null)
          const _SinCajas()
        else ...[
          const SizedBox(height: 16),
          SelectorCajas(
            cajas: controlador.cajas,
            seleccionadaId: controlador.seleccionadaId,
            alElegir: controlador.seleccionarCaja,
          ),
          const SizedBox(height: 16),
          TarjetaResumenCaja(
            caja: caja,
            ultimoCierre: controlador.ultimoCierre,
          ),
          if (controlador.cierrePendiente) ...[
            const SizedBox(height: 12),
            const AvisoCaja(
              titulo: 'Cierre pendiente',
              mensaje:
                  'El cierre de ayer quedó pendiente. Revisa la caja y '
                  'ciérrala para cuadrar el día.',
              color: atencion,
              resaltado: true,
            ),
          ],
          if (!controlador.abierta) ...[
            const SizedBox(height: 12),
            const AvisoCaja(
              titulo: 'Sin caja abierta',
              mensaje:
                  'Abre la caja para vender en el POS y registrar '
                  'movimientos.',
              color: atencion,
            ),
          ],
        ],
      ],
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.caja});

  final CajaVista? caja;

  @override
  Widget build(BuildContext context) {
    final cajaActual = caja;
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Caja',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        if (cajaActual != null)
          PildoraEstadoCaja(
            abierta: cajaActual.abierta,
            cierrePendiente: cajaActual.cierrePendiente,
          ),
      ],
    );
  }
}

class _SinCajas extends StatelessWidget {
  const _SinCajas();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: papel,
              shape: BoxShape.circle,
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedWallet01,
              color: textoSecundario,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin cajas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Aún no hay cajas registradas en esta empresa.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: textoSecundario,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
