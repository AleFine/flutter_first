// Paso 1: la estructura de la pantalla con Scaffold.
// Ejecuta solo este archivo con: flutter run -t lib/pasos/paso1_estructura.dart
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.indigo)),
      home: const EstructuraPage(),
    ),
  );
}

class EstructuraPage extends StatelessWidget {
  const EstructuraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promedio de unidad')),
      body: const Center(child: Text('Aquí irá el formulario')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
