import 'package:cloud_firestore/cloud_firestore.dart';

class Encontro {
  final String id;
  final Timestamp? data;
  final String? horario; // texto simples "19:30"
  final String? livroId;
  final String? local;
  final String formato; // Presencial | Online
  final List<String> participantesIds;
  final String? pauta;
  final List<String> fotosUrls;
  final double? notaEncontro;

  Encontro({
    required this.id,
    this.data,
    this.horario,
    this.livroId,
    this.local,
    this.formato = 'Presencial',
    this.participantesIds = const [],
    this.pauta,
    this.fotosUrls = const [],
    this.notaEncontro,
  });

  factory Encontro.fromMap(String id, Map<String, dynamic> map) {
    return Encontro(
      id: id,
      data: map['data'],
      horario: map['horario'],
      livroId: map['livroId'],
      local: map['local'],
      formato: map['formato'] ?? 'Presencial',
      participantesIds: List<String>.from(map['participantesIds'] ?? []),
      pauta: map['pauta'],
      fotosUrls: List<String>.from(map['fotosUrls'] ?? []),
      notaEncontro: map['notaEncontro']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'horario': horario,
      'livroId': livroId,
      'local': local,
      'formato': formato,
      'participantesIds': participantesIds,
      'pauta': pauta,
      'fotosUrls': fotosUrls,
      'notaEncontro': notaEncontro,
    };
  }
}
