import 'package:cloud_firestore/cloud_firestore.dart';

enum StatusPergunta { pendente, aprovada, recusada }

class PerguntaModel {
  final String id;
  final String atividadeId;
  final String autorId;
  final String autorNome;
  final String texto;
  final StatusPergunta status;
  final DateTime criadaEm;
  final DateTime? moderadaEm;
  final String? motivoRecusa;
  final bool respondida;

  PerguntaModel({
    required this.id,
    required this.atividadeId,
    required this.autorId,
    required this.autorNome,
    required this.texto,
    required this.status,
    required this.criadaEm,
    this.moderadaEm,
    this.motivoRecusa,
    required this.respondida,
  });

  factory PerguntaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PerguntaModel(
      id: doc.id,
      atividadeId: data['atividadeId'] ?? '',
      autorId: data['autorId'] ?? '',
      autorNome: data['autorNome'] ?? '',
      texto: data['texto'] ?? '',
      status: StatusPergunta.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => StatusPergunta.pendente,
      ),
      criadaEm: (data['criadaEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      moderadaEm: (data['moderadaEm'] as Timestamp?)?.toDate(),
      motivoRecusa: data['motivoRecusa'],
      respondida: data['respondida'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'atividadeId': atividadeId,
      'autorId': autorId,
      'autorNome': autorNome,
      'texto': texto,
      'status': status.toString().split('.').last,
      'criadaEm': Timestamp.fromDate(criadaEm),
      'moderadaEm': moderadaEm != null ? Timestamp.fromDate(moderadaEm!) : null,
      'motivoRecusa': motivoRecusa,
      'respondida': respondida,
    };
  }

  PerguntaModel copyWith({
    String? id,
    String? atividadeId,
    String? autorId,
    String? autorNome,
    String? texto,
    StatusPergunta? status,
    DateTime? criadaEm,
    DateTime? moderadaEm,
    String? motivoRecusa,
    bool? respondida,
  }) {
    return PerguntaModel(
      id: id ?? this.id,
      atividadeId: atividadeId ?? this.atividadeId,
      autorId: autorId ?? this.autorId,
      autorNome: autorNome ?? this.autorNome,
      texto: texto ?? this.texto,
      status: status ?? this.status,
      criadaEm: criadaEm ?? this.criadaEm,
      moderadaEm: moderadaEm ?? this.moderadaEm,
      motivoRecusa: motivoRecusa ?? this.motivoRecusa,
      respondida: respondida ?? this.respondida,
    );
  }
}
