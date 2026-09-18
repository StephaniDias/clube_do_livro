import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/user_provider.dart';
import '../../models/votacao.dart';
import '../../models/livro.dart';
import '../../theme/app_theme.dart';
import '../home/home_shell.dart';

class VotacaoScreen extends StatelessWidget {
  const VotacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final user = context.watch<UserProvider>();
    final meuId = user.firebaseUser?.uid;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SectionHeader(
              emoji: '🗳️',
              titulo: 'Votação',
              subtitulo: 'Escolha o próximo livro do clube',
            ),
            Expanded(
              child: StreamBuilder<List<Votacao>>(
                stream: firestore.votacoesAbertasStream(),
                builder: (context, snapVotacoes) {
                  if (!snapVotacoes.hasData) return const Center(child: CircularProgressIndicator());
                  final votacoes = snapVotacoes.data!;
                  if (votacoes.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Nenhuma votação aberta agora.\nQuando o admin liberar livros da biblioteca, eles aparecem aqui! 🗳️',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return StreamBuilder<List<Livro>>(
                    stream: firestore.livrosStream(),
                    builder: (context, snapLivros) {
                      final livros = {for (final l in (snapLivros.data ?? [])) l.id: l};

                      // ordena por número de votos, decrescente
                      final ordenadas = [...votacoes]..sort((a, b) => b.totalVotos.compareTo(a.totalVotos));

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: ordenadas.length,
                        itemBuilder: (context, i) {
                          final votacao = ordenadas[i];
                          final livro = livros[votacao.livroId];
                          if (livro == null) return const SizedBox.shrink();
                          final jaVotei = meuId != null && votacao.votosIds.contains(meuId);

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52, height: 74,
                                    decoration: BoxDecoration(
                                      color: AppColors.rosaClaro,
                                      borderRadius: BorderRadius.circular(8),
                                      image: livro.capaUrl != null
                                          ? DecorationImage(image: NetworkImage(livro.capaUrl!), fit: BoxFit.cover)
                                          : null,
                                    ),
                                    child: livro.capaUrl == null
                                        ? const Center(child: Text('📖'))
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(livro.titulo, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text(livro.autor, style: TextStyle(fontSize: 12, color: AppColors.marrom.withOpacity(0.75))),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.how_to_vote, size: 14, color: AppColors.rosaQueimado),
                                            const SizedBox(width: 4),
                                            Text('${votacao.totalVotos} voto${votacao.totalVotos == 1 ? '' : 's'}',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _BotaoVotar(
                                    jaVotei: jaVotei,
                                    onPressed: meuId == null
                                        ? null
                                        : () {
                                            if (jaVotei) {
                                              firestore.removerVoto(votacaoId: votacao.id, participanteId: meuId);
                                            } else {
                                              firestore.votar(votacaoId: votacao.id, participanteId: meuId);
                                            }
                                          },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotaoVotar extends StatelessWidget {
  final bool jaVotei;
  final VoidCallback? onPressed;
  const _BotaoVotar({required this.jaVotei, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return jaVotei
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.rosaQueimado,
              side: const BorderSide(color: AppColors.rosaQueimado),
            ),
            child: const Text('Votei ✓', style: TextStyle(fontSize: 12)),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
            child: const Text('Votar', style: TextStyle(fontSize: 12)),
          );
  }
}
