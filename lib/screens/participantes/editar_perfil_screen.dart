import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_provider.dart';

const _generosDisponiveis = [
  'Romance', 'Fantasia', 'Ficção Científica', 'Suspense', 'Terror',
  'Clássico', 'Biografia', 'Autoajuda', 'Poesia', 'Jovem Adulto', 'Drama', 'Humor',
];

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _firestore = FirestoreService();
  final _apelidoCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _aniversarioCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final Set<String> _generos = {};
  bool _carregado = false;
  bool _salvando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_carregado) {
      final p = context.read<UserProvider>().participante;
      if (p != null) {
        _apelidoCtrl.text = p.apelido ?? '';
        _cidadeCtrl.text = p.cidade ?? '';
        _aniversarioCtrl.text = p.aniversario ?? '';
        _instagramCtrl.text = p.instagram ?? '';
        _generos.addAll(p.generosFavoritos);
      }
      _carregado = true;
    }
  }

  Future<void> _salvar() async {
    final uid = context.read<UserProvider>().firebaseUser?.uid;
    if (uid == null) return;
    setState(() => _salvando = true);
    try {
      await _firestore.atualizarParticipante(uid, {
        'apelido': _apelidoCtrl.text.trim(),
        'cidade': _cidadeCtrl.text.trim(),
        'aniversario': _aniversarioCtrl.text.trim(),
        'instagram': _instagramCtrl.text.trim(),
        'generosFavoritos': _generos.toList(),
      });
      await context.read<UserProvider>().recarregarParticipante();
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => AuthService().sair(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _apelidoCtrl, decoration: const InputDecoration(labelText: '🏷️ Apelido')),
          const SizedBox(height: 14),
          TextField(controller: _cidadeCtrl, decoration: const InputDecoration(labelText: '📍 Cidade')),
          const SizedBox(height: 14),
          TextField(
            controller: _aniversarioCtrl,
            decoration: const InputDecoration(labelText: '🎂 Aniversário (dd/MM)'),
          ),
          const SizedBox(height: 14),
          TextField(controller: _instagramCtrl, decoration: const InputDecoration(labelText: '📱 Instagram')),
          const SizedBox(height: 20),
          const Text('📚 Gêneros favoritos', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _generosDisponiveis.map((g) {
              final selecionado = _generos.contains(g);
              return FilterChip(
                label: Text(g),
                selected: selecionado,
                onSelected: (v) => setState(() => v ? _generos.add(g) : _generos.remove(g)),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _salvando ? null : _salvar,
            child: _salvando
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
