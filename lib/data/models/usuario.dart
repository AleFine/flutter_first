/// Usuario de la app. `toMap`/`fromMap` usan los mismos nombres de campo que
/// tendría la tabla o colección en una base de datos real.
class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.codigo,
    this.carrera,
    this.telefono,
    this.fotoUrl,
  });

  final String id;
  final String nombre;
  final String email;
  final String? codigo;
  final String? carrera;
  final String? telefono;

  /// URL de la foto de perfil. Con los mocks es un `data:` URI; con un
  /// backend real será una URL `https://` del almacenamiento de archivos.
  final String? fotoUrl;

  String get primerNombre => nombre.trim().split(RegExp(r'\s+')).first;

  String get iniciales {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    return partes.take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }

  Usuario copyWith({String? fotoUrl, bool quitarFoto = false}) {
    return Usuario(
      id: id,
      email: email,
      nombre: nombre,
      codigo: codigo,
      carrera: carrera,
      telefono: telefono,
      fotoUrl: quitarFoto ? null : (fotoUrl ?? this.fotoUrl),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'email': email,
    'codigo': codigo,
    'carrera': carrera,
    'telefono': telefono,
    'foto_url': fotoUrl,
  };

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
    id: map['id'] as String,
    nombre: map['nombre'] as String,
    email: map['email'] as String,
    codigo: map['codigo'] as String?,
    carrera: map['carrera'] as String?,
    telefono: map['telefono'] as String?,
    fotoUrl: map['foto_url'] as String?,
  );
}
