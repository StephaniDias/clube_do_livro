import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/user_provider.dart';
import '../../models/participante.dart';
import '../../theme/app_theme.dart';
import '../home/home_shell.dart';
import 'participante_detail_screen.dart';
import 'editar_perfil_screen.dart';

class ParticipantesScreen extends StatelessWidget {
  const ParticipantesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final user = context.watch<UserProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SectionHeader(
              emoji: '👥',
              titulo: 'Participantes',
              subtitulo: 'Quem faz parte do clube',
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Editar meu perfil',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditarPerfilScreen()),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Participante>>(
                stream: firestore.participantesStream(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final participantes = snap.data!;
                  if (participantes.isEmpty) {
                    return const Center(child: Text('Ninguém por aqui ainda 🌱'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: participantes.length,
                    itemBuilder: (context, i) {
                      final p = participantes[i];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.rosaClaro,
                            backgroundImage: p.fotoUrl != null ? NetworkImage(p.fotoUrl!) : null,
                            child: p.fotoUrl == null
                                ? Text(p.nome.isNotEmpty ? p.nome[0].toUpperCase() : '?',
                                    style: const TextStyle(color: AppColors.marrom, fontWeight: FontWeight.bold))
                                : null,
                          ),
                          title: Row(
                            children: [
                              Flexible(child: Text(p.apelido?.isNotEmpty == true ? p.apelido! : p.nome, overflow: TextOverflow.ellipsis)),
                              if (p.isAdmin) const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Text('👑', style: TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            [
                              if (p.cidade != null && p.cidade!.isNotEmpty) p.cidade,
                              if (p.generosFavoritos.isNotEmpty) p.generosFavoritos.take(2).join(', '),
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: p.status == 'Ativo'
                              ? const Icon(Icons.circle, size: 10, color: Colors.green)
                              : Icon(Icons.circle, size: 10, color: Colors.grey.shade400),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ParticipanteDetailScreen(participanteId: p.id)),
                          ),
                        ),
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
