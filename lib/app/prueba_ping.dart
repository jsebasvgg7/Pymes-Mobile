import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/storage/session_storage.dart';

class PruebaPing extends StatefulWidget {
  const PruebaPing({super.key});

  @override
  State<PruebaPing> createState() => _PruebaPingState();
}

class _PruebaPingState extends State<PruebaPing> {
  late final ApiClient _cliente = ApiClient(almacen: SessionStorage());
  String _resultado = 'Sin probar';
  bool _cargando = false;

  Future<void> _probar() async {
    setState(() {
      _cargando = true;
      _resultado = 'Llamando...';
    });
    final reloj = Stopwatch()..start();
    try {
      final datos = await _cliente.get('/api/ping');
      reloj.stop();
      setState(() => _resultado = '$datos\n${reloj.elapsedMilliseconds} ms');
    } catch (e) {
      reloj.stop();
      setState(() => _resultado = '$e\n${reloj.elapsedMilliseconds} ms');
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_resultado, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _cargando ? null : _probar,
                child: const Text('Probar /api/ping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
