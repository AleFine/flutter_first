import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mi_primera_app/screens/promedio_page.dart';

void main() {
  Widget calculadora() => const MaterialApp(home: PromedioPage());

  testWidgets('Calcula el promedio de unidad', (WidgetTester tester) async {
    await tester.pumpWidget(calculadora());
    expect(find.text('Ingresa tus notas'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '16');
    await tester.enterText(find.byType(TextFormField).at(1), '14');
    await tester.enterText(find.byType(TextFormField).at(2), '17');
    await tester.tap(find.text('Calcular'));
    await tester.pump();

    expect(find.text('PU = 16.00'), findsOneWidget);
  });

  testWidgets('Valida que la nota esté entre 0 y 20', (tester) async {
    await tester.pumpWidget(calculadora());

    await tester.enterText(find.byType(TextFormField).at(0), '25');
    await tester.tap(find.text('Calcular'));
    await tester.pump();

    expect(find.text('La nota va de 0 a 20'), findsOneWidget);
    expect(find.text('Escribe un número'), findsNWidgets(2));
  });
}
