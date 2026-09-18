import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/user_provider.dart';
import '../../models/encontro.dart';
import '../../models/livro.dart';
import '../../theme/app_theme.dart';

class EncontroDetailScreen extends StatelessWidget {
  final String encontroId;
  const EncontroDetailScreen({super.key, required this.encontroId});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final user = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do encontro')),
      body: StreamBuilder<List<Encontro>>(
        stream: firestore.encontrosStream(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final encontro = snap.data!.where((e) => e.id == encontroId).cast<Encontro?>().firstWhere((e) => e != null, orElse: () => null);
          if (encontro == null) return const Center(child: Text('Encontro não encontrado.'));

          final vouParticipar = user.firebaseUser != null && encontro.participantesIds.contains(user.firebaseUser!.uid);
          final data = encontro.data?.toDate();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  const Text('🗓️', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data != null ? DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(data) : '—',
                          style: Theme.of(context).textTheme.titleMedium),
                      if (encontro.horario != null) Text('às ${encontro.horario}', style: TextStyle(color: AppColors.marrom.withOpacity(0.8))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _LinhaInfo(icone: encontro.formato == 'Online' ? '💻' : '📍', texto: encontro.local?.isNotEmpty == true ? encontro.local! : encontro.formato),
              if (encontro.livroId != null)
                FutureBuilder<List<Livro>>(
                  future: firestore.livrosStream().first,
                  builder: (context, snapLivros) {
                    final livro = snapLivros.data?.firstWhere((l) => l.id == encontro.livroId, orElse: () => Livro(id: '', titulo: '', autor: ''));
                    if (livro == null || livro.titulo.isEmpty) return const SizedBox.shrink();
                    return _LinhaInfo(icone: '📖', texto: '${livro.titulo} — ${livro.autor}');
                  },
                ),
              if (encontro.pauta != null && encontro.pauta!.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('📝 Pauta', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(encontro.pauta!),
              ],
              const SizedBox(height: 24),
              if (user.logado)
                OutlinedButton.icon(
                  icon: Icon(vouParticipar ? Icons.check_circle : Icons.check_circle_outline),
                  label: Text(vouParticipar ? 'Você confirmou presença' : 'Confirmar presença'),
                  onPressed: vouParticipar
                      ? null
                      : () {
                          final novaLista = [...encontro.participantesIds, user.firebaseUser!.uid];
                          firestore.atualizarEncontro(encontro.id, {'participantesIds': novaLista});
                        },
                ),
              const SizedBox(height: 12),
              Text('👥 ${encontro.participantesIds.length} confirmado(s)', style: const TextStyle(fontSize: 13)),
            ],
          );
        },
      ),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  final String icone;
  final String texto;
  const _LinhaInfo({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icone, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
