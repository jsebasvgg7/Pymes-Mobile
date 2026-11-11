import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme.dart';
import '../monto_caja.dart';

class CampoMontoCaja extends StatefulWidget {
  const CampoMontoCaja({
    super.key,
    required this.controlador,
    required this.etiqueta,
    this.simboloMoneda = r'$',
    this.moneda = 'COP',
    this.habilitado = true,
    this.autofoco = true,
    this.alCambiar,
  });

  final TextEditingController controlador;
  final String etiqueta;
  final String simboloMoneda;
  final String moneda;
  final bool habilitado;
  final bool autofoco;
  final void Function(String)? alCambiar;

  @override
  State<CampoMontoCaja> createState() => _CampoMontoCajaState();
}

class _CampoMontoCajaState extends State<CampoMontoCaja> {
  bool get _valorValido => montoDesdeTexto(widget.controlador.text) != null;

  @override
  void initState() {
    super.initState();
    if (widget.autofoco) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.controlador.selection = TextSelection.collapsed(
            offset: widget.controlador.text.length,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.etiqueta,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textoSecundario,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: widget.habilitado ? papel : superficie,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.habilitado ? linea : const Color(0xFFD7D9DE),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                widget.simboloMoneda,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: tintaPrincipal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: widget.controlador,
                  enabled: widget.habilitado,
                  autofocus: widget.autofoco,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(12),
                    FormatoMiles(),
                  ],
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: tintaPrincipal,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: widget.alCambiar,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.moneda,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textoSecundario,
                ),
              ),
            ],
          ),
        ),
        if (!_valorValido && widget.controlador.text.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 2),
            child: Text(
              'Monto no válido',
              style: TextStyle(fontSize: 11, color: negativo),
            ),
          ),
      ],
    );
  }
}
