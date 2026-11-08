import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import 'bienvenida_controller.dart';

class BienvenidaPage extends StatelessWidget {
  const BienvenidaPage({super.key});

  Future<void> _continuar(BuildContext context, String ruta) async {
    await context.read<BienvenidaController>().marcarVista();
    if (context.mounted) context.go(ruta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          tintaPrincipal,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset('assets/icon/icon_foreground.png'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Image.asset(
                    'assets/images/hero-illustration.png',
                    height: 240,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tu negocio, más simple',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gestiona tu punto de venta, inventario y pagos desde un solo lugar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textoSecundario,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () => _continuar(context, '/login'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Inicia sesión',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _continuar(context, '/registro'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: tintaPrincipal,
                      side: const BorderSide(color: linea),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
