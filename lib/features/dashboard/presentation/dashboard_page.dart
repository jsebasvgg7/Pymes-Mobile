import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../core/format/moneda.dart';
import '../../../core/widgets/estado_carga.dart';
import '../../../core/widgets/estado_error.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/dashboard_repository.dart';
import '../data/models/dashboard_resumen.dart';
import 'dashboard_controller.dart';
import 'widgets/panel_cajas.dart';
import 'widgets/panel_ingresos_egresos.dart';
import 'widgets/panel_stock.dart';
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

String formatearHora(DateTime fecha) {
  final hora = fecha.hour.toString().padLeft(2, '0');
  final minuto = fecha.minute.toString().padLeft(2, '0');
  return '$hora:$minuto';
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
    final tarjetas = <Widget>[
      TarjetaIndicador(
        titulo: 'Saldo total en cajas',
        valor: formatearMoneda(resumen.saldoTotalCajas),
      ),
      if (ventas != null)
        TarjetaIndicador(
          titulo: 'Ventas de hoy',
          valor: formatearMoneda(ventas.total),
          detalle: ventas.cantidad == 1 ? '1 venta' : '${ventas.cantidad} ventas',
        )
      else
        const TarjetaIndicador(
          titulo: 'Ventas de hoy',
          valor: 'No disponible',
          atenuado: true,
        ),
      TarjetaIndicador(
        titulo: 'Stock bajo',
        valor: '${resumen.productosStockBajo}',
        detalle: resumen.productosSinStock > 0
            ? '${resumen.productosSinStock} sin stock'
            : null,
      ),
      TarjetaIndicador(
        titulo: 'Clientes registrados',
        valor: '${resumen.totalClientes}',
      ),
      TarjetaIndicador(
        titulo: 'Productos registrados',
        valor: '${resumen.totalProductos}',
      ),
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      children: [
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: tarjetas.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => tarjetas[i],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: PanelCajas(cajas: resumen.cajas),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: PanelIngresosEgresos(
            ingresos: resumen.totalIngresos,
            egresos: resumen.totalEgresos,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: PanelStock(
            stockBajo: resumen.productosStockBajo,
            sinStock: resumen.productosSinStock,
          ),
        ),
        if (actualizado != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
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
