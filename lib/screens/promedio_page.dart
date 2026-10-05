import 'package:flutter/material.dart';

import '../data/models/curso.dart';

class PromedioPage extends StatefulWidget {
  const PromedioPage({super.key});

  @override
  State<PromedioPage> createState() => _PromedioPageState();
}

class _PromedioPageState extends State<PromedioPage> {
  final _formKey = GlobalKey<FormState>();
  double _el = 0, _et = 0, _pt = 0;
  double? _promedio;

  String? _validarNota(String? texto) {
    final nota = double.tryParse(texto ?? '');
    if (nota == null) return 'Escribe un número';
    if (nota < 0 || nota > 20) return 'La nota va de 0 a 20';
    return null;
  }

  void _calcular() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _promedio = Curso.calcularPromedio(_el, _et, _pt);
      });
    }
  }

  void _limpiar() {
    _formKey.currentState!.reset();
    setState(() => _promedio = null);
  }

  Widget _campoNota(String etiqueta, void Function(double) guardar) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixIcon: const Icon(Icons.edit_note),
      ),
      keyboardType: const .numberWithOptions(decimal: true),
      textInputAction: .next,
      validator: _validarNota,
      onChanged: (_) => setState(() => _promedio = null),
      onSaved: (texto) => guardar(double.parse(texto!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultado = _promedio == null
        ? 'Ingresa tus notas'
        : 'PU = ${_promedio!.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Promedio de unidad')),
      // El scroll evita que el teclado de Android tape o desborde el form.
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              const Text('PU = (2·EL + ET + 2·PT) / 5'),
              const SizedBox(height: 16),
              _campoNota('Nota EL', (nota) => _el = nota),
              const SizedBox(height: 12),
              _campoNota('Nota ET', (nota) => _et = nota),
              const SizedBox(height: 12),
              _campoNota('Nota PT', (nota) => _pt = nota),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _calcular,
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: .center,
                children: [
                  const Icon(Icons.school),
                  const SizedBox(width: 8),
                  Text(resultado, style: const TextStyle(fontSize: 22)),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _limpiar,
        tooltip: 'Limpiar',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
