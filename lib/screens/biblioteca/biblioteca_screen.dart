import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/user_provider.dart';
import '../../models/livro.dart';
import '../../theme/app_theme.dart';
import '../home/home_shell.dart';
import 'livro_detail_screen.dart';
import 'form_livro_screen.dart';

class BibliotecaScreen extends StatefulWidget {
  const BibliotecaScreen({super.key});

  @override
  State<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen> {
  String? _filtro; // null = todos

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final isAdmin = context.watch<UserProvider>().isAdmin;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SectionHeader(emoji: '📚', titulo: 'Biblioteca do Clube', subtitulo: 'Todos os livros já passados por aqui'),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FiltroChip(label: 'Todos', selecionado: _filtro == null, onTap: () => setState(() => _filtro = null)),
                  ...LivroStatus.todos.map((s) => _FiltroChip(
                        label: s,
                        selecionado: _filtro == s,
                        onTap: () => setState(() => _filtro = s),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Livro>>(
                stream: firestore.livrosStream(status: _filtro),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final livros = snap.data!;
                  if (livros.isEmpty) {
                    return const Center(child: Text('Nenhum livro por aqui ainda 📖'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: livros.length,
                    itemBuilder: (context, i) => _LivroCard(livro: livros[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(isAdmin ? Icons.add : Icons.lightbulb_outline),
        label: Text(isAdmin ? 'Adicionar livro' : 'Sugerir livro'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FormLivroScreen()),
        ),
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool selecionado;
  final VoidCallback onTap;
  const _FiltroChip({required this.label, required this.selecionado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selecionado,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.rosaQueimado,
        labelStyle: TextStyle(color: selecionado ? Colors.white : AppColors.marrom),
      ),
    );
  }
}

class _LivroCard extends StatelessWidget {
  final Livro livro;
  const _LivroCard({required this.livro});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LivroDetailScreen(livroId: livro.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.rosaClaro,
                borderRadius: BorderRadius.circular(10),
                image: livro.capaUrl != null
                    ? DecorationImage(image: NetworkImage(livro.capaUrl!), fit: BoxFit.cover)
                    : null,
                boxShadow: [BoxShadow(color: AppColors.marrom.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: livro.capaUrl == null
                  ? const Center(child: Text('📖', style: TextStyle(fontSize: 28)))
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(livro.titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
          Text(livro.autor, style: TextStyle(fontSize: 11, color: AppColors.marrom.withOpacity(0.7)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
