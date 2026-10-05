import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../data/models/curso.dart';
import '../data/models/usuario.dart';
import '../widgets/avatar_usuario.dart';
import 'promedio_page.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key, required this.onVerPerfil});

  final VoidCallback onVerPerfil;

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  Future<List<Curso>>? _cursos;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cursos ??= _cargarCursos();
  }

  Future<List<Curso>> _cargarCursos() {
    final scope = AppScope.read(context);
    return scope.dependencies.cursos.listarPorUsuario(scope.sesion.usuario!.id);
  }

  Future<void> _recargar() async {
    final cursos = _cargarCursos();
    setState(() => _cursos = cursos);
    await cursos.catchError((_) => <Curso>[]);
  }

  void _abrirCalculadora() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PromedioPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.of(context).sesion.usuario;
    if (usuario == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            tooltip: 'Mi perfil',
            onPressed: widget.onVerPerfil,
            icon: AvatarUsuario(usuario: usuario, radio: 16),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _recargar,
        child: FutureBuilder<List<Curso>>(
          future: _cursos,
          builder: (context, snapshot) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              // Espacio extra abajo para que el FAB no tape la última tarjeta.
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                _Saludo(usuario: usuario),
                const SizedBox(height: 16),
                ..._contenido(context, snapshot),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCalculadora,
        icon: const Icon(Icons.calculate),
        label: const Text('Calcular PU'),
      ),
    );
  }

  List<Widget> _contenido(
    BuildContext context,
    AsyncSnapshot<List<Curso>> snapshot,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const [
        Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (snapshot.hasError) {
      return [
        _Aviso(
          icono: Icons.cloud_off,
          texto: 'No se pudieron cargar tus cursos',
          accion: TextButton(onPressed: _recargar, child: const Text('Reintentar')),
        ),
      ];
    }

    final cursos = snapshot.data!;
    if (cursos.isEmpty) {
      return const [
        _Aviso(
          icono: Icons.menu_book_outlined,
          texto: 'Aún no tienes cursos matriculados',
        ),
      ];
    }

    return [
      _Resumen(cursos: cursos),
      const SizedBox(height: 24),
      Text('Mis cursos', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      for (final curso in cursos) ...[
        _CursoCard(curso: curso),
        const SizedBox(height: 12),
      ],
    ];
  }
}

class _Saludo extends StatelessWidget {
  const _Saludo({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;

    return Card(
      color: colores.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            AvatarUsuario(usuario: usuario, radio: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    'Hola, ${usuario.primerNombre}',
                    style: tema.textTheme.titleLarge?.copyWith(
                      color: colores.onPrimaryContainer,
                      fontWeight: .bold,
                    ),
                  ),
                  if (usuario.carrera?.isNotEmpty ?? false)
                    Text(
                      usuario.carrera!,
                      maxLines: 2,
                      overflow: .ellipsis,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: colores.onPrimaryContainer,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.cursos});

  final List<Curso> cursos;

  @override
  Widget build(BuildContext context) {
    final general =
        cursos.map((c) => c.promedio).reduce((a, b) => a + b) / cursos.length;
    final aprobados = cursos.where((c) => c.aprobado).length;

    return Row(
      children: [
        Expanded(child: _Dato(valor: '${cursos.length}', etiqueta: 'Cursos')),
        const SizedBox(width: 12),
        Expanded(
          child: _Dato(valor: general.toStringAsFixed(1), etiqueta: 'Promedio'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Dato(
            valor: '$aprobados/${cursos.length}',
            etiqueta: 'Aprobados',
          ),
        ),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.valor, required this.etiqueta});

  final String valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(
              valor,
              style: tema.textTheme.headlineSmall?.copyWith(fontWeight: .bold),
            ),
            const SizedBox(height: 4),
            Text(
              etiqueta,
              style: tema.textTheme.labelMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CursoCard extends StatelessWidget {
  const _CursoCard({required this.curso});

  final Curso curso;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final fondo = curso.aprobado ? Colors.green.shade100 : colores.errorContainer;
    final texto = curso.aprobado ? Colors.green.shade900 : colores.onErrorContainer;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(curso.nombre, style: tema.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        curso.docente,
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: colores.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: fondo,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    curso.promedio.toStringAsFixed(2),
                    style: tema.textTheme.titleMedium?.copyWith(
                      color: texto,
                      fontWeight: .bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              runSpacing: 4,
              children: [
                _Nota('EL', curso.notaEl),
                _Nota('ET', curso.notaEt),
                _Nota('PT', curso.notaPt),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Nota extends StatelessWidget {
  const _Nota(this.etiqueta, this.valor);

  final String etiqueta;
  final double valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$etiqueta ',
              style: TextStyle(color: tema.colorScheme.onSurfaceVariant),
            ),
            TextSpan(
              text: valor.toStringAsFixed(0),
              style: const TextStyle(fontWeight: .w600),
            ),
          ],
        ),
        style: tema.textTheme.bodyMedium,
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.icono, required this.texto, this.accion});

  final IconData icono;
  final String texto;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icono, size: 48, color: colores.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(texto, textAlign: .center),
          ?accion,
        ],
      ),
    );
  }
}
