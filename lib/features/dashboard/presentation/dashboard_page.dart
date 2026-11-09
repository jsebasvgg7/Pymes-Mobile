import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../../app/navegacion/abrir_destino.dart';
import '../../../app/navegacion/destinos.dart';
import '../../../app/theme.dart';
import '../../../core/format/fecha.dart';
import '../../../core/format/moneda.dart';
import '../../../core/widgets/estado_carga.dart';
import '../../../core/widgets/estado_error.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/dashboard_repository.dart';
import '../data/models/dashboard_resumen.dart';
import 'dashboard_controller.dart';
import 'widgets/panel_flujo_caja.dart';
import 'widgets/panel_movimientos.dart';
import 'widgets/tarjeta_indicador.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.read<AuthController>().usuario;
    if (usuario == null) return const SizedBox.shrink();
    return ChangeNotifierProvider<DashboardController>(
      create: (contexto) => DashboardController(
        repositorio: contexto.read<DashboardRepository>(),
        empresaId: usuario.empresaId,
      )..cargar(),
      child: const _VistaDashboard(),
    );
  }
}

class _VistaDashboard extends StatelessWidget {
  const _VistaDashboard();

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<DashboardController>();
    final resumen = controlador.resumen;

    switch (controlador.estado) {
      case EstadoDashboard.cargando:
        return const EstadoCarga();
      case EstadoDashboard.error:
        return EstadoError(
          mensaje: controlador.error ?? 'No pudimos cargar el resumen.',
          alReintentar: controlador.cargar,
        );
      case EstadoDashboard.listo:
        if (resumen == null) return const EstadoCarga();
        return RefreshIndicator(
          color: tintaPrincipal,
          backgroundColor: papel,
          onRefresh: () => _refrescar(context, controlador),
          child: _Contenido(controlador: controlador, resumen: resumen),
        );
    }
  }

  Future<void> _refrescar(
    BuildContext context,
    DashboardController controlador,
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
  const _Contenido({required this.controlador, required this.resumen});

  final DashboardController controlador;
  final DashboardResumen resumen;

  @override
  Widget build(BuildContext context) {
    final ventas = controlador.ventasHoy;
    final actualizado = controlador.actualizadoEn;

    void ir(String id) {
      final destino = destinoPorId(id);
      if (destino != null) abrirDestino(context, destino);
    }

    final tarjetas = <Widget>[
      if (ventas != null)
        TarjetaIndicador(
          icono: HugeIcons.strokeRoundedMoney03,
          titulo: 'Ventas de hoy',
          valor: formatearMoneda(ventas.total),
          detalle: ventas.cantidad == 1 ? '1 venta' : '${ventas.cantidad} ventas',
          destacada: true,
          alTocar: () => ir('pos'),
        )
      else
        TarjetaIndicador(
          icono: HugeIcons.strokeRoundedMoney03,
          titulo: 'Ventas de hoy',
          valor: 'No disponible',
          destacada: true,
          atenuado: true,
          alTocar: () => ir('pos'),
        ),
      TarjetaIndicador(
        icono: HugeIcons.strokeRoundedAlert02,
        titulo: 'Stock bajo',
        valor: '${resumen.productosStockBajo}',
        detalle: resumen.productosSinStock > 0
            ? '${resumen.productosSinStock} sin stock'
            : null,
        alTocar: () => ir('inventario'),
      ),
      TarjetaIndicador(
        icono: HugeIcons.strokeRoundedUserGroup,
        titulo: 'Clientes',
        valor: '${resumen.totalClientes}',
        alTocar: () => ir('clientes'),
      ),
      TarjetaIndicador(
        icono: HugeIcons.strokeRoundedPackage,
        titulo: 'Productos',
        valor: '${resumen.totalProductos}',
        alTocar: () => ir('productos'),
      ),
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Row(
          children: [
            Expanded(child: tarjetas[0]),
            const SizedBox(width: 12),
            Expanded(child: tarjetas[1]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: tarjetas[2]),
            const SizedBox(width: 12),
            Expanded(child: tarjetas[3]),
          ],
        ),
        const SizedBox(height: 24),
        PanelFlujoCaja(
          saldoTotal: resumen.saldoTotalCajas,
          totalCajas: resumen.totalCajas,
          serie: controlador.serieFlujo,
          periodo: controlador.periodoFlujo,
          alCambiarPeriodo: controlador.cambiarPeriodo,
        ),
        const SizedBox(height: 16),
        PanelMovimientos(
          movimientos: controlador.movimientos,
          alVerTodo: () => ir('caja'),
        ),
        if (actualizado != null)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              'Actualizado a las ${formatearHora(actualizado)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: textoSecundario),
            ),
          ),
      ],
    );
  }
}
