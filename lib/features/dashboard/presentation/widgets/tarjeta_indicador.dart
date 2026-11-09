import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/theme.dart';

class TarjetaIndicador extends StatelessWidget {
  const TarjetaIndicador({
    super.key,
    required this.icono,
    required this.titulo,
    required this.valor,
    this.detalle,
    this.destacada = false,
    this.atenuado = false,
    this.alTocar,
  });

  final List<List<dynamic>> icono;
  final String titulo;
  final String valor;
  final String? detalle;
  final bool destacada;
  final bool atenuado;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final fondo = destacada ? tintaPrincipal : papel;
    final tinta = destacada ? papel : tintaPrincipal;
    final tenue = destacada ? papel.withValues(alpha: 0.7) : textoSecundario;
    final circulo = destacada ? papel.withValues(alpha: 0.14) : superficie;

    return Semantics(
      button: alTocar != null,
      label: '$titulo: $valor',
      excludeSemantics: true,
      child: Container(
        height: 136,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: tintaPrincipal.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: fondo,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: alTocar,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: circulo,
                          shape: BoxShape.circle,
                        ),
                        child: HugeIcon(icon: icono, color: tinta, size: 16),
                      ),
                      const Spacer(),
                      if (alTocar != null)
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowUpRight01,
                          color: tenue,
                          size: 16,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: tenue),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      valor,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: atenuado ? 13 : 20,
                        fontWeight: FontWeight.w600,
                        color: atenuado ? tenue : tinta,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 16,
                    child: Text(
                      detalle ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: tenue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
