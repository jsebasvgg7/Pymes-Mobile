import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import 'caja_controller.dart';
import 'monto_caja.dart';
import 'widgets/campo_monto_caja.dart';

Future<void> mostrarCrearCaja(
  BuildContext contextoPagina,
  CajaController controlador,
) async {
  final messenger = ScaffoldMessenger.of(contextoPagina);
  final controladorNombre = TextEditingController();
  final controladorMonto = TextEditingController();
  bool enviando = false;
  String? error;

  await showModalBottomSheet<void>(
    context: contextoPagina,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: papel,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (contextoHoja) {
      return StatefulBuilder(
        builder: (contexto, estadoHoja) {
          Future<void> guardar() async {
            final nombre = controladorNombre.text;
            if (nombre.trim().isEmpty) {
              error = 'Ingresa el nombre de la caja.';
              estadoHoja(() {});
              return;
            }
            final montoTexto = controladorMonto.text.trim();
            num? saldoInicial;
            if (montoTexto.isNotEmpty) {
              saldoInicial = montoDesdeTexto(controladorMonto.text);
              if (saldoInicial == null) {
                error = 'Monto no válido.';
                estadoHoja(() {});
                return;
              }
            }
            enviando = true;
            error = null;
            estadoHoja(() {});

            final ok = await controlador.crearCaja(
              nombre,
              saldoInicial: saldoInicial,
            );

            if (!contextoHoja.mounted) return;
            if (ok) {
              Navigator.of(contextoHoja).pop();
              if (contextoPagina.mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Caja creada'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              return;
            }

            enviando = false;
            error = controlador.errorAccion ?? 'No se pudo crear la caja.';
            estadoHoja(() {});
          }

          return Padding(
            padding:
                MediaQuery.of(contexto).viewInsets +
                const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7D9DE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nueva caja',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: tintaPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Solo en estado vacío. Se crea para esta empresa.',
                  style: TextStyle(fontSize: 13, color: textoSecundario),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nombre de la caja',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textoSecundario,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controladorNombre,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: superficie,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: linea),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: linea),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: tintaPrincipal),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CampoMontoCaja(
                  controlador: controladorMonto,
                  etiqueta: 'Saldo inicial (opcional)',
                  autofoco: false,
                  alCambiar: (_) => estadoHoja(() {}),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error!,
                    style: const TextStyle(fontSize: 13, color: negativo),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: enviando
                            ? null
                            : () => Navigator.pop(contextoHoja),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tintaPrincipal,
                          side: const BorderSide(color: linea),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: enviando ? null : guardar,
                        style: FilledButton.styleFrom(
                          backgroundColor: tintaPrincipal,
                          foregroundColor: papel,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: enviando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: papel,
                                ),
                              )
                            : const Text('Crear'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
