// Paso 2: organizar el contenido con Padding, Column, Row y SizedBox.
// Ejecuta solo este archivo con: flutter run -t lib/pasos/paso2_layout.dart
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.indigo)),
      home: const LayoutPage(),
    ),
  );
}

class LayoutPage extends StatelessWidget {
  const LayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promedio de unidad')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Text('PU = (2·EL + ET + 2·PT) / 5'),
            SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.school),
                SizedBox(width: 8),
                Text('Notas de 0 a 20'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
