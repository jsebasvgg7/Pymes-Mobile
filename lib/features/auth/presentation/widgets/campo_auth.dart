import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class CampoAuth extends StatelessWidget {
  const CampoAuth({
    super.key,
    required this.controlador,
    required this.etiqueta,
    required this.icono,
    this.error,
    this.habilitado = true,
    this.tipoTeclado,
    this.accion = TextInputAction.next,
    this.pistas,
    this.ocultar,
    this.alAlternarVisibilidad,
    this.alCambiar,
    this.alEnviar,
  });

  final TextEditingController controlador;
  final String etiqueta;
  final IconData icono;
  final String? error;
  final bool habilitado;
  final TextInputType? tipoTeclado;
  final TextInputAction accion;
  final Iterable<String>? pistas;
  final bool? ocultar;
  final VoidCallback? alAlternarVisibilidad;
  final VoidCallback? alCambiar;
  final VoidCallback? alEnviar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final oculto = ocultar ?? false;

    OutlineInputBorder borde(Color color, double ancho) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: ancho),
    );

    return TextField(
      controller: controlador,
      enabled: habilitado,
      obscureText: oculto,
      keyboardType: tipoTeclado,
      textInputAction: accion,
      autofillHints: pistas,
      onChanged: (_) => alCambiar?.call(),
      onSubmitted: (_) => alEnviar?.call(),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: etiqueta,
        hintStyle: const TextStyle(color: textoSecundario, fontSize: 14),
        errorStyle: const TextStyle(fontSize: 12),
        errorText: error,
        filled: true,
        fillColor: superficie,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        prefixIcon: Icon(icono, color: textoSecundario, size: 20),
        suffixIcon: alAlternarVisibilidad == null
            ? null
            : IconButton(
                tooltip: oculto ? 'Mostrar' : 'Ocultar',
                icon: Icon(
                  oculto
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: textoSecundario,
                  size: 20,
                ),
                onPressed: alAlternarVisibilidad,
              ),
        border: borde(superficie, 0),
        enabledBorder: borde(superficie, 0),
        disabledBorder: borde(superficie, 0),
        focusedBorder: borde(tintaPrincipal, 1.2),
        errorBorder: borde(esquema.error, 1.2),
        focusedErrorBorder: borde(esquema.error, 1.5),
      ),
    );
  }
}
