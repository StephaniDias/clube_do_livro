import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../services/user_provider.dart';
import '../../models/encontro.dart';
import '../../models/livro.dart';
import '../../theme/app_theme.dart';
import '../home/home_shell.dart';
import 'form_encontro_screen.dart';
import 'encontro_detail_screen.dart';

class EncontrosScreen extends StatelessWidget {
  const EncontrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final isAdmin = context.watch<UserProvider>().isAdmin;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SectionHeader(emoji: '🗓️', titulo: 'Encontros', subtitulo: 'Nossos papos sobre os livros'),
            Expanded(
              child: StreamBuilder<List<Encontro>>(
                stream: firestore.encontrosStream(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final encontros = snap.data!;
                  if (encontros.isEmpty) {
                    return const Center(child: Text('Nenhum encontro marcado ainda 🕯️'));
                  }
                  return StreamBuilder<List<Livro>>(
                    stream: firestore.livrosStream(),
                    builder: (context, snapLivros) {
                      final livros = {for (final l in (snapLivros.data ?? [])) l.id: l};
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: encontros.length,
                        itemBuilder: (context, i) {
                          final e = encontros[i];
                          final livro = e.livroId != null ? livros[e.livroId] : null;
                          final data = e.data?.toDate();
                          final futuro = data != null && data.isAfter(DateTime.now());

                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: futuro ? AppColors.rosaQueimado : AppColors.rosaClaro,
                                child: Text(
                                  data != null ? DateFormat('dd').format(data) : '?',
                                  style: TextStyle(color: futuro ? Colors.white : AppColors.marrom, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(livro?.titulo ?? 'Encontro do clube'),
                              subtitle: Text(
                                [
                                  if (data != null) DateFormat('dd/MM/yyyy').format(data),
                                  if (e.horario != null) e.horario,
                                  e.formato,
                                  if (e.local != null && e.local!.isNotEmpty) e.local,
                                ].join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => EncontroDetailScreen(encontroId: e.id)),
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
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Marcar encontro'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FormEncontroScreen()),
              ),
            )
          : null,
    );
  }
}
