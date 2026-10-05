import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../data/repositories/repositories.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _ocultarPassword = true;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validarEmail(String? texto) {
    final email = texto?.trim() ?? '';
    if (email.isEmpty) return 'Escribe tu correo';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Correo no válido';
    }
    return null;
  }

  String? _validarPassword(String? texto) {
    if (texto == null || texto.isEmpty) return 'Escribe tu contraseña';
    if (texto.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  Future<void> _ingresar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await AppScope.read(context).sesion.iniciarSesion(
        _email.text,
        _password.text,
      );
      // Al iniciar sesión, App cambia a la pantalla de inicio por sí sola.
    } on DataException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo conectar. Intenta otra vez.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _usarCuentaDePrueba(String email) {
    setState(() {
      _email.text = email;
      _password.text = '123456';
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: colores.primaryContainer,
                        child: Icon(
                          Icons.school,
                          size: 44,
                          color: colores.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bienvenido',
                        textAlign: .center,
                        style: tema.textTheme.headlineMedium?.copyWith(
                          fontWeight: .bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión para ver tus cursos',
                        textAlign: .center,
                        style: tema.textTheme.bodyLarge?.copyWith(
                          color: colores.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _email,
                        enabled: !_cargando,
                        decoration: const InputDecoration(
                          labelText: 'Correo institucional',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: .emailAddress,
                        textInputAction: .next,
                        autocorrect: false,
                        autofillHints: const [AutofillHints.email],
                        validator: _validarEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        enabled: !_cargando,
                        obscureText: _ocultarPassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _ocultarPassword ? 'Mostrar' : 'Ocultar',
                            icon: Icon(
                              _ocultarPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _ocultarPassword = !_ocultarPassword,
                            ),
                          ),
                        ),
                        textInputAction: .done,
                        autofillHints: const [AutofillHints.password],
                        validator: _validarPassword,
                        onFieldSubmitted: (_) => _ingresar(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        _MensajeError(_error!),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _cargando ? null : _ingresar,
                        child: _cargando
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              )
                            : const Text('Ingresar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MensajeError extends StatelessWidget {
  const _MensajeError(this.mensaje);

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colores.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colores.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(mensaje, style: TextStyle(color: colores.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}

/// Atajos a las cuentas de `MemoriaDatabase`. Solo aparece en modo debug.
class _CuentasDePrueba extends StatelessWidget {
  const _CuentasDePrueba({required this.onElegir});

  final void Function(String email)? onElegir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      children: [
        Text(
          'Cuentas de prueba (contraseña 123456)',
          style: tema.textTheme.labelMedium?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: .center,
          children: [
            for (final email in const ['alumno@unt.edu.pe', 'docente@unt.edu.pe'])
              ActionChip(
                avatar: const Icon(Icons.person_outline, size: 18),
                label: Text(email),
                onPressed: onElegir == null ? null : () => onElegir!(email),
              ),
          ],
        ),
      ],
    );
  }
}
