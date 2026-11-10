import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme.dart';

class BarraBusqueda extends StatelessWidget {
  const BarraBusqueda({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: papel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: linea),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: const SizedBox(
            height: 48,
            child: Row(
              children: [
                SizedBox(width: 16),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  color: textoSecundario,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Buscar...',
                  style: TextStyle(fontSize: 15, color: textoSecundario),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
