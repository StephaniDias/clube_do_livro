import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/encontro.dart';
import '../../models/livro.dart';

class FormEncontroScreen extends StatefulWidget {
  const FormEncontroScreen({super.key});

  @override
  State<FormEncontroScreen> createState() => _FormEncontroScreenState();
}

class _FormEncontroScreenState extends State<FormEncontroScreen> {
  DateTime? _data;
  final _horarioCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  final _pautaCtrl = TextEditingController();
  String _formato = 'Presencial';
  String? _livroId;
  bool _salvando = false;

  Future<void> _escolherData() async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selecionada != null) setState(() => _data = selecionada);
  }

  Future<void> _salvar() async {
    if (_data == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escolha uma data para o encontro')));
      return;
    }
    setState(() => _salvando = true);
    try {
      final encontro = Encontro(
        id: '',
        data: Timestamp.fromDate(_data!),
        horario: _horarioCtrl.text.trim().isEmpty ? null : _horarioCtrl.text.trim(),
        livroId: _livroId,
        local: _localCtrl.text.trim().isEmpty ? null : _localCtrl.text.trim(),
        formato: _formato,
        pauta: _pautaCtrl.text.trim().isEmpty ? null : _pautaCtrl.text.trim(),
      );
      await FirestoreService().criarEncontro(encontro);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Marcar encontro')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(_data == null ? 'Escolher data' : DateFormat('dd/MM/yyyy').format(_data!)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _escolherData,
          ),
          const SizedBox(height: 6),
          TextField(controller: _horarioCtrl, decoration: const InputDecoration(labelText: '⏰ Horário (ex.: 19:30)')),
          const SizedBox(height: 14),
          TextField(controller: _localCtrl, decoration: const InputDecoration(labelText: '📍 Local')),
          const SizedBox(height: 14),
          const Text('💻 Formato', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Presencial', 'Online'].map((f) {
              return ChoiceChip(label: Text(f), selected: _formato == f, onSelected: (_) => setState(() => _formato = f));
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('📖 Livro do encontro', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          StreamBuilder<List<Livro>>(
            stream: firestore.livrosStream(),
            builder: (context, snap) {
              final livros = snap.data ?? [];
              return DropdownButtonFormField<String>(
                value: _livroId,
                items: livros
                    .map((l) => DropdownMenuItem(value: l.id, child: Text(l.titulo, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => _livroId = v),
                decoration: const InputDecoration(labelText: 'Selecionar livro (opcional)'),
              );
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _pautaCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: '📝 Pauta / tópicos do encontro'),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _salvando ? null : _salvar,
            child: _salvando
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Marcar encontro'),
          ),
        ],
      ),
    );
  }
}
