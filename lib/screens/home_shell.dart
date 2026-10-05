import 'package:flutter/material.dart';

import 'inicio_page.dart';
import 'perfil_page.dart';

/// Contenedor con la barra de navegación inferior (Inicio / Perfil).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indice = 0;

  void _irA(int indice) => setState(() => _indice = indice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack conserva el estado (scroll, datos) al cambiar de pestaña.
      body: IndexedStack(
        index: _indice,
        children: [
          InicioPage(onVerPerfil: () => _irA(1)),
          const PerfilPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: _irA,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
