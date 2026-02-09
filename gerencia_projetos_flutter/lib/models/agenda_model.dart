import 'package:cloud_firestore/cloud_firestore.dart';

class ItemAgendaModel {
  final String atividadeId;
  final DateTime adicionadaEm;
  final int lembreteMinutos;

  ItemAgendaModel({
    required this.atividadeId,
    required this.adicionadaEm,
    required this.lembreteMinutos,
  });

  factory ItemAgendaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemAgendaModel(
      atividadeId: doc.id,
      adicionadaEm: (data['adicionadaEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lembreteMinutos: data['lembreteMinutos'] ?? 15,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'adicionadaEm': Timestamp.fromDate(adicionadaEm),
      'lembreteMinutos': lembreteMinutos,
    };
  }

  ItemAgendaModel copyWith({
    String? atividadeId,
    DateTime? adicionadaEm,
    int? lembreteMinutos,
  }) {
    return ItemAgendaModel(
      atividadeId: atividadeId ?? this.atividadeId,
      adicionadaEm: adicionadaEm ?? this.adicionadaEm,
      lembreteMinutos: lembreteMinutos ?? this.lembreteMinutos,
    );
  }
}
