import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/user_provider.dart';
import '../../models/livro.dart';
import '../../theme/app_theme.dart';

class LeituraAtualScreen extends StatelessWidget {
  const LeituraAtualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final user = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('📖 Leitura Atual')),
      body: StreamBuilder<Livro?>(
        stream: firestore.livroAtualStream(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final livro = snap.data;
          if (livro == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Ainda não há um livro sendo lido pelo clube.\nAcompanhe a Votação! 🗳️', textAlign: TextAlign.center),
              ),
            );
          }

          final jaMarquei = user.firebaseUser != null && livro.participantesIds.contains(user.firebaseUser!.uid);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 160, height: 230,
                  decoration: BoxDecoration(
                    color: AppColors.rosaClaro,
                    borderRadius: BorderRadius.circular(16),
                    image: livro.capaUrl != null ? DecorationImage(image: NetworkImage(livro.capaUrl!), fit: BoxFit.cover) : null,
                    boxShadow: [BoxShadow(color: AppColors.marrom.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: livro.capaUrl == null ? const Center(child: Text('📖', style: TextStyle(fontSize: 52))) : null,
                ),
              ),
              const SizedBox(height: 20),
              Center(child: Text(livro.titulo, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge)),
              const SizedBox(height: 4),
              Center(child: Text(livro.autor, style: TextStyle(color: AppColors.marrom.withOpacity(0.8)))),
              const SizedBox(height: 16),
              if (livro.genero.isNotEmpty)
                Center(
                  child: Wrap(
                    spacing: 6,
                    alignment: WrapAlignment.center,
                    children: livro.genero.map((g) => Chip(label: Text(g))).toList(),
                  ),
                ),
              const SizedBox(height: 24),
              if (user.logado)
                Center(
                  child: OutlinedButton.icon(
                    icon: Icon(jaMarquei ? Icons.check_circle : Icons.check_circle_outline),
                    label: Text(jaMarquei ? 'Você já marcou como lendo' : 'Marcar que estou lendo'),
                    onPressed: jaMarquei
                        ? null
                        : () {
                            final novaLista = [...livro.participantesIds, user.firebaseUser!.uid];
                            firestore.atualizarLivro(livro.id, {'participantesIds': novaLista});
                          },
                  ),
                ),
              const SizedBox(height: 16),
              Text('👥 ${livro.participantesIds.length} pessoa(s) lendo junto', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
            ],
          );
        },
      ),
    );
  }
}
