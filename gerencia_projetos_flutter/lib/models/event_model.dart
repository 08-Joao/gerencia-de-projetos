import 'package:cloud_firestore/cloud_firestore.dart';

class EventoModel {
  final String id;
  final String nome;
  final String descricao;
  final DateTime dataInicio;
  final DateTime dataFim;
  final bool ativo;

  EventoModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.dataInicio,
    required this.dataFim,
    required this.ativo,
  });

  factory EventoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventoModel(
      id: doc.id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      dataInicio: (data['dataInicio'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dataFim: (data['dataFim'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ativo: data['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'descricao': descricao,
      'dataInicio': Timestamp.fromDate(dataInicio),
      'dataFim': Timestamp.fromDate(dataFim),
      'ativo': ativo,
    };
  }

  EventoModel copyWith({
    String? id,
    String? nome,
    String? descricao,
    DateTime? dataInicio,
    DateTime? dataFim,
    bool? ativo,
  }) {
    return EventoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      ativo: ativo ?? this.ativo,
    );
  }
}
