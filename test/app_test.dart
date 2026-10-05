import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mi_primera_app/core/dependencies.dart';
import 'package:mi_primera_app/core/sesion_controller.dart';
import 'package:mi_primera_app/data/repositories/repositories.dart';
import 'package:mi_primera_app/main.dart';

void main() {
  AppDependencies mocks() => AppDependencies.mock(latencia: Duration.zero);

  /// Pantalla de un teléfono Android típico: 1080×2340 px a 3x = 360×780 dp.
  void usarPantallaDeTelefono(WidgetTester tester, {double anchoDp = 360}) {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = Size(anchoDp * 3, 780 * 3);
    addTearDown(tester.view.reset);
  }

  Future<void> iniciarSesion(WidgetTester tester, String email, String clave) async {
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), clave);
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();
  }

  group('Login', () {
    testWidgets('rechaza credenciales incorrectas', (tester) async {
      usarPantallaDeTelefono(tester);
      await tester.pumpWidget(MiApp(dependencies: mocks()));
      await tester.pumpAndSettle();

      await iniciarSesion(tester, 'alumno@unt.edu.pe', 'incorrecta');

      expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
      expect(find.text('Bienvenido'), findsOneWidget);
    });

    testWidgets('valida el formato del correo', (tester) async {
      usarPantallaDeTelefono(tester);
      await tester.pumpWidget(MiApp(dependencies: mocks()));
      await tester.pumpAndSettle();

      await iniciarSesion(tester, 'no-es-correo', '123456');

      expect(find.text('Correo no válido'), findsOneWidget);
    });

    testWidgets('entra al inicio y muestra los cursos del mock', (tester) async {
      usarPantallaDeTelefono(tester);
      await tester.pumpWidget(MiApp(dependencies: mocks()));
      await tester.pumpAndSettle();

      await iniciarSesion(tester, 'alumno@unt.edu.pe', '123456');

      expect(find.text('Hola, Kevin'), findsOneWidget);
      expect(find.text('Aplicaciones Móviles'), findsOneWidget);
      expect(find.text('16.00'), findsOneWidget); // PU de Aplicaciones Móviles
      expect(find.text('3/4'), findsOneWidget); // cursos aprobados
    });
  });

  testWidgets('perfil: editar datos y cerrar sesión', (tester) async {
    usarPantallaDeTelefono(tester);
    await tester.pumpWidget(MiApp(dependencies: mocks()));
    await tester.pumpAndSettle();
    await iniciarSesion(tester, 'alumno@unt.edu.pe', '123456');

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Kevin Paredes'), findsOneWidget);
    expect(find.text('alumno@unt.edu.pe'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Editar perfil'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Kevin García');
    await tester.enterText(find.byType(TextFormField).last, '');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil actualizado'), findsOneWidget);
    expect(find.text('Kevin García'), findsOneWidget);
    expect(find.text('Sin registrar'), findsOneWidget); // teléfono borrado

    await tester.tap(find.widgetWithText(OutlinedButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salir'));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido'), findsOneWidget);
  });

  testWidgets('sin desbordes en un teléfono pequeño (320 dp)', (tester) async {
    usarPantallaDeTelefono(tester, anchoDp: 320);
    await tester.pumpWidget(MiApp(dependencies: mocks()));
    await tester.pumpAndSettle();
    await iniciarSesion(tester, 'alumno@unt.edu.pe', '123456');
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  group('SesionController con mocks', () {
    late SesionController sesion;

    setUp(() async {
      sesion = SesionController(mocks());
      await sesion.restaurarSesion();
      await sesion.iniciarSesion('alumno@unt.edu.pe', '123456');
    });

    test('sube la foto como data URI y la puede quitar', () async {
      await sesion.cambiarFoto(Uint8List.fromList([1, 2, 3]), mimeType: 'image/png');
      expect(sesion.usuario!.fotoUrl, 'data:image/png;base64,AQID');

      await sesion.quitarFoto();
      expect(sesion.usuario!.fotoUrl, isNull);
    });

    test('cerrar sesión limpia el usuario', () async {
      await sesion.cerrarSesion();
      expect(sesion.autenticado, isFalse);
    });

    test('credenciales inválidas lanzan DataException', () {
      expect(
        SesionController(mocks()).iniciarSesion('x@y.com', 'malmal'),
        throwsA(isA<DataException>()),
      );
    });
  });
}
