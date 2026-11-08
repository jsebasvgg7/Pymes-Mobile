import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../navegacion/busqueda_destinos.dart';
import '../navegacion/destino.dart';
import '../navegacion/destinos.dart';
import '../theme.dart';
import 'fila_destino.dart';

class BuscadorPage extends StatefulWidget {
  const BuscadorPage({super.key, required this.alElegir});

  final ValueChanged<Destino> alElegir;

  @override
  State<BuscadorPage> createState() => _BuscadorPageState();
}

class _BuscadorPageState extends State<BuscadorPage> {
  final TextEditingController _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultados = buscarDestinos(destinos, _controlador.text);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Volver',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      color: tintaPrincipal,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controlador,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: const TextStyle(color: textoSecundario),
                        filled: true,
                        fillColor: superficie,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        prefixIcon: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedSearch01,
                              color: textoSecundario,
                              size: 20,
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: resultados.isEmpty
                  ? const Center(
                      child: Text(
                        'Sin resultados',
                        style: TextStyle(color: textoSecundario),
                      ),
                    )
                  : ListView(
                      children: [
                        for (final destino in resultados)
                          FilaDestino(
                            destino: destino,
                            alTocar: () {
                              Navigator.of(context).pop();
                              widget.alElegir(destino);
                            },
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
