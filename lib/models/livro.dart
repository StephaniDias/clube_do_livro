import 'package:cloud_firestore/cloud_firestore.dart';

/// Status de um livro dentro do fluxo do clube.
/// sugestao   -> sugerido por um participante, aguardando o admin
/// votacao    -> liberado pelo admin para votação
/// lendoAgora -> escolhido, é a leitura atual do clube
/// lido       -> já foi lido/discutido em encontro
/// arquivado  -> não seguiu, ficou fora
class LivroStatus {
  static const sugestao = 'Sugestão';
  static const votacao = 'Em votação';
  static const lendoAgora = 'Lendo agora';
  static const lido = 'Lido';
  static const arquivado = 'Arquivado';

  static const todos = [sugestao, votacao, lendoAgora, lido, arquivado];
}

class Livro {
  final String id;
  final String titulo;
  final String autor;
  final String? capaUrl;
  final List<String> genero;
  final int? anoPublicacao;
  final int? paginas;
  final double notaClube; // rollup calculado a partir das Avaliações
  final List<String> participantesIds; // quem já leu
  final String? encontroId;
  final String status;
  final String? resenhaClube;
  final String? indicadoPorId; // participante que sugeriu (se veio de sugestão)
  final Timestamp? criadoEm;

  Livro({
    required this.id,
    required this.titulo,
    required this.autor,
    this.capaUrl,
    this.genero = const [],
    this.anoPublicacao,
    this.paginas,
    this.notaClube = 0,
    this.participantesIds = const [],
    this.encontroId,
    this.status = LivroStatus.sugestao,
    this.resenhaClube,
    this.indicadoPorId,
    this.criadoEm,
  });

  factory Livro.fromMap(String id, Map<String, dynamic> map) {
    return Livro(
      id: id,
      titulo: map['titulo'] ?? '',
      autor: map['autor'] ?? '',
      capaUrl: map['capaUrl'],
      genero: List<String>.from(map['genero'] ?? []),
      anoPublicacao: map['anoPublicacao'],
      paginas: map['paginas'],
      notaClube: (map['notaClube'] ?? 0).toDouble(),
      participantesIds: List<String>.from(map['participantesIds'] ?? []),
      encontroId: map['encontroId'],
      status: map['status'] ?? LivroStatus.sugestao,
      resenhaClube: map['resenhaClube'],
      indicadoPorId: map['indicadoPorId'],
      criadoEm: map['criadoEm'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'autor': autor,
      'capaUrl': capaUrl,
      'genero': genero,
      'anoPublicacao': anoPublicacao,
      'paginas': paginas,
      'notaClube': notaClube,
      'participantesIds': participantesIds,
      'encontroId': encontroId,
      'status': status,
      'resenhaClube': resenhaClube,
      'indicadoPorId': indicadoPorId,
      'criadoEm': criadoEm ?? FieldValue.serverTimestamp(),
    };
  }
}
