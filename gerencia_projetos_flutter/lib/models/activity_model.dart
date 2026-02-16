import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoAtividade { palestra, minicurso, workshop }

class AtividadeModel {
  final String id;
  final String titulo;
  final String descricao;
  final String palestranteId;
  final String palestranteNome;
  final DateTime data;
  final DateTime horaInicio;
  final DateTime horaFim;
  final String local;
  final TipoAtividade tipo;
  final List<String> tags;
  final bool publicada;

  AtividadeModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.palestranteId,
    required this.palestranteNome,
    required this.data,
    required this.horaInicio,
    required this.horaFim,
    required this.local,
    required this.tipo,
    required this.tags,
    required this.publicada,
  });

  factory AtividadeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AtividadeModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descricao: data['descricao'] ?? '',
      palestranteId: data['palestranteId'] ?? '',
      palestranteNome: data['palestranteNome'] ?? '',
      data: (data['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
      horaInicio: (data['horaInicio'] as Timestamp?)?.toDate() ?? DateTime.now(),
      horaFim: (data['horaFim'] as Timestamp?)?.toDate() ?? DateTime.now(),
      local: data['local'] ?? '',
      tipo: TipoAtividade.values.firstWhere(
        (e) => e.toString().split('.').last == data['tipo'],
        orElse: () => TipoAtividade.palestra,
      ),
      tags: List<String>.from(data['tags'] ?? []),
      publicada: data['publicada'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'palestranteId': palestranteId,
      'palestranteNome': palestranteNome,
      'data': Timestamp.fromDate(data),
      'horaInicio': Timestamp.fromDate(horaInicio),
      'horaFim': Timestamp.fromDate(horaFim),
      'local': local,
      'tipo': tipo.toString().split('.').last,
      'tags': tags,
      'publicada': publicada,
    };
  }

  AtividadeModel copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? palestranteId,
    String? palestranteNome,
    DateTime? data,
    DateTime? horaInicio,
    DateTime? horaFim,
    String? local,
    TipoAtividade? tipo,
    List<String>? tags,
    bool? publicada,
  }) {
    return AtividadeModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      palestranteId: palestranteId ?? this.palestranteId,
      palestranteNome: palestranteNome ?? this.palestranteNome,
      data: data ?? this.data,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFim: horaFim ?? this.horaFim,
      local: local ?? this.local,
      tipo: tipo ?? this.tipo,
      tags: tags ?? this.tags,
      publicada: publicada ?? this.publicada,
    );
  }
}
