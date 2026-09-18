import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/livro.dart';
import '../../models/encontro.dart';
import '../leitura_atual/leitura_atual_screen.dart';
import 'home_shell.dart'; // fornece SectionHeader e NavIndexController

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _confirmarLogout(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você vai precisar entrar de novo com seu e-mail e senha.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sair')),
        ],
      ),
    );
    if (confirmar == true) {
      await AuthService().sair();
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final user = context.watch<UserProvider>();
    final nome = user.participante?.apelido?.isNotEmpty == true
        ? user.participante!.apelido!
        : (user.participante?.nome.split(' ').first ?? '');

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Oi, $nome 🌷', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          'Um lugar para ler, conversar, discordar\ne descobrir novas histórias.',
                          style: TextStyle(color: AppColors.marrom.withOpacity(0.75), fontSize: 13),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('📚', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _confirmarLogout(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 14, color: AppColors.marrom.withOpacity(0.7)),
                                const SizedBox(width: 3),
                                Text('Sair', style: TextStyle(fontSize: 12, color: AppColors.marrom.withOpacity(0.7))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Leitura atual
              StreamBuilder<Livro?>(
                stream: firestore.livroAtualStream(),
                builder: (context, snap) {
                  final livro = snap.data;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LeituraAtualScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.rosaQueimado,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56, height: 78,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(10),
                                image: livro?.capaUrl != null
                                    ? DecorationImage(image: NetworkImage(livro!.capaUrl!), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: livro?.capaUrl == null
                                  ? const Icon(Icons.menu_book, color: Colors.white70)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('📖 LEITURA ATUAL',
                                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    livro?.titulo ?? 'Nenhum livro em leitura ainda',
                                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (livro != null) Text(livro.autor, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Próximo encontro
              StreamBuilder<List<Encontro>>(
                stream: firestore.encontrosStream(),
                builder: (context, snap) {
                  final encontros = snap.data ?? [];
                  final agora = DateTime.now();
                  Encontro? proximo;
                  for (final e in encontros) {
                    final data = e.data?.toDate();
                    if (data != null && data.isAfter(agora)) {
                      proximo = e;
                    }
                  }
                  if (proximo == null) return const SizedBox.shrink();
                  final data = proximo.data!.toDate();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Text('🗓️', style: TextStyle(fontSize: 26)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Próximo encontro', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${DateFormat("dd/MM/yyyy").format(data)}'
                                    '${proximo.horario != null ? " às ${proximo.horario}" : ""}'
                                    '${proximo.local != null ? " · ${proximo.local}" : ""}',
                                    style: TextStyle(color: AppColors.marrom.withOpacity(0.8), fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SectionHeader(emoji: '✨', titulo: 'Atalhos'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Atalho(emoji: '📚', label: 'Biblioteca', destino: 1),
                    _Atalho(emoji: '🗳️', label: 'Votação', destino: 2),
                    _Atalho(emoji: '🗓️', label: 'Encontros', destino: 3),
                    _Atalho(emoji: '🫶', label: 'Participantes', destino: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Atalho extends StatelessWidget {
  final String emoji;
  final String label;
  final int destino;
  const _Atalho({required this.emoji, required this.label, required this.destino});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.read<NavIndexController>().irPara(destino),
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.rosaClaro,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
