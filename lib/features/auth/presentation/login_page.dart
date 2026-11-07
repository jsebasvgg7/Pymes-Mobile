import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import 'auth_controller.dart';

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
    final errorClave = clave.isEmpty ? 'Escribe tu clave.' : null;

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

  InputDecoration _decoracion({
    required String etiqueta,
    required IconData icono,
    String? error,
    Widget? sufijo,
  }) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: linea),
    );
    return InputDecoration(
      labelText: etiqueta,
      errorText: error,
      prefixIcon: Icon(icono),
      suffixIcon: sufijo,
      enabledBorder: borde,
      border: borde,
      focusedBorder: borde.copyWith(
        borderSide: const BorderSide(color: tintaPrincipal, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final esquema = Theme.of(context).colorScheme;
    final errorCorreo = _errorCorreo ?? auth.errores['email'];
    final errorClave = _errorClave ?? auth.errores['password'];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.storefront_outlined, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    'Inicie sesión en su cuenta',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ingrese con el correo de su negocio.',
                    style: TextStyle(color: textoSecundario),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _correo,
                    enabled: !auth.cargando,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    onChanged: (_) => _alEditar(true),
                    decoration: _decoracion(
                      etiqueta: 'Correo',
                      icono: Icons.mail_outline,
                      error: errorCorreo,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _clave,
                    enabled: !auth.cargando,
                    obscureText: !_verClave,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onChanged: (_) => _alEditar(false),
                    onSubmitted: (_) => _enviar(),
                    decoration: _decoracion(
                      etiqueta: 'Clave',
                      icono: Icons.lock_outline,
                      error: errorClave,
                      sufijo: IconButton(
                        tooltip: _verClave ? 'Ocultar clave' : 'Mostrar clave',
                        icon: Icon(
                          _verClave
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(() => _verClave = !_verClave),
                      ),
                    ),
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      auth.error!,
                      style: TextStyle(color: esquema.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: auth.cargando ? null : _enviar,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                        : const Text('Iniciar sesión'),
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
