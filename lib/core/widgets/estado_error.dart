import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../app/theme.dart';

class EstadoError extends StatelessWidget {
  const EstadoError({
    super.key,
    required this.mensaje,
    required this.alReintentar,
  });

  final String mensaje;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 7),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: papel,
                  shape: BoxShape.circle,
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedAlertCircle,
                  color: textoSecundario,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: textoSecundario,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: alReintentar,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(160, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        const Spacer(flex: 13),
      ],
    );
  }
}
