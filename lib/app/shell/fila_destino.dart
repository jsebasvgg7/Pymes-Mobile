import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../navegacion/destino.dart';
import '../theme.dart';

class FilaDestino extends StatelessWidget {
  const FilaDestino({super.key, required this.destino, required this.alTocar});

  final Destino destino;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: alTocar,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: superficie,
                borderRadius: BorderRadius.circular(12),
              ),
              child: HugeIcon(
                icon: destino.icono,
                color: tintaPrincipal,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                destino.nombre,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (!destino.disponible)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: superficie,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Próximamente',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textoSecundario,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GrupoLista {
  const GrupoLista(this.etiqueta, this.destinos);

  final String? etiqueta;
  final List<Destino> destinos;
}

class ListaDestinos extends StatelessWidget {
  const ListaDestinos({
    super.key,
    required this.titulo,
    required this.grupos,
    required this.alElegir,
  });

  final String titulo;
  final List<GrupoLista> grupos;
  final ValueChanged<Destino> alElegir;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final grupo in grupos) ...[
              if (grupo.etiqueta != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Text(
                    grupo.etiqueta!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textoSecundario,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              for (final destino in grupo.destinos)
                FilaDestino(
                  destino: destino,
                  alTocar: () => alElegir(destino),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
