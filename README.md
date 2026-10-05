# mi_primera_app — Semana 9, Aplicaciones Móviles (UNT)

App de ejemplo de la sesión: calcula el promedio de unidad del sílabo,
PU = (2·EL + ET + 2·PT) / 5, usando los widgets básicos de Flutter
(Scaffold, AppBar, body, Center, Padding, Form, Column, Row, SizedBox,
Text, TextFormField, ElevatedButton, Icon y FloatingActionButton).

Probado con Flutter 3.47.6 (Dart 3.13.5).

## App con login, inicio y perfil

Cuentas de prueba (contraseña `123456`): `alumno@unt.edu.pe`, `docente@unt.edu.pe`.
Los datos viven en memoria y se reinician al cerrar la app.

```
lib/
  main.dart                 arranque; elige AppDependencies.mock()
  app.dart                  tema, marco de teléfono en web, login ↔ inicio
  core/
    dependencies.dart       punto único para cambiar mocks por una BD real
    sesion_controller.dart  usuario logueado, editar perfil, subir/quitar foto
    app_scope.dart          da acceso a la sesión desde cualquier widget
  data/
    models/                 Usuario, Curso (con toMap/fromMap)
    repositories/           interfaces: Auth, Usuario, Curso, Archivo
    mock/                   MemoriaDatabase (datos hardcodeados) + repos mock
  screens/                  login, home_shell, inicio, perfil, editar_perfil, promedio
  widgets/avatar_usuario.dart
```

**Pasar a una base de datos:** implementa las 4 interfaces de
`lib/data/repositories/repositories.dart` (por ejemplo con Firebase o una API
REST), crea `AppDependencies.api(...)` en `core/dependencies.dart` y úsalo en
`main.dart`. Las pantallas no cambian. `ArchivoRepository.subirFotoPerfil`
debe devolver la URL `https://` de la imagen; el mock devuelve un `data:` URI.

## Archivos

- `lib/screens/promedio_page.dart`: calculadora del promedio (formulario, validación, eventos y resultado).
- `lib/pasos/paso0_plantilla.dart`: la plantilla original del contador que genera `flutter create`.
- `lib/pasos/paso1_estructura.dart`: paso 1, Scaffold con AppBar, body y FAB.
- `lib/pasos/paso2_layout.dart`: paso 2, Padding, Column, Row y SizedBox.
- `test/widget_test.dart`: pruebas de la app final.

## Cómo ejecutar

```
flutter pub get
flutter run                                    # app final (lib/main.dart)
flutter run -t lib/pasos/paso1_estructura.dart # solo el paso 1
flutter run -t lib/pasos/paso2_layout.dart     # solo el paso 2
flutter test                                   # pruebas
```

En VS Code: abre la carpeta, elige el dispositivo en la barra de estado y pulsa F5.
