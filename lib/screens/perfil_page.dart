import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_scope.dart';
import '../data/models/usuario.dart';
import '../widgets/avatar_usuario.dart';
import 'editar_perfil_page.dart';

enum _AccionFoto { camara, galeria, quitar }

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _picker = ImagePicker();

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _cambiarFoto(Usuario usuario) async {
    final accion = await showModalBottomSheet<_AccionFoto>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: .min,
          children: [
            if (_picker.supportsImageSource(ImageSource.camera))
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Tomar foto'),
                onTap: () => Navigator.pop(context, _AccionFoto.camara),
              ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(context, _AccionFoto.galeria),
            ),
            if (usuario.fotoUrl != null)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: const Text('Quitar foto'),
                onTap: () => Navigator.pop(context, _AccionFoto.quitar),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (accion == null || !mounted) return;

    final sesion = AppScope.read(context).sesion;
    try {
      if (accion == _AccionFoto.quitar) {
        await sesion.quitarFoto();
        _avisar('Foto eliminada');
        return;
      }

      // Se reduce la imagen antes de subirla: un avatar no necesita más.
      final archivo = await _picker.pickImage(
        source: accion == _AccionFoto.camara ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
      if (archivo == null) return;

      final bytes = await archivo.readAsBytes();
      await sesion.cambiarFoto(bytes, mimeType: _mimeType(archivo));
      _avisar('Foto actualizada');
    } catch (_) {
      _avisar('No se pudo actualizar la foto');
    }
  }

  String _mimeType(XFile archivo) {
    if (archivo.mimeType != null) return archivo.mimeType!;
    final nombre = archivo.name.toLowerCase();
    if (nombre.endsWith('.png')) return 'image/png';
    if (nombre.endsWith('.webp')) return 'image/webp';
    if (nombre.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  void _editar() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EditarPerfilPage()),
    );
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      await AppScope.read(context).sesion.cerrarSesion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesion = AppScope.of(context).sesion;
    final usuario = sesion.usuario;
    if (usuario == null) return const SizedBox.shrink();

    final tema = Theme.of(context);
    final colores = tema.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          IconButton(
            tooltip: 'Editar perfil',
            onPressed: _editar,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Center(
            child: _AvatarEditable(
              usuario: usuario,
              subiendo: sesion.subiendoFoto,
              onCambiar: () => _cambiarFoto(usuario),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            usuario.nombre,
            textAlign: .center,
            style: tema.textTheme.headlineSmall?.copyWith(fontWeight: .bold),
          ),
          const SizedBox(height: 4),
          Text(
            usuario.email,
            textAlign: .center,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: colores.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            clipBehavior: .antiAlias,
            child: Column(
              children: [
                _Dato(Icons.badge_outlined, 'Código', usuario.codigo),
                const Divider(height: 1, indent: 56),
                _Dato(Icons.school_outlined, 'Carrera', usuario.carrera),
                const Divider(height: 1, indent: 56),
                _Dato(Icons.phone_outlined, 'Teléfono', usuario.telefono),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: _editar,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar perfil'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _cerrarSesion,
            style: OutlinedButton.styleFrom(
              foregroundColor: colores.error,
              side: BorderSide(color: colores.error.withValues(alpha: 0.5)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class _AvatarEditable extends StatelessWidget {
  const _AvatarEditable({
    required this.usuario,
    required this.subiendo,
    required this.onCambiar,
  });

  final Usuario usuario;
  final bool subiendo;
  final VoidCallback onCambiar;

  static const _radio = 56.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Cambiar foto de perfil',
      child: GestureDetector(
        onTap: subiendo ? null : onCambiar,
        child: SizedBox.square(
          dimension: _radio * 2 + 8,
          child: Stack(
            alignment: .center,
            children: [
              AvatarUsuario(usuario: usuario, radio: _radio),
              if (subiendo)
                const CircleAvatar(
                  radius: _radio,
                  backgroundColor: Colors.black45,
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton.filled(
                  tooltip: 'Cambiar foto',
                  onPressed: subiendo ? null : onCambiar,
                  icon: const Icon(Icons.photo_camera, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.icono, this.etiqueta, this.valor);

  final IconData icono;
  final String etiqueta;
  final String? valor;

  @override
  Widget build(BuildContext context) {
    final vacio = valor == null || valor!.isEmpty;
    return ListTile(
      leading: Icon(icono),
      title: Text(etiqueta),
      subtitle: Text(
        vacio ? 'Sin registrar' : valor!,
        style: vacio ? const TextStyle(fontStyle: .italic) : null,
      ),
    );
  }
}
