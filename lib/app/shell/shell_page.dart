import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../navegacion/abrir_destino.dart';
import '../navegacion/destino.dart';
import '../navegacion/destinos.dart';
import 'barra_inferior.dart';
import 'buscador_page.dart';
import 'cabecera_shell.dart';
import 'menu_mas.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({super.key, required this.rutaActual, required this.child});

  final String rutaActual;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthController>().usuario;
    if (usuario == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CabeceraShell(usuario: usuario),
            BarraBusqueda(onTap: () => _abrirBuscador(context)),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: BarraInferior(
        destinos: destinosDe(GrupoDestino.barra),
        activoId: destinoPorRuta(rutaActual)?.id,
        alTocarDestino: (destino) => abrirDestino(context, destino),
        alTocarMas: () => mostrarMenuMas(context),
      ),
    );
  }

  void _abrirBuscador(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            BuscadorPage(alElegir: (destino) => abrirDestino(context, destino)),
      ),
    );
  }
}
