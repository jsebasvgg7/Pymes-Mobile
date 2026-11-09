import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class TarjetaPanel extends StatelessWidget {
  const TarjetaPanel({super.key, required this.child});

  final Widget child;

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
      child: child,
    );
  }
}

class PanelDashboard extends StatelessWidget {
  const PanelDashboard({
    super.key,
    required this.titulo,
    required this.hijos,
    this.accion,
  });

  final String titulo;
  final List<Widget> hijos;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return TarjetaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (accion != null) accion!,
            ],
          ),
          const SizedBox(height: 12),
          ...hijos,
        ],
      ),
    );
  }
}
