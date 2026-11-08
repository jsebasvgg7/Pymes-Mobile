import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import 'auth_controller.dart';
import 'widgets/campo_auth.dart';
import 'widgets/encabezado_auth.dart';
import 'widgets/marca_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static final RegExp _formatoCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final TextEditingController _correo = TextEditingController();
  final TextEditingController _clave = TextEditingController();
  bool _verClave = false;
  bool _recordar = false;
  String? _errorCorreo;
  String? _errorClave;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>();
    final correo = auth.correoRecordado;
    final clave = auth.claveRecordada;
    if (correo != null && clave != null) {
      _correo.text = correo;
      _clave.text = clave;
      _recordar = true;
    }
  }

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final correo = _correo.text.trim();
    final clave = _clave.text;

    final errorCorreo = correo.isEmpty
        ? 'Escribe tu correo.'
        : (_formatoCorreo.hasMatch(correo)
              ? null
              : 'Escribe un correo con formato válido.');
    final errorClave = clave.isEmpty ? 'Escribe tu contraseña.' : null;

    setState(() {
      _errorCorreo = errorCorreo;
      _errorClave = errorClave;
    });
    if (errorCorreo != null || errorClave != null) return;

    FocusScope.of(context).unfocus();
    await context.read<AuthController>().login(
      email: correo,
      password: clave,
      recordar: _recordar,
    );
  }

  void _alEditar(bool esCorreo) {
    setState(() {
      if (esCorreo) {
        _errorCorreo = null;
      } else {
        _errorClave = null;
      }
    });
    context.read<AuthController>().limpiarErrores();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const MarcaAuth(),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const EncabezadoAuth(
                              titulo: 'Inicia sesión',
                              subtitulo: 'Ingresa con tu correo y contraseña.',
                            ),
                            if (auth.aviso != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: superficie,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const HugeIcon(
                                      icon:
                                          HugeIcons.strokeRoundedInformationCircle,
                                      size: 18,
                                      color: textoSecundario,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        auth.aviso!,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            CampoAuth(
                              controlador: _correo,
                              etiqueta: 'Correo electrónico',
                              icono: HugeIcons.strokeRoundedMail01,
                              habilitado: !auth.cargando,
                              tipoTeclado: TextInputType.emailAddress,
                              pistas: const [AutofillHints.email],
                              error: _errorCorreo ?? auth.errores['email'],
                              alCambiar: () => _alEditar(true),
                            ),
                            const SizedBox(height: 12),
                            CampoAuth(
                              controlador: _clave,
                              etiqueta: 'Contraseña',
                              icono: HugeIcons.strokeRoundedLockPassword,
                              habilitado: !auth.cargando,
                              accion: TextInputAction.done,
                              pistas: const [AutofillHints.password],
                              ocultar: !_verClave,
                              alAlternarVisibilidad: () =>
                                  setState(() => _verClave = !_verClave),
                              error: _errorClave ?? auth.errores['password'],
                              alCambiar: () => _alEditar(false),
                              alEnviar: _enviar,
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: auth.cargando
                                  ? null
                                  : () => setState(() => _recordar = !_recordar),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: Checkbox(
                                        value: _recordar,
                                        onChanged: auth.cargando
                                            ? null
                                            : (v) => setState(
                                                () => _recordar = v ?? false,
                                              ),
                                        fillColor:
                                            WidgetStateProperty.resolveWith(
                                              (estados) =>
                                                  estados.contains(
                                                    WidgetState.selected,
                                                  )
                                                  ? tintaPrincipal
                                                  : superficie,
                                            ),
                                        checkColor: papel,
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Recordar mis datos',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textoSecundario,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (auth.error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                auth.error!,
                                style: TextStyle(color: esquema.error),
                              ),
                            ],
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: auth.cargando ? null : _enviar,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: auth.cargando
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: papel,
                                      ),
                                    )
                                  : const Text(
                                      'Inicia sesión',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: auth.cargando
                                  ? null
                                  : () => context.go('/registro'),
                              child: const Text(
                                '¿No tienes cuenta? Regístrate',
                                style: TextStyle(
                                  color: tintaPrincipal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
