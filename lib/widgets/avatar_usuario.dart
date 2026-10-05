import 'package:flutter/material.dart';

import '../data/models/usuario.dart';

/// Foto de perfil circular; si no hay foto muestra las iniciales.
class AvatarUsuario extends StatelessWidget {
  const AvatarUsuario({super.key, required this.usuario, this.radio = 24});

  final Usuario usuario;
  final double radio;

  // Decodificar el base64 en cada build haría parpadear la imagen, así que
  // se reutiliza el mismo ImageProvider para la misma URL.
  static final _cache = <String, ImageProvider>{};

  static ImageProvider? _imagen(String? url) {
    if (url == null || url.isEmpty) return null;
    return _cache.putIfAbsent(url, () {
      if (_cache.length > 8) _cache.clear();
      return url.startsWith('data:')
          ? MemoryImage(UriData.parse(url).contentAsBytes())
          : NetworkImage(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final imagen = _imagen(usuario.fotoUrl);

    return CircleAvatar(
      radius: radio,
      backgroundColor: colores.primaryContainer,
      foregroundColor: colores.onPrimaryContainer,
      backgroundImage: imagen,
      onBackgroundImageError: imagen == null ? null : (_, _) {},
      child: imagen == null
          ? Text(
              usuario.iniciales,
              style: TextStyle(fontSize: radio * 0.7, fontWeight: .w600),
            )
          : null,
    );
  }
}
