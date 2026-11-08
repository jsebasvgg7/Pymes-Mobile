import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class TarjetaIndicador extends StatelessWidget {
  const TarjetaIndicador({
    super.key,
    required this.titulo,
    required this.valor,
    this.detalle,
    this.atenuado = false,
  });

  final String titulo;
  final String valor;
  final String? detalle;
  final bool atenuado;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: papel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: linea),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.25,
              color: textoSecundario,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              maxLines: 1,
              style: TextStyle(
                fontSize: atenuado ? 15 : 22,
                fontWeight: atenuado ? FontWeight.w600 : FontWeight.w700,
                color: atenuado ? textoSecundario : tintaPrincipal,
              ),
            ),
          ),
          if (detalle != null) ...[
            const SizedBox(height: 4),
            Text(
              detalle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: textoSecundario),
            ),
          ],
        ],
      ),
    );
  }
}
