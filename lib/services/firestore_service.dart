import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/participante.dart';
import '../models/livro.dart';
import '../models/votacao.dart';
import '../models/encontro.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- PARTICIPANTES ----------------

  Stream<List<Participante>> participantesStream() {
    return _db.collection('participantes').orderBy('nome').snapshots().map(
          (s) => s.docs.map((d) => Participante.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<Participante?> getParticipante(String id) async {
    final doc = await _db.collection('participantes').doc(id).get();
    if (!doc.exists) return null;
    return Participante.fromMap(doc.id, doc.data()!);
  }

  Future<void> atualizarParticipante(String id, Map<String, dynamic> dados) {
    return _db.collection('participantes').doc(id).update(dados);
  }

  // ---------------- LIVROS / BIBLIOTECA ----------------

  Stream<List<Livro>> livrosStream({String? status}) {
    Query<Map<String, dynamic>> query = _db.collection('livros');
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query.orderBy('criadoEm', descending: true).snapshots().map(
          (s) => s.docs.map((d) => Livro.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<Livro?> livroAtualStream() {
    return _db
        .collection('livros')
        .where('status', isEqualTo: LivroStatus.lendoAgora)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty ? null : Livro.fromMap(s.docs.first.id, s.docs.first.data()));
  }

  /// Participante sugere um livro novo (entra como "Sugestão").
  Future<String> sugerirLivro(Livro livro) async {
    final doc = await _db.collection('livros').add(livro.toMap());
    return doc.id;
  }

  /// Admin adiciona um livro diretamente (qualquer status).
  Future<String> adicionarLivroComoAdmin(Livro livro) async {
    final doc = await _db.collection('livros').add(livro.toMap());
    return doc.id;
  }

  Future<void> atualizarLivro(String id, Map<String, dynamic> dados) {
    return _db.collection('livros').doc(id).update(dados);
  }

  Future<void> excluirLivro(String id) {
    return _db.collection('livros').doc(id).delete();
  }

  /// Admin move um livro de "Sugestão" para "Em votação" e cria o registro de Votação.
  Future<void> abrirVotacaoParaLivro(Livro livro) async {
    await _db.collection('livros').doc(livro.id).update({'status': LivroStatus.votacao});
    final jaExiste = await _db
        .collection('votacoes')
        .where('livroId', isEqualTo: livro.id)
        .where('status', isEqualTo: VotacaoStatus.aberta)
        .limit(1)
        .get();
    if (jaExiste.docs.isEmpty) {
      final votacao = Votacao(
        id: '',
        livroId: livro.id,
        indicadoPorId: livro.indicadoPorId ?? '',
        genero: livro.genero.isNotEmpty ? livro.genero.first : null,
      );
      await _db.collection('votacoes').add(votacao.toMap());
    }
  }

  // ---------------- VOTAÇÕES ----------------

  Stream<List<Votacao>> votacoesAbertasStream() {
    return _db
        .collection('votacoes')
        .where('status', isEqualTo: VotacaoStatus.aberta)
        .snapshots()
        .map((s) => s.docs.map((d) => Votacao.fromMap(d.id, d.data())).toList());
  }

  /// Registra (ou remove) o voto de um participante numa votação.
  Future<void> votar({required String votacaoId, required String participanteId}) {
    return _db.collection('votacoes').doc(votacaoId).update({
      'votosIds': FieldValue.arrayUnion([participanteId]),
    });
  }

  Future<void> removerVoto({required String votacaoId, required String participanteId}) {
    return _db.collection('votacoes').doc(votacaoId).update({
      'votosIds': FieldValue.arrayRemove([participanteId]),
    });
  }

  /// Admin encerra a votação e define o livro vencedor como "Lendo agora".
  Future<void> encerrarVotacaoEEscolherLivro({
    required String livroVencedorId,
    required List<String> votacaoIdsParaEncerrar,
  }) async {
    final batch = _db.batch();
    for (final vId in votacaoIdsParaEncerrar) {
      batch.update(_db.collection('votacoes').doc(vId), {'status': VotacaoStatus.encerrada});
    }
    batch.update(_db.collection('livros').doc(livroVencedorId), {
      'status': LivroStatus.lendoAgora,
    });
    await batch.commit();
  }

  // ---------------- ENCONTROS ----------------

  Stream<List<Encontro>> encontrosStream() {
    return _db.collection('encontros').orderBy('data', descending: true).snapshots().map(
          (s) => s.docs.map((d) => Encontro.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<String> criarEncontro(Encontro encontro) async {
    final doc = await _db.collection('encontros').add(encontro.toMap());
    return doc.id;
  }

  Future<void> atualizarEncontro(String id, Map<String, dynamic> dados) {
    return _db.collection('encontros').doc(id).update(dados);
  }
}
