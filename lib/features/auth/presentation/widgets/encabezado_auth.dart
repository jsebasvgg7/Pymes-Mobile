import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';

enum PestanaAuth { login, registro }

class EncabezadoAuth extends StatelessWidget {
  const EncabezadoAuth({
    super.key,
    required this.pestana,
    required this.titulo,
    required this.subtitulo,
  });

  final PestanaAuth pestana;
  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SizedBox(
            width: 84,
            height: 84,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                tintaPrincipal,
                BlendMode.srcIn,
              ),
              child: Image.asset('assets/icon/icon_foreground.png'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: textoSecundario,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        _Pestanas(pestana: pestana),
      ],
    );
  }
}

class _Pestanas extends StatelessWidget {
  const _Pestanas({required this.pestana});

  final PestanaAuth pestana;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: superficie,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _Pestana(
            texto: 'Inicia sesión',
            activa: pestana == PestanaAuth.login,
            alTocar: () => context.go('/login'),
          ),
          _Pestana(
            texto: 'Crea tu cuenta',
            activa: pestana == PestanaAuth.registro,
            alTocar: () => context.go('/registro'),
          ),
        ],
      ),
    );
  }
}

class _Pestana extends StatelessWidget {
  const _Pestana({
    required this.texto,
    required this.activa,
    required this.alTocar,
  });

  final String texto;
  final bool activa;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: activa ? null : alTocar,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: activa ? papel : superficie,
            borderRadius: BorderRadius.circular(12),
            boxShadow: activa
                ? [
                    BoxShadow(
                      color: tintaPrincipal.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : const [],
          ),
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: activa ? tintaPrincipal : textoSecundario,
            ),
          ),
        ),
      ),
    );
  }
}
