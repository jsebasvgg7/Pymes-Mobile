import 'package:flutter/material.dart';

const Color tintaPrincipal = Color(0xFF000000);
const Color papel = Color(0xFFFFFFFF);
const Color textoSecundario = Color(0xFF5C606A);
const Color linea = Color(0xFFE3E5E9);
const Color superficie = Color(0xFFF2F3F5);
const Color positivo = Color(0xFF15803D);
const Color atencion = Color(0xFFB45309);
const Color negativo = Color(0xFFB91C1C);

ThemeData construirTema() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: papel,
    colorScheme: const ColorScheme.light(
      primary: tintaPrincipal,
      onPrimary: papel,
      surface: papel,
      onSurface: tintaPrincipal,
      outline: linea,
    ),
    dividerColor: linea,
  );
}
