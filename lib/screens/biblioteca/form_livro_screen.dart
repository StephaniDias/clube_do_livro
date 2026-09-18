import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/user_provider.dart';
import '../../models/livro.dart';

const _generosDisponiveis = [
  'Romance', 'Fantasia', 'Ficção Científica', 'Suspense', 'Terror',
  'Clássico', 'Biografia', 'Autoajuda', 'Poesia', 'Jovem Adulto', 'Drama', 'Humor',
];

class FormLivroScreen extends StatefulWidget {
  const FormLivroScreen({super.key});

  @override
  State<FormLivroScreen> createState() => _FormLivroScreenState();
}

class _FormLivroScreenState extends State<FormLivroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _autorCtrl = TextEditingController();
  final _capaUrlCtrl = TextEditingController();
  final _anoCtrl = TextEditingController();
  final _paginasCtrl = TextEditingController();
  final Set<String> _generos = {};
  String _statusAdmin = LivroStatus.sugestao;
  bool _salvando = false;

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<UserProvider>();
    final isAdmin = user.isAdmin;
    setState(() => _salvando = true);

    final livro = Livro(
      id: '',
      titulo: _tituloCtrl.text.trim(),
      autor: _autorCtrl.text.trim(),
      capaUrl: _capaUrlCtrl.text.trim().isEmpty ? null : _capaUrlCtrl.text.trim(),
      genero: _generos.toList(),
      anoPublicacao: int.tryParse(_anoCtrl.text),
      paginas: int.tryParse(_paginasCtrl.text),
      status: isAdmin ? _statusAdmin : LivroStatus.sugestao,
      indicadoPorId: user.firebaseUser?.uid,
    );

    try {
      if (isAdmin) {
        await FirestoreService().adicionarLivroComoAdmin(livro);
      } else {
        await FirestoreService().sugerirLivro(livro);
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<UserProvider>().isAdmin;

    return Scaffold(
      appBar: AppBar(title: Text(isAdmin ? 'Adicionar livro' : 'Sugerir um livro')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (!isAdmin)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  'Sua sugestão vai para o admin do clube, que decide quando abrir a votação. 🌱',
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(labelText: '📖 Título'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _autorCtrl,
              decoration: const InputDecoration(labelText: '✍️ Autor(a)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o autor' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _capaUrlCtrl,
              decoration: const InputDecoration(labelText: '🖼️ URL da capa (opcional)'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _anoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '📅 Ano'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _paginasCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '📚 Páginas'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('🏷️ Gênero', style: TextStyle(fontWeight: FontWeight.w600)),
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
            if (isAdmin) ...[
              const SizedBox(height: 20),
              const Text('📊 Status inicial', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: LivroStatus.todos.map((s) {
                  return ChoiceChip(
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    selected: _statusAdmin == s,
                    onSelected: (_) => setState(() => _statusAdmin = s),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isAdmin ? 'Adicionar à biblioteca' : 'Enviar sugestão'),
            ),
          ],
        ),
      ),
    );
  }
}
