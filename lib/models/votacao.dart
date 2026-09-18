import 'package:cloud_firestore/cloud_firestore.dart';

class VotacaoStatus {
  static const aberta = 'Aberta';
  static const encerrada = 'Encerrada';
}

class Votacao {
  final String id;
  final String livroId;
  final String indicadoPorId;
  final List<String> votosIds; // ids dos participantes que votaram nesse livro
  final String? genero;
  final String status; // Aberta | Encerrada
  final String? motivo;
  final Timestamp? criadoEm;

  Votacao({
    required this.id,
    required this.livroId,
    required this.indicadoPorId,
    this.votosIds = const [],
    this.genero,
    this.status = VotacaoStatus.aberta,
    this.motivo,
    this.criadoEm,
  });

  int get totalVotos => votosIds.length;

  factory Votacao.fromMap(String id, Map<String, dynamic> map) {
    return Votacao(
      id: id,
      livroId: map['livroId'] ?? '',
      indicadoPorId: map['indicadoPorId'] ?? '',
      votosIds: List<String>.from(map['votosIds'] ?? []),
      genero: map['genero'],
      status: map['status'] ?? VotacaoStatus.aberta,
      motivo: map['motivo'],
      criadoEm: map['criadoEm'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'livroId': livroId,
      'indicadoPorId': indicadoPorId,
      'votosIds': votosIds,
      'genero': genero,
      'status': status,
      'motivo': motivo,
      'criadoEm': criadoEm ?? FieldValue.serverTimestamp(),
    };
  }
}
