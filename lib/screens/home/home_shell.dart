import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import 'home_screen.dart';
import '../participantes/participantes_screen.dart';
import '../biblioteca/biblioteca_screen.dart';
import '../votacao/votacao_screen.dart';
import '../encontros/encontros_screen.dart';

/// Controla qual aba está ativa no HomeShell. Permite que qualquer tela
/// (ex.: os atalhos da Home) troque de aba sem precisar de Navigator.
class NavIndexController extends ChangeNotifier {
  int indice = 0;
  void irPara(int novoIndice) {
    indice = novoIndice;
    notifyListeners();
  }
}

/// Estrutura principal com navegação inferior.
/// "Leitura Atual" fica dentro da Home (é o destaque da tela inicial),
/// e também acessível a partir da Biblioteca.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavIndexController(),
      child: const _HomeShellBody(),
    );
  }
}

class _HomeShellBody extends StatelessWidget {
  const _HomeShellBody();

  static const _telas = [
    HomeScreen(),
    BibliotecaScreen(),
    VotacaoScreen(),
    EncontrosScreen(),
    ParticipantesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavIndexController>();
    return Scaffold(
      body: IndexedStack(index: nav.indice, children: _telas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: nav.indice,
        onTap: (i) => context.read<NavIndexController>().irPara(i),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.how_to_vote_outlined), activeIcon: Icon(Icons.how_to_vote), label: 'Votação'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Encontros'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), activeIcon: Icon(Icons.people_alt), label: 'Participantes'),
        ],
      ),
    );
  }
}

/// Ícone decorativo reutilizável em cabeçalhos de seção.
class SectionHeader extends StatelessWidget {
  final String emoji;
  final String titulo;
  final String? subtitulo;
  final Widget? trailing;

  const SectionHeader({super.key, required this.emoji, required this.titulo, this.subtitulo, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$emoji $titulo', style: Theme.of(context).textTheme.titleLarge),
                if (subtitulo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(subtitulo!, style: TextStyle(color: AppColors.marrom.withOpacity(0.75))),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
