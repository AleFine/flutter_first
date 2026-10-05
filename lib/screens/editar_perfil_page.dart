import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../data/repositories/repositories.dart';

class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({super.key});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _carrera;
  late final TextEditingController _telefono;
  late final String _email;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final usuario = AppScope.read(context).sesion.usuario!;
    _nombre = TextEditingController(text: usuario.nombre);
    _carrera = TextEditingController(text: usuario.carrera);
    _telefono = TextEditingController(text: usuario.telefono);
    _email = usuario.email;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _carrera.dispose();
    _telefono.dispose();
    super.dispose();
  }

  String? _validarNombre(String? texto) {
    if ((texto?.trim().length ?? 0) < 3) return 'Escribe tu nombre completo';
    return null;
  }

  String? _validarTelefono(String? texto) {
    final digitos = (texto ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (digitos.isEmpty) return null;
    if (!RegExp(r'^\+?\d{6,15}$').hasMatch(digitos)) return 'Teléfono no válido';
    return null;
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    try {
      await AppScope.read(context).sesion.actualizarPerfil(
        nombre: _nombre.text,
        carrera: _carrera.text,
        telefono: _telefono.text,
      );
      mensajero.showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
      navegador.pop();
    } catch (e) {
      final mensaje = e is DataException ? e.mensaje : 'No se pudo guardar';
      mensajero.showSnackBar(SnackBar(content: Text(mensaje)));
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nombre,
                enabled: !_guardando,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: .words,
                textInputAction: .next,
                validator: _validarNombre,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _email,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.email_outlined),
                  helperText: 'El correo no se puede cambiar',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _carrera,
                enabled: !_guardando,
                decoration: const InputDecoration(
                  labelText: 'Carrera',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                textCapitalization: .sentences,
                textInputAction: .next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefono,
                enabled: !_guardando,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: .phone,
                textInputAction: .done,
                validator: _validarTelefono,
                onFieldSubmitted: (_) => _guardar(),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
