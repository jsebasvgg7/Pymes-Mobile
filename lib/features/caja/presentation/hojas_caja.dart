import 'package:flutter/material.dart';

import '../../../core/format/fecha.dart';
import '../../../core/format/moneda.dart';
import '../../../app/theme.dart';
import '../data/models/cierre_caja_resultado.dart';
import '../presentation/caja_controller.dart';
import 'monto_caja.dart';
import 'widgets/campo_monto_caja.dart';

String _fechaCorta(DateTime fecha) {
  return '${fecha.day.toString().padLeft(2, '0')} '
      '${mesesCortos[fecha.month - 1]} ${fecha.year}';
}

String _hora12(DateTime fecha) {
  final hora = fecha.hour % 12 == 0 ? 12 : fecha.hour % 12;
  final minuto = fecha.minute.toString().padLeft(2, '0');
  final sufijo = fecha.hour < 12 ? 'a. m.' : 'p. m.';
  return '$hora:$minuto $sufijo';
}

bool _mismoDia(DateTime? a, DateTime b) {
  if (a == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

List<num> _opcionesRapidas(num? sugerido) {
  final base = (sugerido != null && sugerido > 0) ? sugerido.round() : 100000;
  final valores = <num>{0, base, base * 2, base * 5};
  return valores.toList()..sort();
}

Future<bool> mostrarAbrirCaja(
  BuildContext contextoPagina,
  CajaController controlador,
  CajaVista caja,
) async {
  final ahora = DateTime.now();

  late final TextEditingController controladorMonto;
  num? monto;
  final opciones = _opcionesRapidas(caja.estado?.efectivoSugerido);
  bool enviando = false;

  controladorMonto = TextEditingController(text: textoMontoCaja(monto ?? 0));

  void seleccionarOpcion(num valor) {
    monto = valor;
    controladorMonto.text = textoMontoCaja(valor);
    controladorMonto.selection = TextSelection.collapsed(
      offset: controladorMonto.text.length,
    );
  }

  final resultado = await showModalBottomSheet<bool>(
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
          Future<void> confirmar() async {
            final valor = montoDesdeTexto(controladorMonto.text);
            if (valor == null || enviando) return;
            enviando = true;
            estadoHoja(() {});

            final ok = await controlador.abrirCaja(valor);

            if (!contextoHoja.mounted) return;
            if (ok) {
              Navigator.of(contextoHoja).pop(true);
              if (contextoPagina.mounted) {
                ScaffoldMessenger.of(contextoPagina).showSnackBar(
                  const SnackBar(
                    content: Text('Caja abierta'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              return;
            }

            enviando = false;
            final esConflicto = controlador.codigoErrorAccion == 409;
            final mensaje =
                controlador.errorAccion ??
                'No se pudo abrir la caja. Intenta de nuevo.';

            if (esConflicto) {
              Navigator.of(contextoHoja).pop(false);
              await controlador.refrescar();
              if (contextoPagina.mounted) {
                ScaffoldMessenger.of(contextoPagina).showSnackBar(
                  SnackBar(
                    content: Text(mensaje),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
              return;
            }

            estadoHoja(() {});
            if (contextoPagina.mounted) {
              ScaffoldMessenger.of(contextoPagina).showSnackBar(
                SnackBar(
                  content: Text(mensaje),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
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
                  'Abrir caja',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: tintaPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${caja.nombre} · ${_fechaCorta(ahora)}',
                  style: const TextStyle(fontSize: 14, color: textoSecundario),
                ),
                const SizedBox(height: 24),
                const Text(
                  '¿Con cuánto dinero inicia la caja hoy?',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                CampoMontoCaja(
                  controlador: controladorMonto,
                  etiqueta: 'Efectivo inicial',
                  alCambiar: (texto) {
                    monto = montoDesdeTexto(texto);
                    estadoHoja(() {});
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Montos sugeridos',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textoSecundario,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: opciones.map((valor) {
                    final seleccionado =
                        monto != null &&
                        monto == valor &&
                        controladorMonto.text.isNotEmpty;
                    return ChoiceChip(
                      label: Text(
                        textoMontoCaja(valor),
                        style: TextStyle(
                          color: seleccionado
                              ? tintaPrincipal
                              : textoSecundario,
                          fontWeight: seleccionado
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      selected: seleccionado,
                      onSelected: (_) {
                        seleccionarOpcion(valor);
                        estadoHoja(() {});
                      },
                      selectedColor: tintaPrincipal.withValues(alpha: 0.1),
                      backgroundColor: superficie,
                      side: BorderSide(
                        color: seleccionado ? tintaPrincipal : linea,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                      padding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Solo efectivo. Tarjetas y transferencias se llevan a otros medios.',
                  style: TextStyle(fontSize: 12, color: textoSecundario),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: enviando
                            ? null
                            : () => Navigator.pop(contextoHoja, false),
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
                        onPressed: enviando || monto == null ? null : confirmar,
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
                            : const Text('Abrir caja'),
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

  return resultado == true;
}

Future<CierreCajaResultado?> mostrarCerrarCaja(
  BuildContext contextoPagina,
  CajaController controlador,
  CajaVista caja,
) async {
  final apertura = caja.estado?.apertura;
  final ahora = DateTime.now();
  final messenger = ScaffoldMessenger.of(contextoPagina);

  late final TextEditingController controladorMonto;
  num? monto;
  bool enviando = false;

  controladorMonto = TextEditingController();

  Future<void> confirmar() async {
    final valor = montoDesdeTexto(controladorMonto.text);
    if (valor == null || enviando) return;
    enviando = true;

    final resultado = await controlador.cerrarCaja(valor);

    if (resultado != null) {
      if (contextoPagina.mounted) {
        Navigator.of(contextoPagina).pop(resultado);
      }
      return;
    }

    enviando = false;
    final esConflicto = controlador.codigoErrorAccion == 409;
    final mensaje =
        controlador.errorAccion ??
        'No se pudo cerrar la caja. Intenta de nuevo.';

    if (esConflicto) {
      if (contextoPagina.mounted) {
        Navigator.of(contextoPagina).pop(null);
        await controlador.refrescar();
      }
      messenger.showSnackBar(
        SnackBar(content: Text(mensaje), duration: const Duration(seconds: 4)),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 4)),
    );
  }

  final resultado = await showModalBottomSheet<CierreCajaResultado?>(
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
                Text(
                  'Cerrar caja',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: tintaPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${caja.nombre} · ${apertura != null && _mismoDia(apertura.fechaApertura, ahora) ? 'Apertura de hoy' : 'Apertura del ${_fechaCorta(apertura?.fechaApertura ?? ahora)}'}',
                  style: const TextStyle(fontSize: 14, color: textoSecundario),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Cuenta el efectivo que hay en la caja.',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: superficie,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: textoSecundario,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Solo se cuenta el efectivo físico. '
                          'Tarjetas y transferencias no entran en este conteo.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: textoSecundario,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CampoMontoCaja(
                  controlador: controladorMonto,
                  etiqueta: 'Efectivo contado',
                  autofoco: true,
                  alCambiar: (texto) {
                    monto = montoDesdeTexto(texto);
                    estadoHoja(() {});
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Puedes escribir el monto o usar los valores rápidos.',
                  style: TextStyle(fontSize: 12, color: textoSecundario),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: enviando
                            ? null
                            : () => Navigator.pop(contextoHoja, null),
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
                        onPressed: enviando || monto == null ? null : confirmar,
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
                            : const Text('Confirmar cierre'),
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

  return resultado;
}

class _DialogoCierreCaja extends StatefulWidget {
  const _DialogoCierreCaja({
    required this.controlador,
    required this.resultado,
  });

  final CajaController controlador;
  final CierreCajaResultado resultado;

  @override
  State<_DialogoCierreCaja> createState() => _DialogoCierreCajaState();
}

class _DialogoCierreCajaState extends State<_DialogoCierreCaja> {
  bool reabriendo = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final apertura = widget.resultado.apertura;
    final fecha = apertura.fechaCierre ?? DateTime.now();
    final diferencia = apertura.diferencia ?? 0;
    final esFaltante = diferencia < 0;
    final esSobrante = diferencia > 0;

    Color colorDiferencia;
    String etiquetaDiferencia;
    if (esFaltante) {
      colorDiferencia = negativo;
      etiquetaDiferencia = 'Faltante';
    } else if (esSobrante) {
      colorDiferencia = positivo;
      etiquetaDiferencia = 'Sobrante';
    } else {
      colorDiferencia = tintaPrincipal;
      etiquetaDiferencia = 'Cuadrada';
    }

    String montoDiferencia;
    if (esFaltante) {
      montoDiferencia = '-${formatearMoneda(diferencia.abs())}';
    } else if (esSobrante) {
      montoDiferencia = '+${formatearMoneda(diferencia)}';
    } else {
      montoDiferencia = formatearMoneda(0);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: positivo.withValues(alpha: 0.1),
                  child: Icon(Icons.check_circle, size: 56, color: positivo),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Caja cerrada',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: tintaPrincipal,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  '${apertura.cajaNombre} · ${_fechaCorta(fecha)} ${_hora12(fecha)}',
                  style: const TextStyle(fontSize: 14, color: textoSecundario),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _FilaResultado(
                'Efectivo inicial',
                formatearMoneda(apertura.efectivoInicial),
              ),
              _FilaResultado(
                'Efectivo esperado',
                formatearMoneda(apertura.efectivoEsperado ?? 0),
              ),
              _FilaResultado(
                'Efectivo contado',
                formatearMoneda(apertura.efectivoContado ?? 0),
              ),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          etiquetaDiferencia,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colorDiferencia,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Contado menos esperado',
                          style: const TextStyle(
                            fontSize: 12,
                            color: textoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    montoDiferencia,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colorDiferencia,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: superficie,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Otros medios · solo informativo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _FilaResultado(
                      'Ingresos otros medios',
                      formatearMoneda(widget.resultado.ingresosOtrosMedios),
                    ),
                    _FilaResultado(
                      'Egresos otros medios',
                      '-${formatearMoneda(widget.resultado.egresosOtrosMedios)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    error!,
                    style: const TextStyle(fontSize: 13, color: negativo),
                  ),
                ),
              Row(
                children: [
                  if (widget.controlador.puedeReabrir)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: reabriendo ? null : _reabrir,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tintaPrincipal,
                          side: const BorderSide(color: linea),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: reabriendo
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: tintaPrincipal,
                                ),
                              )
                            : const Text('Reabrir cierre'),
                      ),
                    ),
                  if (widget.controlador.puedeReabrir)
                    const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: tintaPrincipal,
                        foregroundColor: papel,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Listo'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _reabrir() async {
    setState(() {
      reabriendo = true;
      error = null;
    });

    final ok = await widget.controlador.reabrirCaja();

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      reabriendo = false;
      error =
          widget.controlador.errorAccion ??
          'No se pudo reabrir la caja. Intenta de nuevo.';
    });
  }
}

class _FilaResultado extends StatelessWidget {
  const _FilaResultado(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              etiqueta,
              style: const TextStyle(fontSize: 14, color: textoSecundario),
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: tintaPrincipal,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> mostrarResultadoCierre(
  BuildContext contextoPagina,
  CajaController controlador,
  CierreCajaResultado resultado,
) async {
  final messenger = ScaffoldMessenger.of(contextoPagina);
  await showDialog<void>(
    context: contextoPagina,
    barrierDismissible: false,
    builder: (contexto) =>
        _DialogoCierreCaja(controlador: controlador, resultado: resultado),
  );
  if (contextoPagina.mounted) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Caja cerrada'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
