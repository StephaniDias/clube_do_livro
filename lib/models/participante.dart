import 'package:cloud_firestore/cloud_firestore.dart';

class Participante {
  final String id; // mesmo uid do Firebase Auth
  final String nome;
  final String? fotoUrl;
  final String? apelido;
  final String? aniversario; // formato dd/MM, texto simples
  final String? cidade;
  final List<String> generosFavoritos;
  final String? livroFavoritoId;
  final String? lendoAgoraId;
  final double notaMedia;
  final Timestamp? entradaClube;
  final String? indicadoPorId;
  final String? instagram;
  final String status; // 'Ativo' | 'Ausente'
  final bool isAdmin;

  Participante({
    required this.id,
    required this.nome,
    this.fotoUrl,
    this.apelido,
    this.aniversario,
    this.cidade,
    this.generosFavoritos = const [],
    this.livroFavoritoId,
    this.lendoAgoraId,
    this.notaMedia = 0,
    this.entradaClube,
    this.indicadoPorId,
    this.instagram,
    this.status = 'Ativo',
    this.isAdmin = false,
  });

  factory Participante.fromMap(String id, Map<String, dynamic> map) {
    return Participante(
      id: id,
      nome: map['nome'] ?? '',
      fotoUrl: map['fotoUrl'],
      apelido: map['apelido'],
      aniversario: map['aniversario'],
      cidade: map['cidade'],
      generosFavoritos: List<String>.from(map['generosFavoritos'] ?? []),
      livroFavoritoId: map['livroFavoritoId'],
      lendoAgoraId: map['lendoAgoraId'],
      notaMedia: (map['notaMedia'] ?? 0).toDouble(),
      entradaClube: map['entradaClube'],
      indicadoPorId: map['indicadoPorId'],
      instagram: map['instagram'],
      status: map['status'] ?? 'Ativo',
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'fotoUrl': fotoUrl,
      'apelido': apelido,
      'aniversario': aniversario,
      'cidade': cidade,
      'generosFavoritos': generosFavoritos,
      'livroFavoritoId': livroFavoritoId,
      'lendoAgoraId': lendoAgoraId,
      'notaMedia': notaMedia,
      'entradaClube': entradaClube ?? FieldValue.serverTimestamp(),
      'indicadoPorId': indicadoPorId,
      'instagram': instagram,
      'status': status,
      'isAdmin': isAdmin,
    };
  }

  Participante copyWith({
    String? nome,
    String? fotoUrl,
    String? apelido,
    String? aniversario,
    String? cidade,
    List<String>? generosFavoritos,
    String? livroFavoritoId,
    String? lendoAgoraId,
    double? notaMedia,
    String? indicadoPorId,
    String? instagram,
    String? status,
    bool? isAdmin,
  }) {
    return Participante(
      id: id,
      nome: nome ?? this.nome,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      apelido: apelido ?? this.apelido,
      aniversario: aniversario ?? this.aniversario,
      cidade: cidade ?? this.cidade,
      generosFavoritos: generosFavoritos ?? this.generosFavoritos,
      livroFavoritoId: livroFavoritoId ?? this.livroFavoritoId,
      lendoAgoraId: lendoAgoraId ?? this.lendoAgoraId,
      notaMedia: notaMedia ?? this.notaMedia,
      entradaClube: entradaClube,
      indicadoPorId: indicadoPorId ?? this.indicadoPorId,
      instagram: instagram ?? this.instagram,
      status: status ?? this.status,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
