import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/carga_marca.dart';
import 'auth_controller.dart';
import 'widgets/campo_auth.dart';
import 'widgets/encabezado_auth.dart';
import 'widgets/marca_auth.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  static final RegExp _formatoCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final TextEditingController _empresa = TextEditingController();
  final TextEditingController _usuario = TextEditingController();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _clave = TextEditingController();
  final TextEditingController _codigo = TextEditingController();

  bool _verClave = false;
  bool _verCodigo = false;
  Map<String, String> _locales = {};

  @override
  void dispose() {
    _empresa.dispose();
    _usuario.dispose();
    _correo.dispose();
    _clave.dispose();
    _codigo.dispose();
    super.dispose();
  }

  Map<String, String> _validar() {
    final errores = <String, String>{};
    final empresa = _empresa.text.trim();
    final usuario = _usuario.text.trim();
    final correo = _correo.text.trim();
    final codigo = _codigo.text.trim();

    if (empresa.isEmpty) {
      errores['empresaNombre'] = 'Escribe el nombre de tu negocio.';
    }
    if (usuario.length < 4 || usuario.length > 50) {
      errores['username'] = 'El usuario debe tener entre 4 y 50 caracteres.';
    }
    if (correo.isEmpty) {
      errores['email'] = 'Escribe tu correo.';
    } else if (!_formatoCorreo.hasMatch(correo)) {
      errores['email'] = 'Escribe un correo con formato válido.';
    }
    if (_clave.text.length < 6) {
      errores['password'] = 'La contraseña debe tener mínimo 6 caracteres.';
    }
    if (codigo.isEmpty) {
      errores['codigoRegistro'] = 'Escribe el código de acceso.';
    } else if (codigo.length > 128) {
      errores['codigoRegistro'] = 'El código es demasiado largo.';
    }
    return errores;
  }

  Future<void> _enviar() async {
    final errores = _validar();
    setState(() => _locales = errores);
    if (errores.isNotEmpty) return;

    FocusScope.of(context).unfocus();
    await context.read<AuthController>().registrar(
      empresaNombre: _empresa.text.trim(),
      username: _usuario.text.trim(),
      email: _correo.text.trim(),
      password: _clave.text,
      codigoRegistro: _codigo.text.trim(),
    );
  }

  void _alEditar(String campo) {
    if (_locales.containsKey(campo)) {
      setState(() => _locales = {..._locales}..remove(campo));
    }
    context.read<AuthController>().limpiarErrores();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final esquema = Theme.of(context).colorScheme;
    final ocupado = auth.cargando;

    String? error(String campo) => _locales[campo] ?? auth.errores[campo];

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
                              titulo: 'Crea tu cuenta',
                              subtitulo:
                                  'Ingresa el código que te entregamos para registrar tu negocio.',
                            ),
                            const SizedBox(height: 24),
                            CampoAuth(
                              controlador: _empresa,
                              etiqueta: 'Nombre de tu negocio',
                              icono: HugeIcons.strokeRoundedBuilding03,
                              habilitado: !ocupado,
                              error: error('empresaNombre'),
                              alCambiar: () => _alEditar('empresaNombre'),
                            ),
                            const SizedBox(height: 12),
                            CampoAuth(
                              controlador: _usuario,
                              etiqueta: 'Nombre de usuario',
                              icono: HugeIcons.strokeRoundedUser,
                              habilitado: !ocupado,
                              pistas: const [AutofillHints.newUsername],
                              error: error('username'),
                              alCambiar: () => _alEditar('username'),
                            ),
                            const SizedBox(height: 12),
                            CampoAuth(
                              controlador: _correo,
                              etiqueta: 'Correo electrónico',
                              icono: HugeIcons.strokeRoundedMail01,
                              habilitado: !ocupado,
                              tipoTeclado: TextInputType.emailAddress,
                              pistas: const [AutofillHints.email],
                              error: error('email'),
                              alCambiar: () => _alEditar('email'),
                            ),
                            const SizedBox(height: 12),
                            CampoAuth(
                              controlador: _clave,
                              etiqueta: 'Contraseña',
                              icono: HugeIcons.strokeRoundedLockPassword,
                              habilitado: !ocupado,
                              pistas: const [AutofillHints.newPassword],
                              ocultar: !_verClave,
                              alAlternarVisibilidad: () =>
                                  setState(() => _verClave = !_verClave),
                              error: error('password'),
                              alCambiar: () => _alEditar('password'),
                            ),
                            const SizedBox(height: 12),
                            CampoAuth(
                              controlador: _codigo,
                              etiqueta: 'Código que te entregamos',
                              icono: HugeIcons.strokeRoundedKey01,
                              habilitado: !ocupado,
                              accion: TextInputAction.done,
                              ocultar: !_verCodigo,
                              alAlternarVisibilidad: () =>
                                  setState(() => _verCodigo = !_verCodigo),
                              error: error('codigoRegistro'),
                              alCambiar: () => _alEditar('codigoRegistro'),
                              alEnviar: _enviar,
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
                              onPressed: ocupado ? null : _enviar,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: ocupado
                                  ? const CargaMarca(
                                      tamano: 22,
                                      color: papel,
                                      conBarrido: false,
                                    )
                                  : const Text(
                                      'Crear cuenta',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: ocupado
                                  ? null
                                  : () => context.go('/login'),
                              child: const Text(
                                '¿Ya tienes cuenta? Inicia sesión',
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
