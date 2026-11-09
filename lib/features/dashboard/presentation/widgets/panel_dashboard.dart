import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class PanelDashboard extends StatelessWidget {
  const PanelDashboard({
    super.key,
    required this.titulo,
    required this.hijos,
    this.destacado,
  });

  final String titulo;
  final List<Widget> hijos;
  final String? destacado;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: papel,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: tintaPrincipal.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (destacado != null)
                Text(
                  destacado!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...hijos,
        ],
      ),
    );
  }
}

class FilaPanel extends StatelessWidget {
  const FilaPanel({super.key, required this.etiqueta, required this.valor});

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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: textoSecundario),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            valor,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
