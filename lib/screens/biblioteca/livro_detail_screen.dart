import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/user_provider.dart';
import '../../models/livro.dart';
import '../../theme/app_theme.dart';

class LivroDetailScreen extends StatelessWidget {
  final String livroId;
  const LivroDetailScreen({super.key, required this.livroId});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final isAdmin = context.watch<UserProvider>().isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do livro')),
      body: StreamBuilder<List<Livro>>(
        stream: firestore.livrosStream(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final livro = snap.data!.where((l) => l.id == livroId).cast<Livro?>().firstWhere((l) => l != null, orElse: () => null);
          if (livro == null) return const Center(child: Text('Livro não encontrado.'));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 140, height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.rosaClaro,
                    borderRadius: BorderRadius.circular(14),
                    image: livro.capaUrl != null ? DecorationImage(image: NetworkImage(livro.capaUrl!), fit: BoxFit.cover) : null,
                  ),
                  child: livro.capaUrl == null ? const Center(child: Text('📖', style: TextStyle(fontSize: 44))) : null,
                ),
              ),
              const SizedBox(height: 18),
              Center(child: Text(livro.titulo, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium)),
              const SizedBox(height: 4),
              Center(child: Text(livro.autor, style: TextStyle(color: AppColors.marrom.withOpacity(0.8)))),
              const SizedBox(height: 10),
              Center(
                child: Chip(
                  label: Text(livro.status),
                  backgroundColor: AppColors.rosaQueimado.withOpacity(0.15),
                ),
              ),
              const SizedBox(height: 16),
              if (livro.genero.isNotEmpty)
                Center(
                  child: Wrap(
                    spacing: 6,
                    alignment: WrapAlignment.center,
                    children: livro.genero.map((g) => Chip(label: Text(g))).toList(),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (livro.anoPublicacao != null) _Info('📅', '${livro.anoPublicacao}'),
                  if (livro.paginas != null) _Info('📚', '${livro.paginas} pág.'),
                  if (livro.notaClube > 0) _Info('⭐', livro.notaClube.toStringAsFixed(1)),
                ],
              ),
              if (livro.resenhaClube != null && livro.resenhaClube!.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('📝 Resenha do clube', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(livro.resenhaClube!),
              ],
              if (isAdmin) ...[
                const Divider(height: 40),
                const Text('👑 Ações do admin', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (livro.status == LivroStatus.sugestao)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.how_to_vote),
                    label: const Text('Abrir votação para este livro'),
                    onPressed: () async {
                      await firestore.abrirVotacaoParaLivro(livro);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Votação aberta! 🗳️')),
                        );
                      }
                    },
                  ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: LivroStatus.todos.where((s) => s != livro.status).map((s) {
                    return OutlinedButton(
                      onPressed: () => firestore.atualizarLivro(livro.id, {'status': s}),
                      child: Text('Mover para "$s"', style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String emoji;
  final String texto;
  const _Info(this.emoji, this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(texto, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
