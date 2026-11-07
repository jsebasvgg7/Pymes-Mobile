import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import 'auth_controller.dart';
import 'widgets/campo_auth.dart';
import 'widgets/encabezado_auth.dart';

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
  String? _errorCorreo;
  String? _errorClave;

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
    await context.read<AuthController>().login(email: correo, password: clave);
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const EncabezadoAuth(
                    pestana: PestanaAuth.login,
                    titulo: '¡Bienvenido a Pymes ERP!',
                    subtitulo:
                        'Gestiona tu punto de venta, inventario y pagos desde un solo lugar.',
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Inicia sesión en tu cuenta',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ingresa con tus credenciales para administrar tu negocio.',
                    style: TextStyle(color: textoSecundario, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  CampoAuth(
                    controlador: _correo,
                    etiqueta: 'Correo electrónico',
                    icono: Icons.mail_outline,
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
                    icono: Icons.lock_outline,
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
                  if (auth.error != null) ...[
                    const SizedBox(height: 12),
                    Text(auth.error!, style: TextStyle(color: esquema.error)),
                  ],
                  const SizedBox(height: 18),
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
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: auth.cargando
                        ? null
                        : () => context.go('/registro'),
                    child: const Text(
                      '¿No tienes cuenta? Créala aquí',
                      style: TextStyle(color: tintaPrincipal, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pymes ERP · Tu negocio, más simple',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textoSecundario, fontSize: 12),
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
