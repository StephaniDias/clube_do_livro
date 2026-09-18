import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/participante.dart';
import '../../theme/app_theme.dart';

class ParticipanteDetailScreen extends StatelessWidget {
  final String participanteId;
  const ParticipanteDetailScreen({super.key, required this.participanteId});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<Participante?>(
        future: firestore.getParticipante(participanteId),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final p = snap.data;
          if (p == null) return const Center(child: Text('Participante não encontrado.'));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.rosaClaro,
                  backgroundImage: p.fotoUrl != null ? NetworkImage(p.fotoUrl!) : null,
                  child: p.fotoUrl == null
                      ? Text(p.nome.isNotEmpty ? p.nome[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 30, color: AppColors.marrom))
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  p.apelido?.isNotEmpty == true ? '${p.apelido} (${p.nome})' : p.nome,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              if (p.isAdmin)
                const Center(child: Padding(padding: EdgeInsets.only(top: 4), child: Text('👑 Admin do clube'))),
              const SizedBox(height: 20),
              _InfoRow(icone: '📍', label: 'Cidade', valor: p.cidade),
              _InfoRow(icone: '🎂', label: 'Aniversário', valor: p.aniversario),
              _InfoRow(icone: '📅', label: 'No clube desde', valor: p.entradaClube?.toDate().toString().split(' ').first),
              _InfoRow(icone: '⭐', label: 'Nota média dada', valor: p.notaMedia > 0 ? p.notaMedia.toStringAsFixed(1) : null),
              _InfoRow(icone: '📱', label: 'Instagram', valor: p.instagram),
              if (p.generosFavoritos.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('📚 Gêneros favoritos', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: p.generosFavoritos.map((g) => Chip(label: Text(g))).toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icone;
  final String label;
  final String? valor;
  const _InfoRow({required this.icone, required this.label, this.valor});

  @override
  Widget build(BuildContext context) {
    if (valor == null || valor!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(icone, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(valor!)),
        ],
      ),
    );
  }
}
